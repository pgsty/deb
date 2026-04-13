all: setup build move

TARBALL := GraphBLAS-10.2.0.tar.gz

setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

build:
	cd build && dpkg-buildpackage -b -us -uc

move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb build

.PHONY: all setup build move clean
