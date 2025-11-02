#==============================================================#
# File      :   Makefile
# Desc      :   pgsty/deb repo shortcuts
# Ctime     :   2024-07-28
# Mtime     :   2025-11-02
# Path      :   Makefile
# Author    :   Ruohang Feng (rh@vonng.com)
# License   :   Apache-2.0
#==============================================================#


###############################################################
#                     Rust Extensions                        #
###############################################################

timescaledb_toolkit:
	cd timescaledb_toolkit && make

pg_later:
	cd pg_later && make

pg_polyline:
	cd pg_polyline && make

pg_tzf:
	cd pg_tzf && make

vchord:
	cd vchord && make

pgvectorscale:
	cd pgvectorscale && make

pg_vectorize:
	cd pg_vectorize && make

pg_summarize:
	cd pg_summarize && make

pg_tiktoken:
	cd pg_tiktoken && make

pgml:
	cd pgml && make

pg_search:
	cd pg_search && make

pg_bestmatch:
	cd pg_bestmatch && make

vchord_bm25:
	cd vchord_bm25 && make

pg_tokenizer:
	cd pg_tokenizer && make

pg_mooncake:
	cd pg_mooncake && make

pg_parquet:
	cd pg_parquet && make

pg_graphql:
	cd pg_graphql && make

pg_jsonschema:
	cd pg_jsonschema && make

pg_cardano:
	cd pg_cardano && make

plprql:
	cd plprql && make

pglite_fusion:
	cd pglite_fusion && make

pg_smtp_client:
	cd pg_smtp_client && make

pg_render:
	cd pg_render && make

pg_idkit:
	cd pg_idkit && make

pgx_ulid:
	cd pgx_ulid && make

pg_base58:
	cd pg_base58 && make

pg_convert:
	cd pg_convert && make

pgdd:
	cd pgdd && make

pg_explain_ui:
	cd pg_explain_ui && make

pg_session_jwt:
	cd pg_session_jwt && make

pg_anon:
	cd pg_anon && make

pgsmcrypto:
	cd pgsmcrypto && make

wrappers:
	cd wrappers && make



###############################################################
#            Category: TIME - Time & Schedule                #
###############################################################

timescaledb:
	cd timescaledb && make

pg_timeseries:
	cd pg_timeseries && make

temporal_tables:
	cd temporal_tables && make

emaj:
	cd emaj && make

table_version:
	cd table_version && make

pg_task:
	cd pg_task && make

pg_background:
	cd pg_background && make


###############################################################
#            Category: GIS  - Geospatial                     #
###############################################################

geoip:
	cd geoip && make

pg_geohash:
	cd pg_geohash && make


###############################################################
#            Category: RAG  - RAG & Vector                   #
###############################################################

smlar:
	cd smlar && make

pg4ml:
	cd pg4ml && make


###############################################################
#            Category: FTS  - Full-Text Search               #
###############################################################

pgroonga:
	cd pgroonga && make

pg_bigm:
	cd pg_bigm && make

zhparser:
	cd zhparser && make


###############################################################
#            Category: OLAP - OLAP & Analytics               #
###############################################################

citus:
	cd citus && make

hydra:
	cd hydra && make

pg_duckdb:
	cd pg_duckdb && make

duckdb_fdw:
	cd duckdb_fdw && make

pg_fkpart:
	cd pg_fkpart && make


###############################################################
#            Category: FEAT - Functionality                  #
###############################################################

index_advisor:
	cd index_advisor && make

pg_plan_filter:
	cd pg_plan_filter && make

imgsmlr:
	cd imgsmlr && make

pg_ivm:
	cd pg_ivm && make

pg_incremental:
	cd pg_incremental && make

pgmq:
	cd pgmq && make

omnigres:
	cd omnigres && make


###############################################################
#            Category: LANG - Languages                      #
###############################################################

pg_tle:
	cd pg_tle && make

plv8:
	cd plv8 && make


###############################################################
#            Category: TYPE - Data Types                     #
###############################################################

pgpdf:
	cd pgpdf && make

md5hash:
	cd md5hash && make

pg_country:
	cd pg_country && make

pg_xenophile:
	cd pg_xenophile && make

pg_currency:
	cd pg_currency && make

pgcollection:
	cd pgcollection && make

pguint:
	cd pguint && make

pg_uint128:
	cd pg_uint128 && make

hashtypes:
	cd hashtypes && make

pg_duration:
	cd pg_duration && make

pg_uri:
	cd pg_uri && make

pg_emailaddr:
	cd pg_emailaddr && make

pg_acl:
	cd pg_acl && make

timestamp9:
	cd timestamp9 && make

chkpass:
	cd chkpass && make


###############################################################
#            Category: UTIL - Utilities                      #
###############################################################

pg_gzip:
	cd pg_gzip && make

pg_bzip:
	cd pg_bzip && make

pg_zstd:
	cd pg_zstd && make

pg_net:
	cd pg_net && make

pg_curl:
	cd pg_curl && make

pgjq:
	cd pgjq && make

pgjwt:
	cd pgjwt && make

pg_html5_email_address:
	cd pg_html5_email_address && make

url_encode:
	cd url_encode && make

pgsql_tweaks:
	cd pgsql_tweaks && make

pg_extra_time:
	cd pg_extra_time && make

pgqr:
	cd pgqr && make

pg_protobuf:
	cd pg_protobuf && make

pg_envvar:
	cd pg_envvar && make

