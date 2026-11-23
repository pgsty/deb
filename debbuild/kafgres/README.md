# kafgres 0.3.3

The official `kafgres-0.3.3.tar.gz` archive has SHA-256
`1bea83c83d26dfbebbef93c78625cb2e45675b8877a41a57170e8567ba53361d`.
[Upstream release](https://github.com/RayElg/kafgres/releases/tag/0.3.3)

Build PostgreSQL 15–19 with Rust 1.100.0 and cargo-pgrx 0.20.1. Run
`pig build get kafgres` in the builder, then `make` in `~/debbuild/kafgres`.
`PGRX_BIN_DIR` selects an isolated cargo-pgrx installation. The shared patches
update the extension's pgrx dependencies and lockfile, and adapt logical
decoding, wait sets and segment I/O to PG19. The recipe fetches locked
dependencies, compiles offline and checks the lockfiles after packaging.
The optimized build supplies full DWARF for the debug packages.

kafgres embeds a Kafka protocol broker in PostgreSQL, with SQL-managed
topics, partitions and message production. It requires shared_preload_libraries
and a server restart. The default segment engine stores its message log in
separate files and needs its own replication and archive configuration.
The table engine stores the message log in PostgreSQL tables.

The earlier 0.1.0 validation found that EL9's librdkafka 1.6.1 could not query
the logical END offset, while librdkafka 2.15.1 passed offset queries and
read-committed consumption. The 0.3.3 pilot used a
Kafka client to write a message and read it back after a server restart.
