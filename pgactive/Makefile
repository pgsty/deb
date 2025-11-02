all: setup build move

TARBALL := pgactive-2.1.7.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	pg_buildext updatecontrol
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

# building deb
build: build18 build17 build16 build15 build14 build13
build18:
	sed -i "1s/17/18/g" build/debian/rules
	echo "18" > build/debian/pgversions
	cd build && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/18/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	cd build/ && make clean
	cd build/ && PATH=/usr/lib/postgresql/18/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build17:
	sed -i "1s/17/17/g" build/debian/rules
	echo "17" > build/debian/pgversions
	cd build && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	cd build/ && make clean
	cd build/ && PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build16:
	sed -i "1s/17/16/g" build/debian/rules
	echo "16" > build/debian/pgversions
	cd build && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	cd build/ && make clean
	cd build/ && PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build15:
	sed -i "1s/17/15/g" build/debian/rules
	echo "15" > build/debian/pgversions
	cd build && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	cd build/ && make clean
	cd build/ && PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build14:
	sed -i "1s/17/14/g" build/debian/rules
	echo "14" > build/debian/pgversions
	cd build && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/14/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	cd build/ && make clean
	cd build/ && PATH=/usr/lib/postgresql/14/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build13:
	sed -i "1s/17/13/g" build/debian/rules
	echo "13" > build/debian/pgversions
	cd build && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/13/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	cd build/ && make clean
	cd build/ && PATH=/usr/lib/postgresql/13/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc


# collect deb
move:
	mkdir -p /tmp/deb && cp *.deb /tmp/deb/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls
