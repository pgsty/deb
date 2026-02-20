all: setup build move

TARBALL := babelfishpg-17.8-5.5.0.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	cp -a build/postgresql_modified_for_babelfish/. build/
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

# building deb
build:
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building artifacts
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

