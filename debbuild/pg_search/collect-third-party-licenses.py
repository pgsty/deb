#!/usr/bin/env python3
"""Collect license/notice files for pg_search's resolved normal-dependency closure."""

from __future__ import annotations

import hashlib
import json
import re
import shutil
import sys
from pathlib import Path

EXPECTED_GIT_SOURCES = {
    "git+https://github.com/paradedb/datafusion-distributed?tag=snapshot-main-2026-08-20-204632#4d870ae1a5abb23618eac0b1844c265ffa2991d8",
    "git+https://github.com/paradedb/fst.git#11e89334c578f26f9fbafbd1122ffb220ebbdbbf",
    "git+https://github.com/paradedb/opencc-jieba-rs?branch=paradedb.no-msrv#36bb03c052f087b603a483e01cdaac260e36898f",
    "git+https://github.com/paradedb/superkmeans-rs?rev=b89e83196143acd518f1d8212ec1f53474e936d4#b89e83196143acd518f1d8212ec1f53474e936d4",
    "git+https://github.com/paradedb/tantivy.git?rev=c3caae3f613d5906c8080a3c3c2845190e749b64#c3caae3f613d5906c8080a3c3c2845190e749b64",
}
NOTICE_NAME = re.compile(
    r"^(licen[cs]e|copying|notice|copyright|unlicense)([._-].*)?$", re.IGNORECASE
)


def normal_closure(metadata: dict) -> set[str]:
    resolve = metadata.get("resolve")
    if not resolve or not resolve.get("root"):
        raise SystemExit("cargo metadata did not return a resolved root")
    nodes = {node["id"]: node for node in resolve["nodes"]}
    closure: set[str] = set()
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


def notice_candidates(package: dict) -> list[Path]:
    manifest = Path(package["manifest_path"])
    root = manifest.parent
    candidates: list[Path] = []

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

    unique: dict[Path, None] = {}
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
        "missing_license_fields=0\n"
        f"notice_gaps_with_common_text_coverage={len(notice_gaps)}\n"
        "uncovered_notice_gaps=0\n",
        encoding="utf-8",
    )
    (out_dir / "LICENSE-EXPRESSIONS.txt").write_text(
        "\n".join(sorted(license_expressions)) + "\n", encoding="utf-8"
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
