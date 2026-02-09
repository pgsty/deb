all: setup build

SRC_DIR := ~/pg_tier
PKG_NAME := pg-tier

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
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls
