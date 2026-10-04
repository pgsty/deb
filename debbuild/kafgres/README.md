# kafgres 0.3.0

Source: [upstream tag](https://codeload.github.com/RayElg/kafgres/tar.gz/refs/tags/0.3.0). The original source and both Cargo.lock
files are unchanged. SHA256: `a0f47a90b04f19323b7e51ee6ef06b9f1b0fb4f769ea30adae572904e6ca29ad`.

PGSTY retains its PostgreSQL 16 package target. Other PostgreSQL majors need
separate build and runtime validation before expanding the package matrix.

Build with cargo-pgrx 0.16.1 and an installed Rust toolchain. `PGRX_BIN_DIR`
can select an isolated cargo-pgrx installation. The Cargo lockfiles are fetched
with `--locked`; package generation is offline and must leave the lockfiles intact.
Full optimized DWARF is retained for RPM debuginfo/debugsource and DEB dbgsym.

kafgres embeds a Kafka protocol broker in PostgreSQL, with SQL-managed
topics, partitions and message production. It requires shared_preload_libraries
and a server restart. The default segment engine stores its message log in
separate files and needs its own replication and archive configuration.
The table engine stores the message log in PostgreSQL tables.

The earlier 0.1.0 validation found that EL9's librdkafka 1.6.1 could not query
the logical END offset, while librdkafka 2.15.1 passed offset queries and
read-committed consumption. That result has not been revalidated for 0.3.0.
