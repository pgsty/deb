all: setup build move

VERSION := 1.2.42
PFS_COMMIT := d0c5dc6
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
TARBALL := polarstore-$(VERSION)-$(PFS_COMMIT).tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL); copy $(TARBALL) into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	test -f $(BUILD_DIR)/src/pfs_sdk/pfsd_sdk.h
	test -f $(BUILD_DIR)/src/pfs_sdk/pfsd_sdk.cc
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$(lsb_release -sc 2>/dev/null || true); \
	if [ -z "$$OS_CODENAME" ] && [ -r /etc/os-release ]; then \
		. /etc/os-release; \
		OS_CODENAME=$${VERSION_CODENAME:-$${UBUNTU_CODENAME:-}}; \
	fi; \
	OS_CODENAME=$${OS_CODENAME:-unknown}; \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp polarstore_*.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
