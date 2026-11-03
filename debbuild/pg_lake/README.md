# pg_lake 3.5.10

This recipe builds the upstream `pg_lake` 3.5.10 bundle for PostgreSQL 16,
17 and 18. The single DEB source produces the eight extensions
`pg_extension_updater`, `pg_lake`, `pg_extension_base`, `pg_lake_iceberg`,
`pg_lake_engine`, `pg_map`, `pg_lake_table` and `pg_lake_copy`.

- Upstream: <https://github.com/Snowflake-Labs/pg_lake>
- Release: <https://github.com/Snowflake-Labs/pg_lake/releases/tag/v3.5.10>
- Source: `pg_lake-3.5.10.tar.gz`
- Source SHA-256: `7b39247062ef5e1511c1feefb381b735ff211f50e2e441e8b701b1ac89efcd53`
- Upstream commit: `ac94b91467860e9103d19217999585a17db1db84`
- Packaging patch: `patches/pg_lake-3.5.10.patch`
- Patch SHA-256: `21b061739a804c01c3bb6d7a74bf1d27a4bc0f73f1ed2d2f71234ef17bbac07f`

The archive includes the pinned Avro, DuckDB, DuckDB PostgreSQL and database
connector sources. `SOURCE_MANIFEST` and `extension_config.cmake` record the
httpfs, AWS and Azure commits fetched during the build. The build uses vcpkg 2025.10.17 at
commit `74e6536215718009aae747d86d84b78376bf9e09`, DuckDB v1.5.5 and the
bundled Brotli 1.1.1 patch. The build does not fetch Polaris and does not add
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
| httpfs | `827222fb45a043a7a852d1f7aae46901492a3cda` | `~/ext/src/httpfs-827222fb/source` |
| AWS | `b2649e68341a9ee717588dd23f277904727ce793` | `~/ext/src/aws-b2649e68/source` |
| Azure | `003214c96d0caa39d5c3e27a9e1976a0692c7d37` | `~/ext/src/azure-003214c9/source` |

`HTTPFS_SOURCE_OVERRIDE`, `AWS_SOURCE_OVERRIDE` and `AZURE_SOURCE_OVERRIDE`
select those directories when present; otherwise CMake uses the upstream
pinned repositories. Verify each checkout's commit before building. License
installation covers both FetchContent's build directories and these overrides.

Production validation for 3.5.10 covers Debian 12 (`bookworm`), Debian 13
(`trixie`), Ubuntu 22.04 (`jammy`), Ubuntu 24.04 (`noble`) and Ubuntu 26.04
(`resolute`), on amd64 and arm64, for PostgreSQL 16 through 18. The completed
matrix is expected to contain 30 main packages and 30 matching dbgsym packages.
Runtime checks cover extension creation, `pg_map`, DuckDB v1.5.5, Moto S3,
Iceberg insert/update/delete and rollback, Parquet and CSV export/read,
restart persistence, EXPLAIN JSON and the Brotli 1.1.1 decoder vector.

Artifacts are collected under the local `apt/<codename>/` directories. This
work does not import or publish an APT repository, synchronize a CDN, update
the `pgext` database, or commit Git changes.
