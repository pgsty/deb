all: setup build move

TARBALL := pg_mooncake-0.1.2.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	cd build && git submodule update --init --recursive
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

# building deb
build: build17 build16 build15

# building deb
build17:
	echo '17' > build/debian/pgversions
	cd build/ && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/17/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin BUILD_TYPE=release dpkg-buildpackage -b -us -uc

build16:
	echo '16' > build/debian/pgversions
	cd build/ && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/16/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin BUILD_TYPE=release dpkg-buildpackage -b -us -uc

build15:
	echo '15' > build/debian/pgversions
	cd build/ && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/15/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin BUILD_TYPE=release dpkg-buildpackage -b -us -uc

build14:
	echo '14' > build/debian/pgversions
	cd build/ && pg_buildext updatecontrol
	cd build/ && PATH=/usr/lib/postgresql/14/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin BUILD_TYPE=release dpkg-buildpackage -b -us -uc



# collect deb
move:
	cp *.deb /tmp/deb/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls