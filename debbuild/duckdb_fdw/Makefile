all: setup build move

TARBALL := duckdb_fdw-git20251102-870bc43.tar.gz
PG_DUCKDB_TARBALL := pg_duckdb-1.1.1.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build build/duckdb-headers
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	tar -C build/duckdb-headers --strip-components=5 -xf ../SOURCES/$(PG_DUCKDB_TARBALL) \
		pg_duckdb-1.1.1/third_party/duckdb/src/include/duckdb.h \
		pg_duckdb-1.1.1/third_party/duckdb/src/include/duckdb.hpp \
		pg_duckdb-1.1.1/third_party/duckdb/src/include/duckdb
	test -f build/duckdb-headers/duckdb.h
	test -f build/duckdb-headers/duckdb.hpp
	pg_buildext updatecontrol
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

# building deb
build:
	cd build && pg_buildext updatecontrol
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls
