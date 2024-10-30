all: setup build move

TARBALL := libfq-0.6.1.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build/ --strip-components 1 -xf ../tarball/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

# building deb
build:
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	cp *.deb ~/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls
