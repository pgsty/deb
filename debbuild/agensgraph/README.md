# agensgraph debbuild

AgensGraph 2.18.6.1 is based on PostgreSQL 18.6 and installs the bundled kernel and graph engine under `/usr/agens-18`. LLVM JIT is enabled, and `dh_strip` produces an automatic dbgsym package.

This package follows the repository-standard flow:

1. Read local source tarball from `../SOURCES/`.
2. Extract to `build/`.
3. Copy `debian/` into `build/debian`.
4. Run `dpkg-buildpackage`.

## Usage

```bash
cd ~/debbuild/agensgraph
make
```

Required local tarball (default):

`~/ext/src/agensgraph-2.18.6.1.tar.gz`

Run `pig build get agensgraph` first. If the catalog still returns an older version, copy only the missing archive from the local authoritative source directory to the builder. Use the same [official v2.18.6.1 archive](https://github.com/skaiworldwide-oss/agensgraph/archive/refs/tags/v2.18.6.1.tar.gz) as RPM.

## 2026-10-06 full matrix validation

All ten Debian/Ubuntu combinations passed actual builds, installation and runtime QA: Debian 12/13 and Ubuntu 22.04/24.04/26.04, each on amd64 and arm64. LLVM remained enabled throughout; no source or LLVM workaround was required.

|平台|实际系统|架构|PG|结果|产物|
|---|---|---|---|---|---:|
|`pgsty/d12:build`|Debian GNU/Linux 12 (bookworm)|x86_64|18|构建、安装、运行、JIT、debug 全部通过|2|
|`pgsty/d12a:build`|Debian GNU/Linux 12 (bookworm)|aarch64|18|构建、安装、运行、JIT、debug 全部通过|2|
|`pgsty/d13:build`|Debian GNU/Linux 13 (trixie)|x86_64|18|构建、安装、运行、JIT、debug 全部通过|2|
|`pgsty/d13a:build`|Debian GNU/Linux 13 (trixie)|aarch64|18|构建、安装、运行、JIT、debug 全部通过|2|
|`pgsty/u22:build`|Ubuntu 22.04.5 LTS|x86_64|18|构建、安装、运行、JIT、debug 全部通过|2|
|`pgsty/u22a:build`|Ubuntu 22.04.5 LTS|aarch64|18|构建、安装、运行、JIT、debug 全部通过|2|
|`pgsty/u24:build`|Ubuntu 24.04.4 LTS|x86_64|18|构建、安装、运行、JIT、debug 全部通过|2|
|`pgsty/u24a:build`|Ubuntu 24.04.4 LTS|aarch64|18|构建、安装、运行、JIT、debug 全部通过|2|
|`pgsty/u26:build`|Ubuntu 26.04 LTS|x86_64|18|构建、安装、运行、JIT、debug 全部通过|2|
|`pgsty/u26a:build`|Ubuntu 26.04 LTS|aarch64|18|构建、安装、运行、JIT、debug 全部通过|2|

Every main package contains the graph engine, `agens`, `ag_ctl`, 61 extension controls and 1036 bitcode files including 59 indexes. Each dbgsym contains 137 debug ELF files. PostgreSQL and its debug ELF have matching Build IDs and DWARF. The core JIT libLLVM runtime dependency is retained, without adding LLVM/Clang toolchain, system PostgreSQL or libpq5 dependencies.

Installed server/client programs and shared libraries resolved their dynamic dependencies. Initialization, `pg_trgm`, creating two vertices and an edge, and the `alice → bob` graph query passed on every platform. A forced-JIT query produced the correct sum and its EXPLAIN JSON confirmed actual JIT execution. All test databases were stopped.

Twenty main/dbgsym packages were verified by SHA-256 and collected under `apt/bookworm`, `apt/trixie`, `apt/jammy`, `apt/noble` and `apt/resolute`. Earlier pilot files with the same name and different contents were backed up before replacement.

Evidence: `/tmp/kfull-20261006/oriole-agens/matrix-summary.json`, `SHA256SUMS`, `artifact-manifest.tsv`, and per-platform `results/<platform>/agensgraph-18/`. The input snapshot is recorded in `input-manifest.json`.

No production staging, signing, repository index rebuild, source/binary publication, pgext/database metadata update or Git commit was performed.

## 2026-11-03 full matrix validation (2.18.6.1)

The official `v2.18.6.1` archive (`sha256:68c78c6ceee4b9806cd34e4bd280d7c6f220de587205f6e3836354ab514999b5`) builds PostgreSQL 18.6 / AgensGraph 2.18.6.1 without source patches. The package revision is `1PGSTY`. The recipe honors `DEB_BUILD_OPTIONS=parallel=N`, preserves dpkg build flags, and installs upstream README, LICENSE, NOTICE and COPYRIGHT in its private documentation directory. The copyright metadata now records both Apache-2.0 (AgensGraph) and the PostgreSQL license.

All ten platforms in the table above passed again, using native `pgsty/{d12,d13,u22,u24,u26}:build` amd64 builders on m3 and the corresponding `a` ARM64 images on m1/m5. Each main package preserves the complete `install-world-bin` tree: 61 extension controls, 1035 LLVM bitcode files including 59 indexes, and 136 ELF files. Every ELF has matching build-id debug data with `.debug_info` and `.debug_line`. Installed dynamic links resolve, and programs using libpq resolve the bundled library under `/usr/agens-18/lib`.

Every platform passed initialization, kernel version checks, pg_trgm/hstore/pgcrypto, PL/Python/Perl/Tcl, graph creation and traversal, property updates, transaction rollback and restart persistence. A forced-JIT aggregate returned the expected result and EXPLAIN confirmed actual inlining and optimization. The updated `agens` and `ag_ctl` help contact information was checked. Test databases and build containers were stopped.

Twenty SHA-256-verified main/dbgsym artifacts were collected in the five local `apt/<codename>/` directories. Evidence is under `/Users/vonng/.cache/pgsty-build/20261103-extension-production-003724/deb/`: `09a-evidence.json`, `09a-agensgraph-matrix.json`, `09a-agensgraph-artifacts.json`, source/recipe manifests, and per-platform QA/dependency manifests and build logs. This independent kernel has no `pgext.extension` row; supplier scope follows the reviewed production plan and existing APT package history. No database write, production staging/import/publication or Git commit was performed.
