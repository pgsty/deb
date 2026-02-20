all: setup build move

TARBALL := apache-cloudberry-2.0.0-incubating-src.tar.gz

# prepare directory from local tarball
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

# build deb packages
build:
	cd build && dpkg-buildpackage -b -us -uc

# collect artifacts
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# cleanup
clean:
	rm -rf build *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup build move clean
