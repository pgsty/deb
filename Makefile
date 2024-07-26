#---------------------------------------------#
# build
#---------------------------------------------#
pgml:
	cd pgml && make
pg_graphql:
	cd pg-graphql && make
pg_jsonschema:
	cd pg-jsonschema && make
wrappers:
	cd wrappers && make
pg_search:
	cd pg-search && make
pg_lakehouse:
	cd pg-lakehouse && make
pgvectorscale:
	cd pgvectorscale && make
plprql:
	cd plprql && make
pg_idkit:
	cd pg-idkit && make
pgsmcrypto:
	cd pgsmcrypto && make
pgmq:
	cd pgmq && make
pg_tier:
	cd pg-tier && make
pg_vectorize:
	cd pg-vectorize && make
pg_later:
	cd pg-later && make
pgdd:
	cd pgdd && make
pg_tiktoken:
	cd pg-tiktoken && make

rust: pgml pg_graphql pg_jsonschema wrappers pg_search pg_lakehouse pgvectorscale plprql pg_idkit pgsmcrypto pgdd pg_tiktoken pgmq pg_tier pg_vectorize pg_later
norm1: pg_net pgjwt gzip vault pgsodium supautils hydra pg_tle permuteseq postgres_shacrypt pg_hashids pg_proctab pg_sqlog md5hash pg_tde hunspell
norm2: scws libduckdb
norm3: zhparser duckdb_fdw
norm4: plv8

pg_net:
	cd pg-net && make
pgjwt:
	cd pgjwt && make
gzip:
	cd pgsql-gzip && make
vault:
	cd vault && make
pgsodium:
	cd pgsodium && make
supautils:
	cd supautils && make
hydra:
	cd hydra && make
pg_tle:
	cd pg-tle && make
plv8:
	cd plv8 && make
permuteseq:
	cd permuteseq && make
postgres_shacrypt:
	cd postgres-shacrypt && make
pg_hashids:
	cd pg-hashids && make
pg_proctab:
	cd pg-proctab && make
pg_sqlog:
	cd pg-sqlog && make
md5hash:
	cd md5hash && make
pg_tde:
	cd pg-tde && make
hunspell:
	cd hunspell && make
scws:
	cd scws && make
zhparser:
	cd zhparser && make
libduckdb:
	cd libduckdb && make
duckdb_fdw:
	cd duckdb-fdw && make
imgsmlr:
	cd imgsmlr && make
#libarrow-s3:
#	cd libarrow-s3 && make
#parquet-s3-fdw:
#	cd parquet-s3-fdw && make

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

clean-all:
	rm -rf ~/*.ddeb ~/*.deb ~/*.buildinfo ~/*.changes
	rm -rf ~/paradedb/*.deb ~/paradedb/*.ddeb ~/paradedb/*.buildinfo ~/paradedb/*.changes
	rm -rf ~/pg_vectorize/*.deb ~/pg_vectorize/*.ddeb ~/pg_vectorize/*.buildinfo ~/pg_vectorize/*.changes
	rm -rf ~/postgresml/*.deb ~/postgresml/*.ddeb ~/postgresml/*.buildinfo ~/postgresml/*.changes
	rm -rf ~/pgsql-gzip/*.deb ~/pgsql-gzip/*.ddeb ~/pgsql-gzip/*.buildinfo ~/pgsql-gzip/*.changes
	rm -rf ~/pg-net/*.deb ~/pg-net/*.ddeb ~/pg-net/*.buildinfo ~/pg-net/*.changes
	rm -rf ~/pgjwt/*.deb ~/pgjwt/*.ddeb ~/pgjwt/*.buildinfo ~/pgjwt/*.changes
	rm -rf ~/pgvectorscale/*.deb ~/pgvectorscale/*.ddeb ~/pgvectorscale/*.buildinfo ~/pgvectorscale/*.changes

collect:
	mkdir -p /tmp/deb
	rm -rf /tmp/deb/*
	cp -r ~/*.deb /tmp/deb/

#---------------------------------------------#
# sync to/from building server
#---------------------------------------------#
push-sv:
	rsync -avc --exclude deb ./ sv:/data/pigsty-deb/
pushd-sv:
	rsync -avc --exclude deb --delete ./ sv:/data/pigsty-deb/
pull-sv:
	rsync -avc sv:/data/pigsty-deb/deb/ ./deb/
pulld-sv:
	rsync --delete -avc sv:/data/pigsty-deb/deb/ ./deb/
update: push-sv repo-sv pull-sv
updated: pushd-sv repo-sv pulld-sv
pushsd: pushd-sv
	ssh sv 'cd /data/pigsty-deb && make pushd'
pushss: push-sv
	ssh sv 'cd /data/pigsty-deb && make push'

#---------------------------------------------#
# push to building machines
#---------------------------------------------#
push:
	rsync -avc --exclude deb ./ u22:~/pigsty-deb/
	rsync -avc --exclude deb ./ d12:~/pigsty-deb/
pushd:
	rsync -avc --exclude deb --delete ./ u22:~/pigsty-deb/
	rsync -avc --exclude deb --delete ./ d12:~/pigsty-deb/

#---------------------------------------------#
# pull rpm from building machines
#---------------------------------------------#
pull: dirs pull22 pull12
purge:
	rm -rf deb/*
dirs:
	mkdir -p deb/jammy.amd64 deb/bookworm.amd64
pull22:
	rsync -avz u22:/tmp/deb/ deb/jammy.amd64/
pull12:
	rsync -avz d12:/tmp/deb/ deb/bookworm.amd64/

#---------------------------------------------#
# publish
#---------------------------------------------#
sync: release
pub: release
release: clean
	coscmd upload --recursive -s -f -y --delete --ignore .idea . yum

.PHONY: push pull pulld build build-on-sv push9 pull9 build9 build-sv build-on-el9 clean sync pub release clean-all collect \
	pgml pg-graphql pg-jsonschema wrappers pg-search pg-lakehouse pgvectorscale plprql pg_idkit pgsmcrypto pgdd pg_tiktoken pgmq pg_tier pg_vectorize pg_later \
	pg_net pgjwt gzip vault pgsodium supautils hydra pg_tle plv8 permuteseq postgres_shacrypt pg_hashids pg_proctab pg_sqlog md5hash pg_tde imgsmlr pg_bigm \
	hunspell scws zhparser libduckdb duckdb_fdw pg_ivm pg_uuidv7 sqlite_fdw wal2mongo