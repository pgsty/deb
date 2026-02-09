all: setup build move

SRC_DIR := ~/paradedb/pg_lakehouse
PKG_NAME := pg-lakehouse

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
	cp -rf ~/paradedb/*lakehouse*.deb ~/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls