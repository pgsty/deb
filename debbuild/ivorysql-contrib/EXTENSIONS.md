# IvorySQL 5.6 contrib source bundle

The RPM and DEB recipes build the extension payload missing from PGSTY's
IvorySQL 5.6 kernel, using `/usr/ivory-18/bin/pg_config` (PostgreSQL 18).

The official 5.6 release assets `IvorySQL-5.6-74c405c-20261016.aarch64.rpm`
and `IvorySQL-5.6-74c405c-20261016.arm64.deb` contain identical 105 control
files. The PGSTY 5.6 kernel owns 66 of these. The contrib gap is **39 control
files, representing 38 creatable extensions, and 39 top-level modules**.
`pg_proctab--0.0.10-compat.control` is a secondary control file; its placeholder
`pg_proctab.control` has no default version. Use the upstream explicit version
`0.0.10-compat` when checking that compatibility extension.

The 5.6 bundle contains 31 source projects. New projects are pg_bulkload,
pg_profile, pg_readonly, pg_repack, pgnodemx, pgtt, set_user and pgvectorscale.
The official payload contains vectorscale 0.9.1 but no pg_ai_query control or
module, despite the release-note list. PgBouncer, pgBackRest and PgDog remain
independent tools. The bundled pg_bulkload and pg_repack clients belong to
their extension projects and are included below the IvorySQL prefix.

PGroonga advances from 4.0.4 to the official 4.0.9, and pgvector from 0.8.4
to 0.8.7. Existing PostGIS 3.5.4, pgRouting 3.8.0 and plpgsql_check 2.8 ABI
(source 2.8.11) remain unchanged. Existing newer component choices such as
pg_partman 5.4.2 and pg_textsearch 1.2.0 are retained. System GIS libraries
remain distribution dependencies. Only EL9 uses this batch's repaired
Groonga 16.1.4 packages; other platforms retain their existing provider.

All SQL files come from the selected upstream source archives. Packaging
does not generate missing extension upgrades or database migration scripts.
The historical official-5.4 data-directory parity script is not a 5.6 build
requirement. Clean-install smoke tests cover all 38 extensions and the
wal2json output plugin, including the new vectorscale index and pgtt table.

pgvectorscale reuses the existing PGSTY 0.9.1 source archive and its pgrx
0.19.2 compatibility changes. Its Cargo.lock SHA256 is
`a8d26a2e48dd483bf16187b63bb9f55aac0aaa9e3d670518ffed01be038f1eb0`.
Builds require cargo-pgrx 0.19.2, fetch with `--locked`, build offline, verify
an unchanged lockfile, and retain Rust DWARF (`DEBUG=2`, `STRIP=none`).

## Source inputs

The unchanged 5.4 inputs retain their previous hashes. New inputs reuse the
canonical source archive cache; pg_repack and set_user retain their existing
Percona archive names and unmodified source contents. pgtt 4.5 was fetched
from `https://github.com/darold/pgtt/archive/refs/tags/v4.5.tar.gz` via the
configured proxy. `SOURCES.sha256` and `sources.json` record every exact input.

| Source archive | Source root |
|---|---|
| `age-1.7.0-pg18.tar.gz` | `age-1.7.0-pg18` |
| `ivy_jieba-d0ffac8.tar.gz` | `ivy_jieba-d0ffac8` |
| `percona-pg_repack-1.5.3.tar.gz` | `percona-pg_repack-1.5.3` |
| `percona-pgaudit18_set_user-4.2.0.tar.gz` | `percona-pgaudit18_set_user-4.2.0` |
| `pg_bigm-1.2-20250903.tar.gz` | `pg_bigm-1.2-20250903` |
| `pg_bulkload-VERSION3_1_23.tar.gz` | `pg_bulkload-VERSION3_1_23` |
| `pg_cron-1.6.7.tar.gz` | `pg_cron-1.6.7` |
| `pg_curl-2.4.5.tar.gz` | `pg_curl-2.4.5` |
| `pg_hint_plan-REL18_1_8_0.tar.gz` | `pg_hint_plan-REL18_1_8_0` |
| `pg_partman-5.4.2.tar.gz` | `pg_partman-5.4.2` |
| `pg_profile-4.11.tar.gz` | `pg_profile-4.11` |
| `pg_readonly-1.0.6.tar.gz` | `pg_readonly-1.0.6` |
| `pg_show_plans-2.1.8.tar.gz` | `pg_show_plans-2.1.8` |
| `pg_stat_monitor-2.3.2.tar.gz` | `pg_stat_monitor-2.3.2` |
| `pg_textsearch-1.2.0.tar.gz` | `pg_textsearch-1.2.0` |
| `pgagent-4.2.3.tar.gz` | `pgagent-pgagent-4.2.3` |
| `pgaudit-18.0.tar.gz` | `pgaudit-18.0` |
| `pgddl-0.31.tar.gz` | `pgddl-0.31` |
| `pgnodemx-1.7.tar.gz` | `pgnodemx-1.7` |
| `pgroonga-4.0.9.tar.gz` | `pgroonga-4.0.9` |
| `pgrouting-3.8.0.tar.gz` | `pgrouting-3.8.0` |
| `pgsql-http-1.7.1.tar.gz` | `pgsql-http-1.7.1` |
| `pgtt-4.5.tar.gz` | `pgtt-4.5` |
| `pgvector-0.8.7.tar.gz` | `pgvector-0.8.7` |
| `pgvectorscale-0.9.1.tar.gz` | `pgvectorscale-0.9.1` |
| `plpgsql_check-2.8.11.tar.gz` | `plpgsql_check-2.8.11` |
| `postgis-3.5.4.tar.gz` | `postgis-3.5.4` |
| `redis_fdw-20a4c07.tar.gz` | `redis_fdw-20a4c07` |
| `system_stats-4.0.tar.gz` | `system_stats-4.0` |
| `wal2json-2.6.tar.gz` | `wal2json-wal2json_2_6` |
| `zhparser-2.3.tar.gz` | `zhparser-2.3` |

## Official payload evidence

Release: https://github.com/IvorySQL/IvorySQL/releases/tag/IvorySQL_5.6

- Official ARM RPM SHA256: `71dd2ef8203d0bede0c699d8b4fd06d8f05f0d5fa6ac87f81ca55d4ec74c2399`.
- Official ARM DEB SHA256: `ee01bcb1524cc3bb0ede8bad3b00182182544dfc9aff26e6e8590a2fd9210435`.

`expected-controls.txt` and `expected-modules.txt` pin the exact name sets.
Build and runtime results are recorded per platform outside the recipe; this
source manifest alone does not assert that any production build passed.