floatfile:
	cd floatfile && make

pg_readme:
	cd pg_readme && make

ddl_historization:
	cd ddl_historization && make

data_historization:
	cd data_historization && make

pg_schedoc:
	cd pg_schedoc && make

pg_hashlib:
	cd pg_hashlib && make

pg_xxhash:
	cd pg_xxhash && make

shacrypt:
	cd shacrypt && make

cryptint:
	cd cryptint && make

pg_ecdsa:
	cd pg_ecdsa && make

pgsparql:
	cd pgsparql && make


###############################################################
#            Category: FUNC - Functions                      #
###############################################################

pg_uuidv7:
	cd pg_uuidv7 && make

permuteseq:
	cd permuteseq && make

pg_hashids:
	cd pg_hashids && make

sequential_uuids:
	cd sequential_uuids && make

topn:
	cd topn && make

quantile:
	cd quantile && make

lower_quantile:
	cd lower_quantile && make

count_distinct:
	cd count_distinct && make

omnisketch:
	cd omnisketch && make

ddsketch:
	cd ddsketch && make

vasco:
	cd vasco && make

pgxicor:
	cd pgxicor && make

floatvec:
	cd floatvec && make

aggs_for_vecs:
	cd aggs_for_vecs && make

aggs_for_arrays:
	cd aggs_for_arrays && make

pg_arraymath:
	cd pg_arraymath && make

pg_math:
	cd pg_math && make

pg_random:
	cd pg_random && make

pg_base36:
	cd pg_base36 && make

pg_base62:
	cd pg_base62 && make

pg_financial:
	cd pg_financial && make


###############################################################
#            Category: ADMIN - Administration                 #
###############################################################

pg_rewrite:
	cd pg_rewrite && make

pg_cooldown:
	cd pg_cooldown && make

pg_ddlx:
	cd pg_ddlx && make

pg_readonly:
	cd pg_readonly && make

pg_permissions:
	cd pg_permissions && make

pg_upless:
	cd pg_upless && make

pgcozy:
	cd pgcozy && make

pg_orphaned:
	cd pg_orphaned && make

pg_crash:
	cd pg_crash && make

pg_cheat_funcs:
	cd pg_cheat_funcs && make

pg_fio:
	cd pg_fio && make

pg_savior:
	cd pg_savior && make

safeupdate:
	cd safeupdate && make

pg_drop_events:
	cd pg_drop_events && make


###############################################################
#            Category: STAT - Statistics                     #
###############################################################

pg_profile:
	cd pg_profile && make

pg_tracing:
	cd pg_tracing && make

pg_stat_monitor:
	cd pg_stat_monitor && make

pg_store_plans:
	cd pg_store_plans && make

pgsentinel:
	cd pgsentinel && make

system_stats:
	cd system_stats && make

pg_meta:
	cd pg_meta && make

pgnodemx:
	cd pgnodemx && make

pg_sqlog:
	cd pg_sqlog && make

pgmeminfo:
	cd pgmeminfo && make

pg_relusage:
	cd pg_relusage && make

pagevis:
	cd pagevis && make


###############################################################
#            Category: SEC  - Security                       #
###############################################################

passwordcheck_cracklib:
	cd passwordcheck_cracklib && make

supautils:
	cd supautils && make

pgsodium:
	cd pgsodium && make

pg_vault:
	cd pg_vault && make

pg_tde:
	cd pg_tde && make

pg_auth_mon:
	cd pg_auth_mon && make

pgcryptokey:
	cd pgcryptokey && make

pg_jobmon:
	cd pg_jobmon && make

logerrors:
	cd logerrors && make

login_hook:
	cd login_hook && make

pg_auditor:
	cd pg_auditor && make

sslutils:
	cd sslutils && make

pg_noset:
	cd pg_noset && make


###############################################################
#            Category: FDW  - FDW                            #
###############################################################

pgspider_ext:
	cd pgspider_ext && make

sqlite_fdw:
	cd sqlite_fdw && make

pg_redis_pubsub:
	cd pg_redis_pubsub && make

kafka_fdw:
	cd kafka_fdw && make

firebird_fdw:
	cd firebird_fdw && make

aws_s3:
	cd aws_s3 && make

log_fdw:
	cd log_fdw && make


###############################################################
#            Category: SIM  - Similarity                     #
###############################################################

documentdb:
	cd documentdb && make

pgtt:
	cd pgtt && make

session_variable:
	cd session_variable && make

pg_statement_rollback:
	cd pg_statement_rollback && make

spat:
	cd spat && make


###############################################################
#            Category: ETL  - ETL                            #
###############################################################

pg_failover_slots:
	cd pg_failover_slots && make

db_migrator:
	cd db_migrator && make

pgactive:
	cd pgactive && make

wal2mongo:
	cd wal2mongo && make

decoder_raw:
	cd decoder_raw && make

pg_bulkload:
	cd pg_bulkload && make





###############################################################
#                          Kernel                             #
###############################################################
openhalodb:
	cd openhalodb && make
oriolepg_17:
	cd orioledb-17 && make
orioledb:
	cd orioledb && make


###############################################################
#                        1. Building                          #
###############################################################
# noext install
deps:
	sudo dpkg -i ~/libduckdb_*.deb
	sudo dpkg -i ~/libfq_*.deb
	sudo dpkg -i ~/scws_*.deb


collect:
	mkdir -p /tmp/deb
	cp -r ~/*.deb /tmp/deb/


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
