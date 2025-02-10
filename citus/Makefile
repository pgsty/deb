all: setup build move

TARBALL := citus-13.0.1.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	pg_buildext updatecontrol
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

build: build17 build16 build15 build14

# building deb
build17:
	cd build/ && PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	echo '17' > build/debian/pgversions
	cd build/ && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build16:
	cd build/ && PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	echo '16' > build/debian/pgversions
	cd build/ && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build15:
	cd build/ && PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	echo '15' > build/debian/pgversions
	cd build/ && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build14:
	cd build/ && PATH=/usr/lib/postgresql/14/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	echo '14' > build/debian/pgversions
	cd build/ && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/14/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p /tmp/deb
	cp *.deb /tmp/deb

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls
