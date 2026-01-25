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
#                      1. Environment                         #
###############################################################
setup:
	@echo "curl https://repo.pigsty.cc/pig | bash -s 0.7.0"
	@echo "pig build spec"
	@echo "pig build repo"
	@echo "pig build tool"
	@echo "pig build rust"
	@echo "pig build pgrx"
	@echo "#pig build pkg <name...>"

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
pull-new: pull-clean pull-init
pull-init:
	mkdir -p apt/bookworm apt/trixie apt/jammy apt/noble
pull-clean:
	rm -rf   apt/bookworm apt/trixie apt/jammy apt/noble

pull: pull12 pull13 pull22 pull24 pull12a pull13a pull22a pull24a

pullx: pull12 pull13 pull22 pull24
pulla: pull12a pull13a pull22a pull24a

pullm:
	rsync -avc meta:~/ext/pkg/  apt/meta/

pull12:
	rsync -avc d12:~/ext/pkg/  apt/bookworm/
pull13:
	rsync -avc d13:~/ext/pkg/  apt/trixie/
pull22:
	rsync -avc u22:~/ext/pkg/  apt/jammy/
pull24:
	rsync -avc u24:~/ext/pkg/  apt/noble/
pull12a:
	rsync -avc d12a:~/ext/pkg/  apt/bookworm/
pull13a:
	rsync -avc d13a:~/ext/pkg/  apt/trixie/
pull22a:
	rsync -avc u22a:~/ext/pkg/  apt/jammy/
pull24a:
	rsync -avc u24a:~/ext/pkg/  apt/noble/

pullj:
	rsync -avc j2:~/ext/pkg/ apt/trixie/

upload:
	bin/upload.sh


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
#                      Push SPEC to Remote                    #
###############################################################
spec: spec12 spec13 spec22 spec24 spec12a spec13a spec22a spec24a
specm:
	rsync -az debbuild/ meta:~/debbuild/

spec12:
	rsync -az debbuild/ d12:~/debbuild/
spec13:
	rsync -az debbuild/ d13:~/debbuild/
spec22:
	rsync -az debbuild/ u22:~/debbuild/
spec24:
	rsync -az debbuild/ u24:~/debbuild/

spec12a:
	rsync -az debbuild/ d12a:~/debbuild/
spec13a:
	rsync -az debbuild/ d13a:~/debbuild/
spec22a:
	rsync -az debbuild/ u22a:~/debbuild/
spec24a:
	rsync -az debbuild/ u24a:~/debbuild/


###############################################################
#                      Push SRC to Remote                     #
###############################################################
# Update remote source tarball
src: src12 src22 src24 src12a src22a src24a
srcm:
	rsync -avz src/ meta:~/ext/src/
src12:
	rsync -avz src/ d12:~/ext/src/
src13:
	rsync -avz src/ d13:~/ext/src/
src22:
	rsync -avz src/ u22:~/ext/src/
src24:
	rsync -avz src/ u24:~/ext/src/

src12a:
	rsync -avz src/ d12a:~/ext/src/
src22a:
	rsync -avz src/ u22a:~/ext/src/
src24a:
	rsync -avz src/ u24a:~/ext/src/

j: specj srcj
srcj:
	rsync -avz src/ j2:~/ext/src/
specj:
	rsync -az debbuild/ j2:~/debbuild/


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
 	pg_graphql pg_jsonschema wrappers pg_idkit pgsmcrypto pg_tiktoken pg_summarize pg_polyline pg_tzf pg_explain_ui pg_cardano pg_base58 pg_parquet pg_vectorize pgvectorscale timescaledb_toolkit pg_session_jwt pgml plprql pg_later pg_anon pg_smtp_client vchord pg_bestmatch pglite_fusion age18 \
 	pgdd convert pg_tokenizer pg_render pgx_ulid \
 	pg_net pgjwt pg_gzip pg_bzip vault pgsodium supautils pg_tle plv8 omnigres permuteseq postgres_shacrypt pg_hashids pg_sqlog md5hash pg_tde hunspell  zhparser duckdb_fdw pg_duckdb pg_mooncake hydra citus timescaledb pgroonga \
 	pg_timeseries pgmq pg_plan_filter pg_relusage pg_uint128 \
 	imgsmlr pg_bigm pg_ivm pg_uuidv7 sqlite_fdw wal2mongo pg_readonly pguint pg_permissions ddlx pg_safeupdate pg_stat_monitor passwordcheck_cracklib pg_profile pg_store_plan system_stats \
 	pg_fkpart pgmeminfo postgresql_anonymizer pgcryptokey pg_background count_distinct pg_extra_time pgsql_tweaks pgtt temporal_tables emaj table_version pg_statement_rollback \
 	pg_auth_mon login_hook logerrors pg_jobmon geoip timestamp9 \
 	pg_orphaned pgcozy decoder_raw pg_failover_slot log_fdw redis_fdw index_advisor pg_financial pg_savior aggs_for_vecs base36 base62 pg_envvar pg_html5_email_address pg_timeit quantile lower_quantile sequential_uuids ddsketch omnisketch pg_random \
 	smlar sslutils pg_mon chkpass pg_currency pg_emailaddr pg_uri cryptint floatvec floatfile pg_auditor noset \
 	aggs_for_arrays pgqr pg_zstd url_encode pg_geohash pg_meta pg_redis_pubsub pg_arraymath pagevis pg_ecdsa pg_cheat_funcs acl pg_crash pg_math firebird_fdw  kafka_fdw pgnodemx pg_hashlib pg_protobuf pg_country pg_fio aws_s3 \
 	scws libfq libduckdb pgcopydb pg_bulkload libfq pg4ml pgpdf topn pg_upless pg_task pg_readme vasco pg_xxhash pg_duration ddl_historization data_historization pg_schedoc pg_xenophile pg_incremental pg_drop_envents \
 	documentdb pg_tracing pg_curl pgxicor pgsparql pgjq hashtypes db_migrator pg_cooldown pgcollection pgspider_ext pgsentinel spat pgactive openhalodb oriolepg_17 orioledb \
 	push-sv pushd-sv pull-sv pulld-sv ps pd pushsd pushss push pushd push12 push22 push24 pushd12 pushd22 pushd24 pull purge dirs pull22 pull12 sync pub release
