#---------------------------------------------#
# build
#---------------------------------------------#
noext: scws libduckdb pgcopydb libfq
ext: zhparser duckdb_fdw firebird_fdw
big: pg_duckdb plv8 hydra

plv8:
	cd plv8 && make
pg_duckdb:
	cd pg-duckdb && make
pg_mooncake:
	cd pg-mooncake && make
hydra:
	cd hydra && make
citus:
	cd citus && make
timescaledb:
	cd timescaledb && make
pgroonga:
	cd pgroonga && make
omnigres:
	cd omnigres && make

# noext install
deps:
	sudo dpkg -i ~/libduckdb_*.deb
	sudo dpkg -i ~/libfq_*.deb
	sudo dpkg -i ~/scws_*.deb

batch1: pg_net pgjwt pgmq pg_timeseries pg_plan_filter pg_relusage pg_uint128 pg_gzip vault pgsodium supautils
batch2: pg_tle permuteseq postgres_shacrypt pg_hashids pg_sqlog md5hash pg_tde hunspell zhparser duckdb_fdw
batch3: imgsmlr pg_bigm pg_ivm pg_uuidv7 sqlite_fdw wal2mongo pg_readonly pguint pg_permissions postgresql_anonymizer ddlx
batch4: pg_safeupdate pg_stat_monitor passwordcheck_cracklib pg_profile system_stats pg_fkpart pgmeminfo pg_store_plan
batch5: pgcryptokey pg_background count_distinct pg_extra_time pgsql_tweaks pgtt temporal_tables emaj table_version pg_statement_rollback
batch6: pg_orphaned pgcozy decoder_raw pg_failover_slots log_fdw redis_fdw index_advisor pg_financial pg_savior base36 base62
batch7: pg_envvar pg_html5_email_address lower_quantile quantile ddsketch omnisketch sequential_uuids random session_variable smlar sslutils chkpass pg_currency
batch8: aggs_for_vecs aggs_for_arrays pgqr pg_zstd url_encode pg_meta pg_redis_pubsub pg_arraymath pagevis pg_ecdsa pg_cheat_funcs acl pg_crash
batch9: pg_emailaddr pg_uri cryptint floatvec floatfile pg_auditor noset pg_math kafka_fdw pgnodemx pg_hashlib pg_protobuf pg_country pg_fio aws_s3 pg_geohash pg4ml timestamp9
batch0: pg_bulkload chkpass geoip pg_jobmon logerrors login_hook pg_auth_mon pgpdf topn pg_upless pg_task pg_readme vasco pg_xxhash pg_duration ddl_historization data_historization pg_schedoc #pg_mon pg_timeit

