all: setup build move

TARBALL := pg_geohash-1.0.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	mv build/pg_geohash-1.0.sql build/pg_geohash--1.0.sql
	sed -i 's/pg_geohash-1.0.sql/pg_geohash--1.0.sql/' build/Makefile
	sed -i -e '/^PGXS :=/i PG_CONFIG ?= pg_config' -e 's/pg_config --pgxs/$$(PG_CONFIG) --pgxs/' build/Makefile
	pg_buildext updatecontrol
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog

# building deb
build:
	cd build && pg_buildext updatecontrol
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} ~/ext/pkg/ \;

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls
