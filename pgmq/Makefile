all: setup build move

TARBALL := pgmq-1.5.1.tar.gz

# prepare directory
setup:
	rm -rf build build2; mkdir -p build build2
	tar -C build2 --strip-components=1 -xf ../tarball/$(TARBALL)
	cp -r build2/pgmq-extension/* build/
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
	mkdir -p /tmp/deb && cp *.deb /tmp/deb/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls