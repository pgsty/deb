all: setup build move

TARBALL := hydra-1.1.2.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	pg_buildext updatecontrol
	rm -rf build/columnar/debian; cp -r debian build/columnar/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/columnar/debian/changelog

build: build16 build15 build14 build13

# building deb
build16:
	cd build/columnar/ && PATH=/usr/lib/postgresql/16/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	echo '16' > build/columnar/debian/pgversions
	cd build/columnar/ && pg_buildext updatecontrol
	cd build/columnar/ && PATH=/usr/lib/postgresql/16/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build15:
	cd build/columnar/ && PATH=/usr/lib/postgresql/15/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	echo '15' > build/columnar/debian/pgversions
	cd build/columnar/ && pg_buildext updatecontrol
	cd build/columnar/ && PATH=/usr/lib/postgresql/15/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build14:
	cd build/columnar/ && PATH=/usr/lib/postgresql/14/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	echo '14' > build/columnar/debian/pgversions
	cd build/columnar/ && pg_buildext updatecontrol
	cd build/columnar/ && PATH=/usr/lib/postgresql/14/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build13:
	cd build/columnar/ && PATH=/usr/lib/postgresql/13/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	echo '13' > build/columnar/debian/pgversions
	cd build/columnar/ && pg_buildext updatecontrol
	cd build/columnar/ && PATH=/usr/lib/postgresql/13/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

# collect deb
move:
	cp build/*.deb ~/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls
