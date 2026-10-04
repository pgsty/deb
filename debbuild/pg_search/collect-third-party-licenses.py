#!/usr/bin/env python3
"""Collect license/notice files for pg_search's resolved normal-dependency closure."""

import hashlib
import json
import re
import shutil
import sys
from pathlib import Path
from typing import Dict, List, Set

EXPECTED_GIT_SOURCES = {
    "git+https://github.com/paradedb/datafusion-distributed.git?tag=snapshot-main-2026-09-28-172238#1e87c8d6bd266594ec9210f42ed783d8847aedeb",
    "git+https://github.com/paradedb/datafusion.git?branch=paradedb.branch-55#41b058cc278eb497a2ffc6b41a323f056d3ef568",
    "git+https://github.com/paradedb/fst.git?rev=1d2e473c6de63d17749030eb8538ba4d647f3430#1d2e473c6de63d17749030eb8538ba4d647f3430",
    "git+https://github.com/paradedb/opencc-jieba-rs?branch=main#1bee2628bcae67a955caa5e91b740d170f5615d0",
    "git+https://github.com/paradedb/superkmeans-rs?rev=c06dc2b6e9bd15fb5c4a0627178bebbe1fb37a64#c06dc2b6e9bd15fb5c4a0627178bebbe1fb37a64",
    "git+https://github.com/paradedb/tantivy.git?rev=7540730ee070f1e668017bf0f003024554eaab0a#7540730ee070f1e668017bf0f003024554eaab0a",
}
NOTICE_NAME = re.compile(
    r"^(licen[cs]e|copying|notice|copyright|unlicense)([._-].*)?$", re.IGNORECASE
)

# These five manifests omit SPDX metadata at this exact Tantivy revision.
# No subdirectory license overrides the repository's checked MIT LICENSE.
QUANT_SOURCE = "git+https://github.com/paradedb/tantivy.git?rev=7540730ee070f1e668017bf0f003024554eaab0a#7540730ee070f1e668017bf0f003024554eaab0a"
QUANT_CRATES = {"cascade", "fht", "grid-plane", "quant-model", "sign-plane"}
QUANT_LICENSE_SHA256 = "acacd14bebbffdb30d62443c282fb4da3e81915a9f69c63d5d745a029f44de8a"
QUANT_LICENSE_URL = "https://github.com/paradedb/tantivy/blob/7540730ee070f1e668017bf0f003024554eaab0a/LICENSE"


def normal_closure(metadata: dict) -> Set[str]:
    resolve = metadata.get("resolve")
    if not resolve or not resolve.get("root"):
        raise SystemExit("cargo metadata did not return a resolved root")
    nodes = {node["id"]: node for node in resolve["nodes"]}
    closure: Set[str] = set()
    pending = [resolve["root"]]
    while pending:
        package_id = pending.pop()
        if package_id in closure:
            continue
        closure.add(package_id)
        node = nodes[package_id]
        for dependency in node.get("deps", []):
            if any(
                kind.get("kind") in (None, "normal")
                for kind in dependency.get("dep_kinds", [])
            ):
                pending.append(dependency["pkg"])
    return closure


def notice_candidates(package: dict) -> List[Path]:
    manifest = Path(package["manifest_path"])
    root = manifest.parent
    candidates: List[Path] = []

    license_file = package.get("license_file")
    if license_file:
        path = Path(license_file)
        if not path.is_absolute():
            path = root / path
        if path.is_file():
            candidates.append(path)

    def add_from(directory: Path) -> None:
        if not directory.is_dir():
            return
        for entry in sorted(directory.iterdir(), key=lambda item: item.name.casefold()):
            if entry.is_file() and NOTICE_NAME.match(entry.name):
                candidates.append(entry)
            elif entry.is_dir() and entry.name.casefold() == "licenses":
                candidates.extend(
                    sorted(
                        (item for item in entry.rglob("*") if item.is_file()),
                        key=lambda item: item.as_posix().casefold(),
                    )
                )

    add_from(root)
    if not candidates and (package.get("source") or "").startswith("git+"):
        current = root.parent
        for _ in range(12):
            add_from(current)
            if candidates or current.parent == current:
                break
            current = current.parent

    unique: Dict[Path, None] = {}
    for path in candidates:
        unique[path.resolve()] = None
    return list(unique)


