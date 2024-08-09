# PGSTY Deb Package Builder

Extensions Building Scripts for PostgreSQL 12 - 16 on Debian / Ubuntu.



--------

## Extension List

**Common Extensions**

| Extension Name                                                    |             | License                                                         | Comment             |
|-------------------------------------------------------------------|-------------|-----------------------------------------------------------------|---------------------|
| [scws](https://github.com/hightman/scws)                          | v1.2.3      | [BSD](https://github.com/hightman/scws/blob/master/COPYING)     | Deps of zhparser    |
| [libduckdb](https://github.com/duckdb/duckdb)                     | v1.0.0      | [MIT](https://github.com/duckdb/duckdb/blob/main/LICENSE)       | Deps of duckdb_fdw  |
| [duckdb_fdw](https://github.com/alitrack/duckdb_fdw)              | v1.0.0      | [MIT](https://github.com/alitrack/duckdb_fdw/blob/main/LICENSE) | Depend on libduckdb |
| [zhparser](https://github.com/amutu/zhparser)                     | v2.2        |                                                                 | Depend on scws      |
| [pgjwt](https://github.com/michelp/pgjwt)                         | v0.2.0      |                                                                 |                     |
| [vault](https://github.com/supabase/vault)                        | v0.2.9      |                                                                 |                     |
| [hydra](https://github.com/hydradatabase/)                        | v1.1.2      |                                                                 |                     |
| [plv8](https://github.com/plv8/plv8)                              | v3.2.2      |                                                                 |                     |
| [supautils](https://github.com/supabase/supautils)                | v2.2.1      |                                                                 |                     |
| [imgsmlr](https://github.com/postgrespro/imgsmlr)                 | v1.0        |                                                                 |                     |
| [pg_tle](https://github.com/aws/pg_tle)                           | v1.4.0      |                                                                 |                     |
| [pg_tde](https://github.com/Percona-Lab/pg_tde/tree/1.0.0-beta)   | v1.0.0-beta |                                                                 |                     |
| [md5hash](https://github.com/tvondra/md5hash)                     | v1.0.1      |                                                                 |                     |
| [hunspell](https://github.com/postgrespro/hunspell_dicts)         | v1.0        |                                                                 |                     |                 
| [pg_sqlog](https://github.com/kouber/pg_sqlog)                    | v1.6        |                                                                 |                     |      
| [pg_proctab](https://gitlab.com/pg_proctab/pg_proctab)            | v0.0.10     |                                                                 |                     |              
| [pg_hashids](https://github.com/iCyberon/pg_hashids)              | v1.3        |                                                                 |                     |            
| [postgres_shacrypt](https://github.com/dverite/postgres-shacrypt) | v1.1        |                                                                 |                     |                         
| [permuteseq](https://github.com/dverite/permuteseq)               | v1.2.2      |                                                                 |                     |

**Rust Extensions**

| Vendor        | Name                                                                       | Version | PGRX                                                                                            | License                                                                     | PG Ver         | Deps          |
|---------------|----------------------------------------------------------------------------|---------|-------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|----------------|---------------|
| PostgresML    | [pgml](https://github.com/postgresml/postgresml)                           | v2.9.2  | [v0.11.3](https://github.com/postgresml/postgresml/blob/master/pgml-extension/Cargo.lock#L1785) | [MIT](https://github.com/postgresml/postgresml/blob/master/MIT-LICENSE.txt) | 16,15,14       |               |
| ParadeDB      | [pg_search](https://github.com/paradedb/paradedb/tree/dev/pg_search)       | v0.8.5  | [v0.11.3](https://github.com/paradedb/paradedb/blob/dev/pg_search/Cargo.toml#L36)               | [AGPLv3](https://github.com/paradedb/paradedb/blob/dev/LICENSE)             | 16,15          |               |
| ParadeDB      | [pg_lakehouse](https://github.com/paradedb/paradedb/tree/dev/pg_lakehouse) | v0.8.5  | [v0.11.3](https://github.com/paradedb/paradedb/blob/dev/pg_lakehouse/Cargo.toml#L26)            | [AGPLv3](https://github.com/paradedb/paradedb/blob/dev/LICENSE)             | 16,15          |               |
| Supabase      | [pg_graphql](https://github.com/supabase/pg_graphql)                       | v1.5.7  | [v0.11.3](https://github.com/supabase/pg_graphql/blob/master/Cargo.toml#L17)                    | [Apache-2.0](https://github.com/supabase/pg_graphql/blob/master/LICENSE)    | 16,15          |               |
| Supabase      | [pg_jsonschema](https://github.com/supabase/pg_jsonschema)                 | v0.3.1  | [v0.11.3](https://github.com/supabase/pg_jsonschema/blob/master/Cargo.toml#L19)                 | [Apache-2.0](https://github.com/supabase/pg_jsonschema/blob/master/LICENSE) | 16,15,14,13,12 |               |
| Supabase      | [wrappers](https://github.com/supabase/wrappers)                           | v0.4.1  | [v0.11.3](https://github.com/supabase/wrappers/blob/main/Cargo.lock#L4254)                      | [Apache-2.0](https://github.com/supabase/wrappers/blob/main/LICENSE)        | 16,15,14       |               |
| Tembo         | [pgmq](https://github.com/tembo-io/pgmq)                                   | v1.2.1  | v0.11.3                                                                                         | [PostgreSQL](https://github.com/tembo-io/pgmq)                              | 16,15,14,13,12 |               |
| Tembo         | [pg_vectorize](https://github.com/tembo-io/pg_vectorize)                   | v0.17.0 | v0.11.3                                                                                         | [PostgreSQL](https://github.com/tembo-io/pg_vectorize/blob/main/LICENSE)    | 16,15,14       | pgmq, pg_cron |
| Tembo         | [pg_later](https://github.com/tembo-io/pg_later)                           | v0.1.1  | v0.11.3                                                                                         | [PostgreSQL](https://github.com/tembo-io/pg_later/blob/main/LICENSE)        | 16,15,14,13    | pgmq          |
| VADOSWARE     | [pg_idkit](https://github.com/VADOSWARE/pg_idkit)                          | v0.2.3  | v0.11.3                                                                                         | [Apache-2.0](https://github.com/VADOSWARE/pg_idkit/blob/main/LICENSE)       | 16,15,14,13,12 |               |
| pgsmcrypto    | [pgsmcrypto](https://github.com/zhuobie/pgsmcrypto)                        | v0.1.0  | v0.11.3                                                                                         | [MIT](https://github.com/zhuobie/pgsmcrypto/blob/main/LICENSE)              | 16,15,14,13,12 |               |
| kelvich       | [pg_tiktoken](https://github.com/kelvich/pg_tiktoken)                      | v0.0.1  | [v0.10.2](https://github.com/kelvich/pg_tiktoken/blob/main/Cargo.toml)                          | [Apache-2.0](https://github.com/kelvich/pg_tiktoken/blob/main/LICENSE)      | 16,15,14,13,12 |               |
| rustprooflabs | [pgdd](https://github.com/rustprooflabs/pgdd)                              | v0.5.2  | [v0.10.2](https://github.com/rustprooflabs/pgdd/blob/main/Cargo.toml#L25)                       | [MIT](https://github.com/zhuobie/pgsmcrypto/blob/main/LICENSE)              | 16,15,14,13,12 |               |
| timescale     | [vectorscale](https://github.com/timescale/pgvectorscale)                  | v0.2.0  | [v0.11.4](https://github.com/timescale/pgvectorscale/blob/main/pgvectorscale/Cargo.toml#L17)    | [PostgreSQL](https://github.com/timescale/pgvectorscale/blob/main/LICENSE)  | 16,15,14,13,12 |               |
| kaspermarstal | [plprql](https://github.com/kaspermarstal/plprql)                          | v0.1.0  | [v0.11.4](https://github.com/kaspermarstal/plprql/blob/main/Cargo.toml#L21)                     | [Apache-2.0](https://github.com/kaspermarstal/plprql/blob/main/LICENSE)     | 16,15,14,13,12 |               |

--------

## Done

- ADMIN pg_orphaned https://github.com/bdrouvot/pg_orphaned PostgreSQL C 1.0
- ADMIN pgcozy https://github.com/vventirozos/pgcozy/tree/master/sql/functions SQL PostgreSQL 1.0 (no so)
- ETL decoder_raw: https://github.com/michaelpq/pg_plugins/blob/main/decoder_raw/decoder_raw.c C PostgreSQL 1.0 (no ddl)
- ETL pg_failover_slot: https://github.com/EnterpriseDB/pg_failover_slots load C 1.0.1 Postgres?
- FDW log-fdw https://github.com/aws/postgresql-logfdw C Apache 2.0 1.4 (14,15,16)
- FDW redis-fdw https://github.com/pg-redis-fdw/redis_fdw PostgreSQL C
- FEAT index_advisor https://github.com/supabase/index_advisor PostgreSQL (supabase) 0.2.0 SQL
- FEAT pg_financial https://github.com/intgr/pg_financial  C PostgreSQL 1.0.1
- FEAT pg_savior https://github.com/viggy28/pg_savior Apache C (13,14,15,16)
- FUNC aggs_for_vecs https://github.com/pjungwir/aggs_for_vecs (12,13,14,15)
- FUNC base36 https://github.com/adjust/pg-base36 MIT 1.0.0 C
- FUNC base62  https://github.com/adjust/pg-base62 MIT 0.0.1 C
- FUNC envvar https://github.com/theory/pg-envvar C 1.0.0 PostgreSQL
- FUNC pg_html5_email_address https://github.com/bigsmoke/pg_html5_email_address PostgreSQL SQL 1.2.3
- FUNC quantile https://github.com/tvondra/quantile BSD C  1.1.7
- FUNC lower_quantile https://github.com/tvondra/lower_quantile BSD-2 C (12-15) 1.0.0 
- FUNC random https://github.com/tvondra/random PostgreSQL 2.0.0-dev
- FUNC pg_timeit https://github.com/joelonsql/pg-timeit PostgreSQL C  1.0
- RAG smlar https://github.com/jirutka/smlar PostgreSQL? C 1.0 (13-15)
- SEC sslutils https://github.com/EnterpriseDB/sslutils PostgreSQL C 1.3 (12-15)
- STAT pg_mon https://github.com/RafiaSabih/pg_mon C  MIT 1.0 (12-15)
- TYPE chkpass https://github.com/lacanoid/chkpass C PostgreSQL 1.0
- TYPE currency https://github.com/adjust/pg-currency MIT C 0.0.3
- TYPE pgemailaddr https://github.com/petere/pgemailaddr C PostgreSQL 0 (12-15)
- TYPE pguri https://github.com/petere/pguri PostgreSQL C (12-15) 1.20151224
- SIM session_variable: https://github.com/splendiddata/session_variable C GPL-3.0 3.3
- FUNC cryptint https://github.com/dverite/cryptint C  1.0.0 PostgreSQL
- FUNC floatvec https://github.com/pjungwir/floatvec C 1.0.1 MIT
- SEC pg_auditor https://github.com/kouber/pg_auditor PureSQL 0.2 BSD-3
- SEC noset https://gitlab.com/ongresinc/extensions/noset 0.3.0 C AGPLv3 (LOAD)


--------

## TODOLIST

Not Planned
 
- [pg_tier](https://github.com/tembo-io/pg_tier): not ready due to incomplete dep parquet_s3_fdw
- [parquet_s3_fdw](https://github.com/pgspider/parquet_s3_fdw): not ready due to compiler version
- pg_top: not ready due to cmake error
- timestamp9: not ready due to compiler error
- pg_tier obsolete
- pg_timeseries, we already have timescaledb 
- pg_quack, we already have a pg_lakehouse
- pg_telemetry, we already have better observability
- pgx_ulid, https://github.com/pksunkara/pgx_ulid, already covered by pg_idkit (MIT, but RUST)
- embedding: obsolete
- FEAT zson https://github.com/postgrespro/zson MIT C (too old)
- GIS pghydro https://github.com/pghydro/pghydro C GPL-2.0 6.6 (no makefile)
- https://github.com/Zeleo/pg_natural_sort_order (too old)



--------

## Signature

All Deb Packages are signed with GPG key `9592A7BC7A682E7333376E09E7935D8DB9BD8B20` (`B9BD8B20` [Public key](KEYS))


--------

## License

License: [AGPLv3](LICENSE)
