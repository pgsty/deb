# pg_lake 3.7.0

This recipe builds the upstream `pg_lake` 3.7.0 bundle for PostgreSQL 16,
17, 18 and 19. The single DEB source produces the eight extensions
`pg_extension_updater`, `pg_lake`, `pg_extension_base`, `pg_lake_iceberg`,
`pg_lake_engine`, `pg_map`, `pg_lake_table` and `pg_lake_copy`.

- Upstream: <https://github.com/Snowflake-Labs/pg_lake>
- Release: <https://github.com/Snowflake-Labs/pg_lake/releases/tag/v3.7.0>
- Source: `pg_lake-3.7.0.tar.gz`
- Source SHA-256: `0e1c4beb2e9f126bdfc449b3f254394534e4070000489cc182ce1c955fb96b4c`
- Upstream commit: `37bcb0f8963f4a3115347e020e8f291e42b14827`
- Packaging patch: `patches/pg_lake-3.7.0-packaging.patch`
- Patch SHA-256: `73ee6bf08f316a075e926992bc74152da8a4cf258caacf5ceeb30d804b5f1df9`

The archive includes the pinned Avro, DuckDB, DuckDB PostgreSQL and database
connector sources. `SOURCE_MANIFEST` and `extension_config.cmake` record the
httpfs, AWS and Azure commits fetched during the build. The build uses vcpkg 2025.10.17 at
commit `74e6536215718009aae747d86d84b78376bf9e09`, DuckDB v1.5.6 and the
Brotli 1.1.1 compatibility patch described below. The build does not fetch Polaris and does not add
SQL upgrade scripts or product migrations that are absent from upstream.

The package preserves the eight extension control files, SQL payloads,
PGXS bitcode and the private DuckDB/Avro runtime libraries. Native ELF files
use Debian's automatic dbgsym split; the package does not create a separate
Debian debugsource package. Third-party license and notice files are installed
under each PostgreSQL package's private documentation directory.

Each PostgreSQL major ships its own private DuckDB and Avro ELF files. The
linker uses distinct UUID build IDs so their automatic dbgsym packages can
be installed together without overlapping debug file paths.

Builders with restricted GitHub access may seed these exact connector checkouts:

| Connector | Commit | Default source override |
| --- | --- | --- |
| httpfs | `4bc690dba4496c765777a0269d48fdbaff7cdc11` | `~/ext/src/httpfs-4bc690db/source` |
| AWS | `b2649e68341a9ee717588dd23f277904727ce793` | `~/ext/src/aws-b2649e68/source` |
| Azure | `003214c96d0caa39d5c3e27a9e1976a0692c7d37` | `~/ext/src/azure-003214c9/source` |

`HTTPFS_SOURCE_OVERRIDE`, `AWS_SOURCE_OVERRIDE` and `AZURE_SOURCE_OVERRIDE`
select those directories when present; otherwise CMake uses the upstream
pinned repositories. Verify each checkout's commit before building. License
installation covers both FetchContent's build directories and these overrides.

Upstream 3.7.0 still omits the Brotli block-switch fix present in 3.5.10 while
its pinned DuckDB still embeds Brotli 1.1.0. Both recipes retain that exact
upstream fix and regression test in `pg_lake-3.7.0-brotli-block-switch.patch`, applied
after the packaging patch. `SOURCE_MANIFEST` describes the unmodified source;
the effective packaged decoder includes the fix and reports 1.1.1. The new
packaging patch also tolerates an absent upstream `patches/duckdb` directory
and regenerates context in the embedded scanner patch so it applies exactly.
The packaging patch preserves upstream 3.7.0's fail-fast extension-patch staging.
A checksum stamp prevents overlapping patches from being reapplied on install;
changed patch inputs require a fresh source extraction.

`pg_lake-3.7.0-s3-odr.patch` gives pg_lake's internal S3 deletion batch a
distinct type name. The pinned httpfs defines a different `S3DeleteBatch`
layout in the same namespace, which otherwise produces an LTO ODR warning.
The patch changes no deletion behavior or external API.

Upstream 3.7.0 supports PostgreSQL 16–19 and rejects PG15 in
`pg_extension_base`. Its CI explicitly covers 16, 17, 18 and 19; the PG19
`<limits.h>` compatibility fix is already upstream. No local PostgreSQL API
patch is needed. The recipe defaults to that same 16–19 subset.

Both the bundled libraries and vcpkg dependencies retain the distribution's
full `-g` debug information. The previous `-g1` override is removed. Binary
caches are keyed by the build flags and remain platform-specific. The
configurable ccache limit defaults to 6 GiB. LLVM stays enabled. On builders
whose `postgresql-common` supported-version policy predates PG19, explicitly
set `PG_SUPPORTED_VERSIONS=19` for the targeted build.

Runtime requires `pg_extension_base` in `shared_preload_libraries` and a
running `pgduck_server` with `pg_lake_engine.host` pointing at its socket.
The server installs DuckDB's official spatial extension on first startup;
its extension directory must be writable and the download endpoint reachable.
`--no_extension_install` skips installation but still requires spatial to be
available for loading. The optional Rust Delta bridge stays disabled by the
existing packaging policy (`PG_LAKE_DELTA_SUPPORT=0`).

The 2026-11-21 PG19 validation records live outside Git under
`~/pgsty/artifacts/nonrust-heavy-20261121/pg_lake/result.json`. Consult that
record for the actual package, payload, debug and runtime results. Upstream
PG16–18 support is separate from this batch's targeted PG19 validation; earlier
full-matrix builds do not establish acceptance of 3.7.0 on every platform.

## Representative PG19 validation (2026-11-21)

The final 3.7.0 packages were installed and tested on Rocky Linux 9.8
aarch64 (`pgsty/el9a:build`, m5) and Ubuntu 24.04.5 amd64
(`pgsty/u24:build`, m3), both with PostgreSQL 19.0. The RPM output includes
a main package, debuginfo and debugsource; DEB includes a main package and
dbgsym. Each platform has eight extension controls, eight bitcode indexes,
and matching debug information for all eleven native ELF files. Full
DuckDB/Avro DWARF variable and parameter records were checked.

The EL9 PG19 recipe requires `postgresql19-static` because the provider
moved `libpgcommon.a` and `libpgport.a` out of its devel package. PGXS uses
the matching LLVM21 tools on that builder. The RPM debugsource staging also
restores the unchanged generated parser header under its DWARF path. These
are packaging fixes; no local PG19 PostgreSQL API patch was added.

Both installed packages passed normal pgduck_server startup, creation of
all eight extensions at SQL version 3.7, Parquet COPY round trips, a local
HTTP Parquet foreign table, PG19 partitioned-table COPY, and a dynamic pg_map
expression with JIT. The server reports pg_lake v3.7.0 and DuckDB v1.5.6.
PG16–18 were not rebuilt in this batch. Authenticated cloud storage, REST
catalogs, optional Delta support and upgrades of existing databases remain
unverified; CREATE EXTENSION is not a test of those service-dependent paths.