collect:
	mkdir -p /tmp/deb
	cp -r ~/*.deb /tmp/deb/

#---------------------------------------------#
# rust & pgrx extensions
#---------------------------------------------#
rust1: pg_graphql pg_jsonschema wrappers pg_idkit pgsmcrypto pg_tiktoken pg_summarize pg_polyline pg_explain_ui pg_cardano pg_base58 pg_parquet pg_vectorize pgvectorscale vchord pglite_fusion pg_bestmatch pg_later pg_smtp_client timescaledb_toolkit
rust2: pgml plprql

rusta: pg_graphql pg_jsonschema wrappers pg_idkit pg_later
rustb: pgsmcrypto pg_tiktoken pg_summarize pg_polyline pg_explain_ui
rustc: pg_cardano pg_base58 pg_parquet pg_vectorize pgvectorscale
rustd: pg_session_jwt pg_smtp_client vchord pglite_fusion pg_bestmatch

# pgrx 0.12.9
pg_graphql:
	cd pg-graphql && make
pg_jsonschema:
	cd pg-jsonschema && make
wrappers:
	cd wrappers && make
pg_idkit:
	cd pg-idkit && make
pg_later:
	cd pg-later && make
pg_anon:
	cd pg-anon && make

pgsmcrypto:
	cd pgsmcrypto && make
pg_tiktoken:
	cd pg-tiktoken && make
pg_summarize:
	cd pg-summarize && make
pg_polyline:
	cd pg-polyline && make
pg_tzf:
	cd pg-tzf && make
pg_explain_ui:
	cd pg-explain-ui && make

pg_cardano:
	cd pg-cardano && make
pg_base58:
	cd pg-base58 && make
pg_parquet:
	cd pg-parquet && make
pg_vectorize:
	cd pg-vectorize && make
pgvectorscale:
	cd pgvectorscale && make
timescaledb_toolkit:
	cd timescaledb-toolkit && make

pg_session_jwt:
	cd pg-session-jwt && make
pg_smtp_client:
	cd pg-smtp-client && make
vchord:
	cd vchord && make
vchord_bm25:
	cd vchord-bm25 && make
pglite_fusion:
	cd pglite-fusion && make
pg_bestmatch:
	cd pg-bestmatch && make
pgml:
	cd pgml && make

# pgrx 0.11.x
plprql:
	cd plprql && make

pgdd:
	cd pgdd && make
convert:
	cd convert && make
pg_tokenizer:
	cd pg-tokenizer && make
pg_render:
	cd pg-render && make
pgx_ulid:
	cd pgx-ulid && make


rust-clean:
	rm -rf ~/*.ddeb ~/*.deb ~/*.buildinfo ~/*.changes
	rm -rf ~/paradedb/*.deb ~/paradedb/*.ddeb ~/paradedb/*.buildinfo ~/paradedb/*.changes
	rm -rf ~/pg_vectorize/*.deb ~/pg_vectorize/*.ddeb ~/pg_vectorize/*.buildinfo ~/pg_vectorize/*.changes
	rm -rf ~/postgresml/*.deb ~/postgresml/*.ddeb ~/postgresml/*.buildinfo ~/postgresml/*.changes
	rm -rf ~/pgsql-gzip/*.deb ~/pgsql-gzip/*.ddeb ~/pgsql-gzip/*.buildinfo ~/pgsql-gzip/*.changes
	rm -rf ~/pg-net/*.deb ~/pg-net/*.ddeb ~/pg-net/*.buildinfo ~/pg-net/*.changes
	rm -rf ~/pgjwt/*.deb ~/pgjwt/*.ddeb ~/pgjwt/*.buildinfo ~/pgjwt/*.changes
	rm -rf ~/pgvectorscale/*.deb ~/pgvectorscale/*.ddeb ~/pgvectorscale/*.buildinfo ~/pgvectorscale/*.changes

#---------------------------------------------#
# common c/c++ extensions
#---------------------------------------------#
pg_net:
	cd pg-net && make
pgjwt:
	cd pgjwt && make
pgmq:
	cd pgmq && make
pg_timeseries:
	cd pg-timeseries && make
timestamp9:
	cd timestamp9 && make
pg_plan_filter:
	cd pg-plan-filter && make
pg_relusage:
	cd pg-relusage && make
pg_uint128:
	cd pg-uint128 && make
pg_gzip:
	cd pgsql-gzip && make
pg_bzip:
	cd pg-bzip && make
vault:
	cd vault && make
pgsodium:
	cd pgsodium && make
supautils:
	cd supautils && make

# depend on flex
pg_tle:
	cd pg-tle && make
permuteseq:
	cd permuteseq && make
postgres_shacrypt:
	cd postgres-shacrypt && make
pg_hashids:
	cd pg-hashids && make
pg_sqlog:
	cd pg-sqlog && make
md5hash:
	cd md5hash && make
pg_tde:
	cd pg-tde && make
hunspell:
	cd hunspell && make
zhparser:
	cd zhparser && make
duckdb_fdw:
	cd duckdb-fdw && make



imgsmlr:
	cd imgsmlr && make
pg_bigm:
	cd pg-bigm && make
pg_ivm:
	cd pg-ivm && make
pg_uuidv7:
	cd pg-uuidv7 && make
sqlite_fdw:
	cd sqlite-fdw && make
wal2mongo:
	cd wal2mongo && make
pg_readonly:
	cd pg-readonly && make
pguint:
	cd pguint && make
pg_permissions:
	cd pg-permissions && make
ddlx:
	cd ddlx && make
postgresql_anonymizer:
	cd postgresql-anonymizer && make
pg_safeupdate:
	cd pg-safeupdate && make
pg_stat_monitor:
	cd pg-stat-monitor && make
passwordcheck_cracklib:
	cd passwordcheck-cracklib && make
pg_profile:
	cd pg-profile && make
system_stats:
	cd system-stats && make
pg_fkpart:
	cd pg-fkpart && make
pgmeminfo:
	cd pgmeminfo && make
pg_store_plan:
	cd pg-store-plan && make

pgcryptokey:
	cd pgcryptokey && make
pg_background:
	cd pg-background && make
count_distinct:
	cd count-distinct && make
pg_extra_time:
	cd pg-extra-time && make
pgsql_tweaks:
	cd pgsql-tweaks && make
pgtt:
	cd pgtt && make
temporal_tables:
	cd temporal-tables && make
emaj:
	cd emaj && make
table_version:
	cd table-version && make
pg_statement_rollback:
	cd pg-statement-rollback && make
pg_auth_mon:
	cd pg-auth-mon && make
login_hook:
	cd login-hook && make
logerrors:
	cd logerrors && make
pg_jobmon:
	cd pg-jobmon && make
geoip:
	cd geoip && make

scws:
	cd scws && make
libduckdb:
	cd libduckdb && make
pgcopydb:
	cd pgcopydb && make
pg_bulkload:
	cd pg-bulkload && make
libfq:
	cd libfq && make

pg_orphaned:
	cd pg-orphaned && make
pgcozy:
	cd pgcozy && make
decoder_raw:
	cd decoder-raw && make
pg_failover_slots:
	cd pg-failover-slots && make
log_fdw:
	cd log-fdw && make
redis_fdw:
	cd redis-fdw17 && make
	cd redis-fdw16 && make
	cd redis-fdw15 && make
	cd redis-fdw14 && make
	cd redis-fdw13 && make
	cd redis-fdw12 && make
index_advisor:
	cd index-advisor && make
pg_financial:
	cd pg-financial && make
pg_savior:
	cd pg-savior && make
aggs_for_vecs:
	cd aggs-for-vecs && make
base36:
	cd base36 && make
base62:
	cd base62 && make
pg_envvar:
	cd pg-envvar && make
pg_html5_email_address:
	cd pg-html5-email-address && make

lower_quantile:
	cd lower-quantile && make
quantile:
	cd quantile && make
sequential_uuids:
	cd sequential-uuids && make
ddsketch:
	cd ddsketch && make
omnisketch:
	cd omnisketch && make

pg_random:
	cd pg-random && make
session_variable:
	cd session-variable && make
smlar:
	cd smlar && make
sslutils:
	cd sslutils && make

chkpass:
	cd chkpass && make
pg_currency:
	cd pg-currency && make
pg_emailaddr:
	cd pg-emailaddr && make
pg_uri:
	cd pg-uri && make
cryptint:
	cd cryptint && make
floatvec:
	cd floatvec && make
floatfile:
	cd floatfile && make
pg_auditor:
	cd pg-auditor && make
noset:
	cd noset && make


aggs_for_arrays:
	cd aggs-for-arrays && make
pgqr:
	cd pgqr && make
pg_zstd:
	cd pg-zstd && make
url_encode:
	cd url-encode && make
pg_geohash:
	cd pg-geohash && make
pg_meta:
	cd pg-meta && make
pg_redis_pubsub:
	cd pg-redis-pubsub && make
pg_arraymath:
	cd pg-arraymath && make
pagevis:
	cd pagevis && make
pg_ecdsa:
	cd pg-ecdsa && make
pg_cheat_funcs:
	cd pg-cheat-funcs && make
acl:
	cd acl && make
pg_crash:
	cd pg-crash && make
pg_math:
	cd pg-math && make
firebird_fdw:
	cd firebird-fdw && make

kafka_fdw:
	cd kafka-fdw && make
pgnodemx:
	cd pgnodemx && make
pg_hashlib:
	cd pg-hashlib && make
pg_protobuf:
	cd pg-protobuf && make
pg_country:
	cd pg-country && make
pg_fio:
	cd pg-fio && make
aws_s3:
	cd aws-s3 && make
pg4ml:
	cd pg4ml && USE_PGXS=1 make
pgpdf:
	cd pgpdf && make
pg_mon:
	cd pg-mon && make
pg_timeit:
	cd pg-timeit && make
topn:
	cd topn && make

pg_upless:
	cd pg-upless && make
pg_task:
	cd pg-task && make
pg_readme:
	cd pg-readme && make
vasco:
	cd vasco && make
pg_xxhash:
	cd pg-xxhash && make
pg_duration:
	cd pg-duration && make
ddl_historization:
	cd ddl-historization && make
data_historization:
	cd data-historization && make
pg_schedoc:
	cd pg-schedoc && make
pg_xenophile:
	cd pg-xenophile && make
pg_incremental:
	cd pg-incremental && make
pg_drop_events:
	cd pg-drop-events && make

documentdb:
	cd documentdb && make
pg_tracing:
	cd pg-tracing && make
pg_curl:
	cd pg-curl && make
pgxicor:
	cd pgxicor && make
pgsparql:
	cd pgsparql && make
pgjq:
	cd pgjq && make
hashtypes:
	cd hashtypes && make
db_migrator:
	cd db-migrator && make
pg_cooldown:
	cd pg-cooldown && make
pgcollection:
	cd pgcollection && make
pgspider_ext:
	cd pgspider-ext && make
pgsentinel:
	cd pgsentinel && make
spat:
	cd spat && make
pgactive:
	cd pgactive && make

openhalodb:
	cd openhalodb && make
oriolepg_17:
	cd orioledb-17 && make
orioledb:
	cd orioledb && make

###############################################################
#                        1. Building                          #
###############################################################

#---------------------------------------------#
# sync to/from building server
#---------------------------------------------#
push-sv:
	rsync -avc --exclude deb  --exclude tf --exclude tmp ./ sv:/data/deb/
pushd-sv:
	rsync -avc --exclude deb  --exclude tf --exclude tmp --delete ./ sv:/data/deb/
pull-sv:
	rsync -avc sv:/data/deb/ ./deb/
pulld-sv:
	rsync --delete -avc sv:/data/deb/deb/ ./deb/

ps: pushss
pd: pushsd
pushsd: pushd-sv
	ssh sv 'cd /data/deb && make pushd'
pushss: push-sv
	ssh sv 'cd /data/deb && make push'

pl: pull-ss
pull-ss:
	ssh -t sv "cd /data/deb && make pull"
	rsync -avc sv:/data/deb/deb/ deb/
pull-deb:
	rsync -avc sv:/data/deb/deb/ deb/

#---------------------------------------------#
# push to building machines
#---------------------------------------------#
push:
	rsync -avc --exclude deb  --exclude tf --exclude tmp ./ u22:~/deb/
	rsync -avc --exclude deb  --exclude tf --exclude tmp ./ d12:~/deb/
	rsync -avc --exclude deb  --exclude tf --exclude tmp ./ u24:~/deb/
pushd:
	rsync -avc --exclude deb  --exclude tf --exclude tmp --delete ./ d12:~/deb/
	rsync -avc --exclude deb  --exclude tf --exclude tmp --delete ./ u22:~/deb/
	rsync -avc --exclude deb  --exclude tf --exclude tmp --delete ./ u24:~/deb/
push12:
	rsync -avc --exclude deb  --exclude tf --exclude tmp  ./ d12:~/deb/
push22:
	rsync -avc --exclude deb  --exclude tf --exclude tmp ./ u22:~/deb/
push24:
	rsync -avc --exclude deb  --exclude tf --exclude tmp ./ u24:~/deb/
pushd12:
	rsync -avc --exclude deb  --exclude tf --exclude tmp --delete ./ d12:~/deb/
pushd22:
	rsync -avc --exclude deb  --exclude tf --exclude tmp --delete ./ u22:~/deb/
pushd24:
	rsync -avc --exclude deb  --exclude tf --exclude tmp --delete ./ u24:~/deb/
push12a:
	rsync -avc --exclude deb  --exclude tf --exclude tmp ./ d12a:~/deb/
push22a:
	rsync -avc --exclude deb  --exclude tf --exclude tmp ./ u22a:~/deb/
push24a:
	rsync -avc --exclude deb  --exclude tf --exclude tmp ./ u24a:~/deb/
pushm:
	rsync -avc --exclude deb  --exclude tf --exclude tmp ./ meta:~/deb/

#---------------------------------------------#
# pull rpm from building machines
#---------------------------------------------#
init:
	mkdir -p deb deb/{bookworm.amd64,jammy.amd64,noble.amd64}
	mkdir -p deb deb/{bookworm.arm64,jammy.arm64,noble.arm64}
pull:  init pull22 pull12 pull24
pulla: init pull22a pull12a pull24a

dirs:
	mkdir -p deb/jammy.amd64 deb/bookworm.amd64
pull24:
	rsync -avz u24:/tmp/deb/ deb/noble.amd64/
pull22:
	rsync -avz u22:/tmp/deb/ deb/jammy.amd64/
pull12:
	rsync -avz d12:/tmp/deb/ deb/bookworm.amd64/
pull24a:
	rsync -avz u24a:/tmp/deb/ deb/noble.arm64/
pull22a:
	rsync -avz u22a:/tmp/deb/ deb/jammy.arm64/
pull12a:
	rsync -avz d12a:/tmp/deb/ deb/bookworm.arm64/


#---------------------------------------------#
# publish
#---------------------------------------------#
sync: release
pub: release
release: clean
	coscmd upload --recursive -s -f -y --delete --ignore .idea . yum
gen:
	cd deb && ./summary.py

###############################################################
#                         Terraform                           #
###############################################################
u:
	cd tf && terraform apply -auto-approve
	sleep 5
	tf/ssh
	sleep 15
	tf/ssh
a:
	cd tf && terraform apply
d:
	cd tf && terraform destroy -auto-approve
destroy:
	cd tf && terraform destroy
out:
	cd tf && terraform output
ssh:
	tf/ssh
r:
	git restore tf/terraform.tf


.PHONY: rust deps batch1 batch2 deb-collect \
 	pg_graphql pg_jsonschema wrappers pg_idkit pgsmcrypto pg_tiktoken pg_summarize pg_polyline pg_tzf pg_explain_ui pg_cardano pg_base58 pg_parquet pg_vectorize pgvectorscale timescaledb_toolkit pg_session_jwt pgml plprql pg_later pg_anon pg_smtp_client vchord pg_bestmatch pglite_fusion \
 	pgdd convert pg_tokenizer pg_render pgx_ulid \
 	pg_net pgjwt pg_gzip pg_bzip vault pgsodium supautils pg_tle plv8 omnigres permuteseq postgres_shacrypt pg_hashids pg_sqlog md5hash pg_tde hunspell  zhparser duckdb_fdw pg_duckdb pg_mooncake hydra citus timescaledb pgroonga \
 	pg_timeseries pgmq pg_plan_filter pg_relusage pg_uint128 \
 	imgsmlr pg_bigm pg_ivm pg_uuidv7 sqlite_fdw wal2mongo pg_readonly pguint pg_permissions ddlx pg_safeupdate pg_stat_monitor passwordcheck_cracklib pg_profile pg_store_plan system_stats \
 	pg_fkpart pgmeminfo postgresql_anonymizer pgcryptokey pg_background count_distinct pg_extra_time pgsql_tweaks pgtt temporal_tables emaj table_version pg_statement_rollback \
 	pg_auth_mon login_hook logerrors pg_jobmon geoip timestamp9 \
 	pg_orphaned pgcozy decoder_raw pg_failover_slot log_fdw redis_fdw index_advisor pg_financial pg_savior aggs_for_vecs base36 base62 pg_envvar pg_html5_email_address pg_timeit quantile lower_quantile sequential_uuids ddsketch omnisketch pg_random \
 	smlar sslutils pg_mon chkpass pg_currency pg_emailaddr pg_uri cryptint floatvec floatfile pg_auditor noset \
 	aggs_for_arrays pgqr pg_zstd url_encode pg_geohash pg_meta pg_redis_pubsub pg_arraymath pagevis pg_ecdsa pg_cheat_funcs acl pg_crash pg_math firebird_fdw  kafka_fdw pgnodemx pg_hashlib pg_protobuf pg_country pg_fio aws_s3 \
 	scws libduckdb pgcopydb pg_bulkload libfq pg4ml pgpdf topn pg_upless pg_task pg_readme vasco pg_xxhash pg_duration ddl_historization data_historization pg_schedoc pg_xenophile pg_incremental pg_drop_envents \
 	documentdb pg_tracing pg_curl pgxicor pgsparql pgjq hashtypes db_migrator pg_cooldown pgcollection pgspider_ext pgsentinel spat pgactive openhalodb oriolepg_17 orioledb \
 	push-sv pushd-sv pull-sv pulld-sv ps pd pushsd pushss push pushd push12 push22 push24 pushd12 pushd22 pushd24 pull purge dirs pull22 pull12 sync pub release
