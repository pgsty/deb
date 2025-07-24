all: pre setup build

SRC_DIR := ~/plv8
PKG_NAME := plv8


TARBALL := plv8-3.2.4.tar.gz

pre:
	mkdir ~/plv8
	tar -C ~/plv8 --strip-components=1 -xf ../tarball/$(TARBALL)
	cd ~/plv8 && make -j16

# prepare directory
setup:
	rm -rf $(SRC_DIR)/debian
	cp -r debian $(SRC_DIR)/debian
	cd $(SRC_DIR) && pg_buildext updatecontrol
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(SRC_DIR)/debian/changelog

# building deb
build:
	cd $(SRC_DIR) && dpkg-buildpackage -b -us -uc

# collect deb
move:
	cp ~/*plv8*.deb /tmp/deb

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls
