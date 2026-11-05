# pg_lake 3.6.0

This recipe builds the upstream `pg_lake` 3.6.0 bundle for PostgreSQL 16,
17 and 18. The single DEB source produces the eight extensions
`pg_extension_updater`, `pg_lake`, `pg_extension_base`, `pg_lake_iceberg`,
`pg_lake_engine`, `pg_map`, `pg_lake_table` and `pg_lake_copy`.

- Upstream: <https://github.com/Snowflake-Labs/pg_lake>
- Release: <https://github.com/Snowflake-Labs/pg_lake/releases/tag/v3.6.0>
- Source: `pg_lake-3.6.0.tar.gz`
- Source SHA-256: `4b0856a2fbbc6d4b2ad1ad29430cb9e060f8ce9e35efd1c8a39e8b18add6fe96`
- Upstream commit: `11e80f182559f43a1181a05759283b509e01b6ab`
- Packaging patch: `patches/pg_lake-3.6.0.patch`
- Patch SHA-256: `bb5ed4ea9b165f5413a782da097e2883ad451c55d77662298ece2211b0bb154c`

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

Upstream 3.6.0 removed the Brotli block-switch fix present in 3.5.10 while
its pinned DuckDB still embeds Brotli 1.1.0. Both recipes retain that exact
upstream fix and regression test in `pg_lake-3.6.0-brotli-1.1.1.patch`, applied
after the packaging patch. `SOURCE_MANIFEST` describes the unmodified source;
the effective packaged decoder includes the fix and reports 1.1.1. The new
packaging patch also tolerates an absent upstream `patches/duckdb` directory
and regenerates context in the embedded scanner patch so it applies exactly.
A checksum stamp prevents overlapping patches from being reapplied on install;
changed patch inputs require a fresh source extraction.

`pg_lake-3.6.0-s3-odr.patch` gives pg_lake's internal S3 deletion batch a
distinct type name. The pinned httpfs defines a different `S3DeleteBatch`
layout in the same namespace, which otherwise produces an LTO ODR warning.
The patch changes no deletion behavior or external API.

This recipe keeps PG16–18 even though upstream 3.6.0 adds PG19 support.
Prior full-matrix validation for 3.5.10 does not establish acceptance of 3.6.0.
Run representative package, private-library, debug and runtime checks before
production builds.
