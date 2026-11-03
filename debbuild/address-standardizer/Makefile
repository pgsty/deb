all: check-src setup build move
.NOTPARALLEL:

TARBALL := address_standardizer-3.7.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
BUILD_JOBS ?= 3
PG_VERSIONS ?= 14 15 16 17 18
DEB_BUILD_OPTIONS ?= parallel=$(BUILD_JOBS) nocheck
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test "$$(dpkg-architecture -qDEB_HOST_ARCH_BITS)" = 64 || (echo "a 64-bit builder is required" >&2; exit 1)
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES" >&2; exit 1)
	@echo "3f193591c1c0f8ec7d9f3cd179021a9df4e35594e0543fae187f3394721f2983  $(SOURCE_TARBALL)" | sha256sum -c -

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	cp -a debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$(lsb_release -sc); sed -i "1s/1PGSTY)/1PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && DEB_BUILD_OPTIONS="$(DEB_BUILD_OPTIONS)" dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR)
	cp *.deb $(PKG_OUTPUT_DIR)/
	find . -maxdepth 1 -type f -name '*.ddeb' -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
