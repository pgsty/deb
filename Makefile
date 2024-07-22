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
pgdd:
	cd pgdd && make
pgmq:
	cd pgmq && make
pg_tier:
	cd pg-tier && make
pg_vectorize:
	cd pg-vectorize && make
pg_later:
	cd pg-later && make
rust: pgml pg_graphql pg_jsonschema wrappers pg_search pg_lakehouse pgvectorscale plprql pg_idkit pgsmcrypto pgdd pgmq pg_tier pg_vectorize pg_later


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
	rsync -avc ./ sv:/data/pigsty-deb/
pushd-sv:
	rsync -avc --delete ./ sv:/data/pigsty-deb/
repo-sv:
	ssh sv 'cd /data/pigsty-deb && make create'
pull-sv:
	rsync -avc sv:/data/pigsty-deb/RPMS/ ./RPMS/
pulld-sv:
	rsync --delete -avc sv:/data/pigsty-deb/RPMS/ ./RPMS/
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
	rsync -avc ./ u22:~/pigsty-deb/
	rsync -avc ./ d12:~/pigsty-deb/
pushd:
	rsync -avc --delete ./ u22:~/pigsty-deb/
	rsync -avc --delete ./ d12:~/pigsty-deb/

#---------------------------------------------#
# pull rpm from building machines
#---------------------------------------------#
pull: dirs pull8 pull9 adjust create
purge:
	rm -rf RPMS/*
dirs:
	mkdir -p RPMS/el7.x86_64/debug RPMS/el8.x86_64/debug RPMS/el9.x86_64/debug
pull7:
	rsync -avz build-el7:~/rpmbuild/RPMS/x86_64/ RPMS/el7.x86_64/
pull8:
	rsync -avz build-el8:~/rpmbuild/RPMS/x86_64/ RPMS/el8.x86_64/
pull9:
	rsync -avz build-el9:~/rpmbuild/RPMS/x86_64/ RPMS/el9.x86_64/
adjust:
	chown -R root:root RPMS
	#mv -f RPMS/el7.x86_64/*-debug* RPMS/el7.x86_64/debug/
	mv -f RPMS/el8.x86_64/*-debug* RPMS/el8.x86_64/debug/
	mv -f RPMS/el9.x86_64/*-debug* RPMS/el9.x86_64/debug/
create:
	cd RPMS/el7.x86_64/ && createrepo_c .;
	cd RPMS/el8.x86_64/ && createrepo_c . && repo2module -s stable . modules.yaml && modifyrepo_c --mdtype=modules modules.yaml repodata/;
	cd RPMS/el9.x86_64/ && createrepo_c . && repo2module -s stable . modules.yaml && modifyrepo_c --mdtype=modules modules.yaml repodata/;
	cd RPMS/el7.x86_64/debug && createrepo_c .;
	cd RPMS/el8.x86_64/debug && createrepo_c . && repo2module -s stable . modules.yaml && modifyrepo_c --mdtype=modules modules.yaml repodata/;
	cd RPMS/el9.x86_64/debug && createrepo_c . && repo2module -s stable . modules.yaml && modifyrepo_c --mdtype=modules modules.yaml repodata/;
rmds:
	find . -type f -name .DS_Store -delete

#---------------------------------------------#
# publish
#---------------------------------------------#
sync: release
pub: release
release: clean
	coscmd upload --recursive -s -f -y --delete --ignore .idea . yum

.PHONY: push pull pulld build build-on-sv push9 pull9 build9 build-sv build-on-el9 clean sync pub release \
	pgml pg-graphql pg-jsonschema wrappers pg-search pg-lakehouse pgvectorscale plprql pg_idkit pgsmcrypto pgdd pgmq pg_tier pg_vectorize pg_later \
	pg_net pgjwt gzip vault pgsodium clean-all collect