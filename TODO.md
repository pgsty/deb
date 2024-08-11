# TODOLIST

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
- FUNC aggs_for_vecs https://github.com/pjungwir/aggs_for_vecs (12,13,14,15) 1.3.0 C MIT
- FUNC base36 https://github.com/adjust/pg-base36 MIT 1.0.0 C
- FUNC base62  https://github.com/adjust/pg-base62 MIT 0.0.1 C
- FUNC envvar https://github.com/theory/pg-envvar C 1.0.0 PostgreSQL
- FUNC pg_html5_email_address https://github.com/bigsmoke/pg_html5_email_address PostgreSQL SQL 1.2.3
- FUNC quantile https://github.com/tvondra/quantile BSD C  1.1.7 (12-15)
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
- pg_math https://github.com/chanukyasds/pg_math
- pgqr https://github.com/Fenoman/pgqr
- zstd https://github.com/grahamedgecombe/pgzstd
- aggs_for_arrays https://github.com/pjungwir/aggs_for_arrays
- url_encode https://github.com/okbob/url_encode
- pg_geohash https://github.com/jistok/pg_geohash
- meta https://github.com/aquameta/meta
- pg_redis_pubsub https://github.com/brettlaforge/pg_redis_pubsub
- array_math https://github.com/pramsey/pgsql-arraymath
- pagevis https://github.com/hollobon/pagevis
- ecdsa https://github.com/ameensol/pg-ecdsa
- pg_cheat_funcs https://github.com/MasaoFujii/pg_cheat_funcs
- pg_crash https://github.com/cybertec-postgresql/pg_crash



--------

## Not Planned

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
- https://github.com/postgrespro/pg_query_state
- https://github.com/no0p/pgsampler
- pg_lz4 https://github.com/zilder/pg_lz4
- pg_amqp https://github.com/omniti-labs/pg_amqp
- tinyint https://github.com/umitanuki/tinyint-postgresql
- pg_blkchain https://github.com/blkchain/pg_blkchain
- hashtypes https://github.com/pandrewhk/hashtypes
- foreign_table_exposer https://github.com/komamitsu/foreign_table_exposer
- ldap_fdw https://github.com/guedes/ldap_fdw
- pg_backtrace https://github.com/postgrespro/pg_backtrace
- connection_limits https://github.com/tvondra/connection_limits
- fixeddecimal https://github.com/2ndQuadrant/fixeddecimal


--------

## **TODO**

- firebird_fdw https://github.com/ibarwick/firebird_fdw
  - libfq https://github.com/ibarwick/libfq/blob/master/INSTALL.md 
- kafka_fdw https://github.com/adjust/kafka_fdw
- pgnodemx: https://github.com/CrunchyData/pgnodemx
- AWS S3 https://github.com/chimpler/postgres-aws-s3
- fuzzywuzzy https://github.com/hooopo/pg-fuzzywuzzy
- pghashlib https://github.com/markokr/pghashlib
- pg_protobuf https://github.com/afiskon/pg_protobuf
- pgsql-fio: https://github.com/csimsek/pgsql-fio
- fixeddecimal https://github.com/2ndQuadrant/fixeddecimal
- pg_country https://github.com/adjust/pg-country
- sequential_uuids https://github.com/tvondra/sequential-uuids


--------

## Considering

- is_jsonb_valid https://github.com/furstenheim/is_jsonb_valid
- pg_kafka https://github.com/xstevens/pg_kafka
- pg_jieba https://github.com/jaiminpan/pg_jieba
- pg_paxos https://github.com/microsoft/pg_paxos
- OneSparse https://github.com/OneSparse/OneSparse
- PipelineDB https://github.com/pipelinedb/pipelinedb
- SQL Firewall https://github.com/uptimejp/sql_firewall
- zcurve https://github.com/bmuratshin/zcurve
- PG dot net https://github.com/Brick-Abode/pldotnet/releases
- pg_scws: https://github.com/jaiminpan/pg_scws
- themsis: https://github.com/cossacklabs/pg_themis
- pgspeck https://github.com/johto/pgspeck
- lsm3 https://github.com/postgrespro/lsm3
- monq https://github.com/postgrespro/monq
- pg_badplan https://github.com/trustly/pg_badplan
- pg_recall https://github.com/mreithub/pg_recall
- pgfsm https://github.com/michelp/pgfsm
- pg_trgm pro https://github.com/postgrespro/pg_trgm_pro
