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
| [pg_hashids](https://github.com/iCyberon/pg_hashids)              | v1.3        |                                                                 |                     |            
| [postgres_shacrypt](https://github.com/dverite/postgres-shacrypt) | v1.1        |                                                                 |                     |                         
| [permuteseq](https://github.com/dverite/permuteseq)               | v1.2.2      |                                                                 |                     |

**Rust Extensions**

| Vendor        | Name                                                       | Version | PGRX                                                                                            | License                                                                     | PG Ver            | Deps          |
|---------------|------------------------------------------------------------|---------|-------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|-------------------|---------------|
| Supabase      | [pg_graphql](https://github.com/supabase/pg_graphql)       | v1.5.9  | [v0.12.5](https://github.com/supabase/pg_graphql/blob/master/Cargo.toml#L17)                    | [Apache-2.0](https://github.com/supabase/pg_graphql/blob/master/LICENSE)    | 17,16,15          |               |
| Supabase      | [pg_jsonschema](https://github.com/supabase/pg_jsonschema) | v0.3.2  | [v0.12.5](https://github.com/supabase/pg_jsonschema/blob/master/Cargo.toml#L19)                 | [Apache-2.0](https://github.com/supabase/pg_jsonschema/blob/master/LICENSE) | 17,16,15,14,13,12 |               |
| Supabase      | [wrappers](https://github.com/supabase/wrappers)           | v0.4.2  | [v0.11.3](https://github.com/supabase/wrappers/blob/main/Cargo.lock#L4254)                      | [Apache-2.0](https://github.com/supabase/wrappers/blob/main/LICENSE)        | 16,15,14          |               |
| TimescaleDB   | [vectorscale](https://github.com/timescale/pgvectorscale)  | v0.3.0  | [v0.12.5](https://github.com/timescale/pgvectorscale/blob/main/pgvectorscale/Cargo.toml#L17)    | [PostgreSQL](https://github.com/timescale/pgvectorscale/blob/main/LICENSE)  | 17,16,15,14,13,12 |               |
| kelvich       | [pg_tiktoken](https://github.com/Vonng/pg_tiktoken)        | v0.0.1  | [v0.12.5](https://github.com/Vonng/pg_tiktoken/blob/main/Cargo.toml)                            | [Apache-2.0](https://github.com/kelvich/pg_tiktoken/blob/main/LICENSE)      | 16,15,14,13,12    |               |
| PostgresML    | [pgml](https://github.com/postgresml/postgresml)           | v2.9.3  | [v0.11.3](https://github.com/postgresml/postgresml/blob/master/pgml-extension/Cargo.lock#L1785) | [MIT](https://github.com/postgresml/postgresml/blob/master/MIT-LICENSE.txt) | 16,15,14          |               |
| Tembo         | [pg_vectorize](https://github.com/tembo-io/pg_vectorize)   | v0.17.0 | [v0.11.3](https://github.com/tembo-io/pg_vectorize/blob/main/extension/Cargo.toml#L24)          | [PostgreSQL](https://github.com/tembo-io/pg_vectorize/blob/main/LICENSE)    | 16,15,14          | pgmq, pg_cron |
| Tembo         | [pg_later](https://github.com/tembo-io/pg_later)           | v0.1.1  | [v0.11.3](https://github.com/tembo-io/pg_later/blob/main/Cargo.toml#L23)                        | [PostgreSQL](https://github.com/tembo-io/pg_later/blob/main/LICENSE)        | 16,15,14,13       | pgmq          |
| kaspermarstal | [plprql](https://github.com/kaspermarstal/plprql)          | v0.1.0  | [v0.11.3](https://github.com/kaspermarstal/plprql/blob/main/Cargo.toml#L21)                     | [Apache-2.0](https://github.com/kaspermarstal/plprql/blob/main/LICENSE)     | 16,15,14,13,12    |               |
| VADOSWARE     | [pg_idkit](https://github.com/VADOSWARE/pg_idkit)          | v0.2.3  | v0.12.5                                                                                         | [Apache-2.0](https://github.com/VADOSWARE/pg_idkit/blob/main/LICENSE)       | 17,16,15,14,13,12 |               |
| pgsmcrypto    | [pgsmcrypto](https://github.com/Vonng/pgsmcrypto)          | v0.1.0  | v0.12.5                                                                                         | [MIT](https://github.com/zhuobie/pgsmcrypto/blob/main/LICENSE)              | 17,16,15,14,13,12 |               |
| rustprooflabs | [pgdd](https://github.com/rustprooflabs/pgdd)              | v0.5.2  | [v0.10.2](https://github.com/rustprooflabs/pgdd/blob/main/Cargo.toml#L25)                       | [MIT](https://github.com/zhuobie/pgsmcrypto/blob/main/LICENSE)              | 16,15,14,13,12    |               |

ParadeDB's `pg_search`, `pg_lakehouse`, `pg_analytics` are now maintained by [ParadeDB](https://paradedb.com/) themselves.

--------

## Make Spec

```bash
rust: pg_search pg_lakehouse pgml pg_graphql pg_jsonschema wrappers pgvectorscale plprql pg_idkit pgsmcrypto pgdd pg_tiktoken pgmq pg_tier pg_vectorize pg_later
noext: scws libduckdb pgcopydb
batch1: pg_net pgjwt gzip vault pgsodium supautils hydra pg_tle permuteseq postgres_shacrypt pg_hashids pg_sqlog md5hash pg_tde hunspell #plv8 zhparser duckdb_fdw
batch2: imgsmlr pg_bigm pg_ivm pg_uuidv7 sqlite_fdw wal2mongo pg_readonly pguint pg_permissions ddlx pg_safeupdate pg_stat_monitor passwordcheck_cracklib pg_profile pg_store_plan system_stats pg_fkpart pgmeminfo
batch3: pg_orphaned pgcozy decoder_raw pg_failover_slots log_fdw redis_fdw index_advisor pg_financial pg_savior aggs_for_vecs base36 base62 pg_envvar pg_html5_email_address lower_quantile pg_timeit quantile random session_variable smlar sslutils pg_mon chkpass pg_currency pg_emailaddr pg_uri cryptint floatvec pg_auditor noset
batch4: aggs_for_arrays pgqr pg_zstd url_encode pg_meta pg_redis_pubsub pg_arraymath pagevis pg_ecdsa pg_cheat_funcs acl pg_crash pg_math sequential_uuids kafka_fdw pgnodemx pg_hashlib pg_protobuf pg_country pg_fio aws_s3 # firebird_fdw #pg_geohash
```

--------

## Signature

All Deb Packages are signed with GPG key `9592A7BC7A682E7333376E09E7935D8DB9BD8B20` (`B9BD8B20` [Public key](KEYS))


--------

## License

License: [AGPLv3](LICENSE)
