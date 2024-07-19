#---------------------------------------------#
# build
#---------------------------------------------#
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
pg_net:
	cd pg-net && make
pgjwt:
	cd pgjwt && make
gzip:
	cd pgsql-gzip && make

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

.PHONY: push pull pulld build build-on-sv push9 pull9 build9 build-sv build-on-el9 clean sync pub release