def safe(value: str) -> str:
    return re.sub(r"[^A-Za-z0-9._+-]+", "_", value)


def main() -> int:
    if len(sys.argv) != 3:
        raise SystemExit("usage: collect-third-party-licenses.py METADATA_JSON OUT_DIR")
    metadata_path = Path(sys.argv[1])
    out_dir = Path(sys.argv[2])
    if out_dir.exists() and any(out_dir.iterdir()):
        raise SystemExit(f"refusing non-empty output directory: {out_dir}")
    out_dir.mkdir(parents=True, exist_ok=True)

    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    packages = {package["id"]: package for package in metadata["packages"]}
    closure = normal_closure(metadata)
    root_id = metadata["resolve"]["root"]

    rows = []
    missing = []
    notice_gaps = []
    git_sources = set()
    license_expressions = set()
    notice_total = 0
    repository_licenses = []
    for package_id in sorted(closure):
        package = packages[package_id]
        source = package.get("source") or ""
        if source.startswith("git+"):
            git_sources.add(source)
        if package_id == root_id or not source:
            rows.append(
                (
                    package["name"],
                    package["version"],
                    package.get("license") or "",
                    source or "workspace-covered-by-AGPL-3.0-or-later",
                    "main-package-license",
                    "",
                )
            )
            continue

        declared_license = package.get("license")
        if (
            not declared_license
            and source == QUANT_SOURCE
            and package["name"] in QUANT_CRATES
            and package["version"] == "0.1.0"
        ):
            root_license = Path(package["manifest_path"]).parents[2] / "LICENSE"
            if hashlib.sha256(root_license.read_bytes()).hexdigest() != QUANT_LICENSE_SHA256:
                raise SystemExit("reviewed Tantivy repository license changed")
            declared_license = "MIT"
            repository_licenses.append(
                f"{package['name']}\t{package['version']}\tMIT\t{QUANT_LICENSE_URL}"
            )
        if not declared_license:
            missing.append(
                f"{package['name']} {package['version']} {source} has no license expression"
            )
            continue
        license_expressions.add(declared_license)

        notices = notice_candidates(package)
        if not notices:
            source_hash = hashlib.sha256(source.encode("utf-8")).hexdigest()[:12]
            destination = (
                f"{safe(package['name'])}-{safe(package['version'])}-{source_hash}"
                "-UPSTREAM-NOTICE-GAP.txt"
            )
            target = out_dir / destination
            gap_declaration = (
                f"Package: {package['name']} {package['version']}\n"
                f"Source: {source}\n"
                f"Declared license: {declared_license}\n"
                "Packaging risk declaration: the exact locked crate payload contains no top-level "
                "LICENSE, COPYING, NOTICE, COPYRIGHT, UNLICENSE, or LICENSES/ file. "
                "The package records the upstream Cargo license declaration verbatim and "
                "maps it to a common license text shipped elsewhere in this same closure. "
                "This file records an upstream notice gap; it does not claim human legal review.\n"
            )
            target.write_text(gap_declaration, encoding="utf-8")
            digest = hashlib.sha256(target.read_bytes()).hexdigest()
            rows.append(
                (
                    package["name"],
                    package["version"],
                    declared_license,
                    source,
                    destination,
                    digest,
                )
            )
            notice_gaps.append(
                f"{package['name']}\t{package['version']}\t{declared_license}\t{source}"
            )
            continue

        source_hash = hashlib.sha256(source.encode("utf-8")).hexdigest()[:12]
        for index, notice in enumerate(notices, start=1):
            destination = (
                f"{safe(package['name'])}-{safe(package['version'])}-{source_hash}"
                f"-{index:02d}-{safe(notice.name)}"
            )
            target = out_dir / destination
            shutil.copyfile(notice, target)
            digest = hashlib.sha256(target.read_bytes()).hexdigest()
            rows.append(
                (
                    package["name"],
                    package["version"],
                    declared_license,
                    source,
                    destination,
                    digest,
                )
            )
            notice_total += 1

    if git_sources != EXPECTED_GIT_SOURCES:
        missing_git = sorted(EXPECTED_GIT_SOURCES - git_sources)
        extra_git = sorted(git_sources - EXPECTED_GIT_SOURCES)
        raise SystemExit(f"Git source closure mismatch: missing={missing_git} extra={extra_git}")
    if missing:
        raise SystemExit("missing dependency license declarations:\n" + "\n".join(sorted(missing)))

    manifest_lines = [
        "package\tversion\tdeclared_license\tsource\tpackaged_notice\tsha256"
    ]
    manifest_lines.extend("\t".join(row) for row in rows)
    (out_dir / "MANIFEST.tsv").write_text(
        "\n".join(manifest_lines) + "\n", encoding="utf-8"
    )
    (out_dir / "SUMMARY.txt").write_text(
        f"normal_closure_packages={len(closure)}\n"
        f"git_sources={len(git_sources)}\n"
        f"packaged_notice_files={notice_total}\n"
        f"upstream_notice_gaps={len(notice_gaps)}\n"
        f"unique_license_expressions={len(license_expressions)}\n"
        "unresolved_license_fields=0\n"
        f"licenses_from_reviewed_repository={len(repository_licenses)}\n"
        f"notice_gaps_with_common_text_coverage={len(notice_gaps)}\n"
        "uncovered_notice_gaps=0\n",
        encoding="utf-8",
    )
    (out_dir / "LICENSE-EXPRESSIONS.txt").write_text(
        "\n".join(sorted(license_expressions)) + "\n", encoding="utf-8"
    )
    (out_dir / "REPOSITORY-LICENSES.tsv").write_text(
        "package\tversion\tlicense\tsource_url\n"
        + "\n".join(repository_licenses)
        + ("\n" if repository_licenses else ""),
        encoding="utf-8",
    )
    (out_dir / "UPSTREAM-NOTICE-GAPS.tsv").write_text(
        "package\tversion\tdeclared_license\tsource\n"
        + "\n".join(sorted(notice_gaps))
        + ("\n" if notice_gaps else ""),
        encoding="utf-8",
    )
    representatives = {
        "Apache-2.0": next(
            row[4] for row in rows if row[0] == "datafusion-distributed" and row[5]
        ),
        "MIT": next(row[4] for row in rows if row[0] == "opencc-jieba-rs" and row[5]),
        "CC0-1.0": next(row[4] for row in rows if row[0] == "tiny-keccak" and row[5]),
    }
    coverage_lines = [
        "package\tversion\tdeclared_license\telected_common_license\tpackaged_representative"
    ]
    for gap in sorted(notice_gaps):
        name, version, declared_license, _source = gap.split("\t", 3)
        if declared_license == "CC0-1.0":
            elected = "CC0-1.0"
        elif declared_license == "Apache-2.0":
            elected = "Apache-2.0"
        elif "MIT" in declared_license:
            elected = "MIT"
        elif "Apache-2.0" in declared_license:
            elected = "Apache-2.0"
        else:
            raise SystemExit(f"notice gap has no common-text election: {gap}")
        coverage_lines.append(
            "\t".join((name, version, declared_license, elected, representatives[elected]))
        )
    (out_dir / "NOTICE-GAP-COVERAGE.tsv").write_text(
        "\n".join(coverage_lines) + "\n", encoding="utf-8"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
