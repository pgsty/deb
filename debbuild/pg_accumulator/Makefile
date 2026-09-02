all: setup build move

VERSION := 1.2.0
TARBALL := pg_accumulator-$(VERSION).tar.gz
PATCH := patches/pg_accumulator-$(VERSION).patch
UPSTREAM_COMMIT := d9b908b9a4dbea8464fb4ecdf0677f03381aa0c8

SOURCE_TARBALL ?= $(firstword $(wildcard \
	$(HOME)/ext/src/$(TARBALL) \
	$(HOME)/pgsty/repo/ext/src/$(TARBALL) \
	../SOURCES/$(TARBALL) \
	../../src/$(TARBALL)))
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing authoritative $(TARBALL), run pig build get first; if needed, copy only this tarball into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar --no-same-owner -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) -name '._*' -delete
	patch -d $(BUILD_DIR) -p1 --fuzz=0 < $(PATCH)
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
