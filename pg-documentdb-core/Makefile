all: setup build move

TARBALL := documentdb-0.100-0.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	pg_buildext updatecontrol
	rm -rf build/pg_documentdb_core/debian; cp -r debian build/pg_documentdb_core/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/pg_documentdb_core/debian/changelog

build: build17 build16 build15

# building deb
build17:
	echo '17' > build/pg_documentdb_core/debian/pgversions
	cd build/pg_documentdb_core/ && pg_buildext updatecontrol
	cd build/pg_documentdb_core/ && PATH=/usr/lib/postgresql/17/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build16:
	echo '16' > build/pg_documentdb_core/debian/pgversions
	cd build/pg_documentdb_core/ && pg_buildext updatecontrol
	cd build/pg_documentdb_core/ && PATH=/usr/lib/postgresql/16/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build15:
	echo '15' > build/pg_documentdb_core/debian/pgversions
	cd build/pg_documentdb_core/ && pg_buildext updatecontrol
	cd build/pg_documentdb_core/ && PATH=/usr/lib/postgresql/15/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc


# collect deb
move:
	mkdir -p /tmp/deb/
	cp build/*.deb /tmp/deb/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls
