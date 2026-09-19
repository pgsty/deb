# kafgres 0.1.0

Source: [upstream release](https://codeload.github.com/RayElg/kafgres/tar.gz/refs/tags/0.1.0). The original source and both Cargo.lock
files are unchanged. SHA256: `01076e258605655f279c2506aee6e0e3f40eda3a1ae66a1ab7cabcf438f8bc10`.

PostgreSQL 16 only, matching the upstream release binaries and Docker build.
The upstream feature list also names other majors, but the PG17 build fails
in `decoding.rs` because `ReorderBufferTupleBuf` no longer exists.
Those feature names are not a supported package matrix.

Build with cargo-pgrx 0.16.1 and an installed Rust toolchain. `PGRX_BIN_DIR`
can select an isolated cargo-pgrx installation. The Cargo lockfiles are fetched
with `--locked`; package generation is offline and must leave the lockfiles intact.
Full optimized DWARF is retained for RPM debuginfo/debugsource and DEB dbgsym.

kafgres embeds a Kafka protocol broker in PostgreSQL, with SQL-managed
topics, partitions and message production. It requires shared_preload_libraries
and a server restart. The default segment engine stores its message log in
separate files and needs its own replication and archive configuration.
The table engine stores the message log in PostgreSQL tables.

EL9's packaged librdkafka 1.6.1 cannot query the logical END offset against
this upstream broker. Explicit partition/offset consumption works; modern
librdkafka 2.15.1 passes offset queries and read-committed consumption.
