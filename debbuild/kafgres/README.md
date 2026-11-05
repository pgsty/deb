# kafgres 0.3.2

Source: [upstream tag](https://github.com/RayElg/kafgres/releases/tag/0.3.2).
The official source archive is unchanged, with SHA-256
`13ad7ad97ede1023af21a957f373755e59f471a0306b9ae46bc45d9a4a109c69`.

PGSTY retains its PostgreSQL 16 package target. Other PostgreSQL majors need
separate build and runtime validation before expanding the package matrix.

Build with cargo-pgrx 0.19.3 and an installed Rust toolchain. `PGRX_BIN_DIR`
can select an isolated cargo-pgrx installation. The shared RPM/DEB patch
`kafgres-0.3.2-pgrx-0.19.3.patch` updates the extension's pgrx dependency
and lockfile from 0.16.1 to 0.19.3, removes its obsolete PG13 feature, and
adapts the new `Utf8Text` SQL mapping to pgrx's const metadata interface.
It preserves upstream's UTF-8/server-encoding conversion and SQL `text` type.
The root codec workspace and lockfile remain unchanged. Both lockfiles are
checked before and after packaging; fetch is locked and compilation is offline.
Full optimized DWARF is retained for RPM debuginfo/debugsource and DEB dbgsym.

kafgres embeds a Kafka protocol broker in PostgreSQL, with SQL-managed
topics, partitions and message production. It requires shared_preload_libraries
and a server restart. The default segment engine stores its message log in
separate files and needs its own replication and archive configuration.
The table engine stores the message log in PostgreSQL tables.

The earlier 0.1.0 validation found that EL9's librdkafka 1.6.1 could not query
the logical END offset, while librdkafka 2.15.1 passed offset queries and
read-committed consumption. That external Kafka-client coverage has not been
revalidated for 0.3.2.
