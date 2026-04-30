all: pre setup build move

TARBALL := documentdb-0.110-0.tar.gz
SOURCE_TARBALL ?= $(or $(wildcard $(HOME)/ext/src/$(TARBALL)),$(wildcard $(HOME)/pgsty/repo/ext/src/$(TARBALL)),$(wildcard ../SOURCES/$(TARBALL)))

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing $(TARBALL) under $(HOME)/ext/src, $(HOME)/pgsty/repo/ext/src, or ../SOURCES; run pig build get first if needed"; exit 1)

pre:
	bash prepare.sh $(TARBALL)
	apt-get update -qq
	apt install -y systemtap-sdt-dev

# prepare directory
setup: check-src
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf "$(SOURCE_TARBALL)"
	sed -i 's/char \*substring = memchr(/const char *substring = memchr(/' build/pg_documentdb_core/src/types/string_view.c
	sed -i "s/char \\*dotPosition = strchr(currentNameSpace, '\\.');/const char *dotPosition = strchr(currentNameSpace, '.');/" build/pg_documentdb/src/aggregation/bson_aggregation_output_pipeline.c
	sed -i "s/char \\*leftSubstring = memchr(path, '\\.', pathLength);/const char *leftSubstring = memchr(path, '.', pathLength);/" build/pg_documentdb/src/aggregation/bson_project.c
	sed -i "s/char \\*arrayIndexSubstring = memchr(path, '\\.', pathLength);/const char *arrayIndexSubstring = memchr(path, '.', pathLength);/" build/pg_documentdb/src/aggregation/bson_project.c
	sed -i 's/DateFormatMap \*result = bsearch(/const DateFormatMap *result = bsearch(/' build/pg_documentdb/src/operators/bson_expression_date_operators.c
	sed -i 's/TimezoneMap \*result = bsearch(/const TimezoneMap *result = bsearch(/' build/pg_documentdb/src/operators/bson_expression_date_operators.c
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	if [ "$${OS_CODENAME}" = "resolute" ]; then \
		sed -i 's/char \*dot = NULL;/const char *dot = NULL;/' build/pg_documentdb/src/sharding/sharding.c; \
	fi
	pg_buildext updatecontrol
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
	chown -R $(shell whoami):$(shell whoami) build/

# building deb
build: build18 build17 build16 build15

build18: setup
	echo '18' > build/debian/pgversions
	sed -i 's/, postgresql-PGVERSION-rum//g' build/debian/control.in
	cd build/ && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/18/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build17: setup
	echo '17' > build/debian/pgversions
	cd build/ && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build16: setup
	echo '16' > build/debian/pgversions
	cd build/ && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build15: setup
	echo '15' > build/debian/pgversions
	cd build/ && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc


# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src pre setup update build move clean
