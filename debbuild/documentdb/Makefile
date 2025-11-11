all: pre setup build move

TARBALL := documentdb-0.107.0-ferretdb-2.7.0.tar.gz

pre:
	bash prepare.sh $(TARBALL)
	apt install -y systemtap-sdt-dev

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	pg_buildext updatecontrol
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
	chown -R $(shell whoami):$(shell whoami) build/

# building deb
build: build17 build16 build15

# not working on ferretdb fork yet (works on microsoft documentdb fork)
build18: setup
	echo '18' > build/debian/pgversions
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

.PHONY: all pre setup update build move clean