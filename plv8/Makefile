all: setup build

SRC_DIR := ~/plv8
PKG_NAME := plv8


TARBALL := plv8-3.2.3.tar.gz

pre:
	mkdir ~/plv8
	tar -C ~/plv8 --strip-components=1 -xf ../tarball/$(TARBALL)

# prepare directory
setup:
	rm -rf $(SRC_DIR)/debian
	cp -r debian $(SRC_DIR)/debian
	cd $(SRC_DIR) && pg_buildext updatecontrol
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(SRC_DIR)/debian/changelog

## prepare directory
#setup:
#	rm -rf build; mkdir -p build
#	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
#	pg_buildext updatecontrol
#	rm -rf build/debian; cp -r debian build/debian
#	OS_CODENAME=$(shell lsb_release -sc); \
#	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(SRC_DIR)/debian/changelog
#
## building deb
#build:
#	cd build && pg_buildext updatecontrol
#	cd build && dpkg-buildpackage -b -us -uc



# building deb
build:
	cd $(SRC_DIR) && dpkg-buildpackage -b -us -uc

# collect deb
move:
	cp ~/postgresql-*plv8*.deb /tmp/deb

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls
