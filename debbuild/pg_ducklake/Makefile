all: build move

VERSION := 1.0.2
TARBALL := pg_ducklake-$(VERSION).tar.gz
ROARING_VERSION := 4.7.1
# Upstream v1.0.2 CI pins vcpkg 84bab45d, whose roaring port is 4.5.0.
# Keep Pigsty's already-validated 4.7.1; CRoaring 5 is a separate major upgrade.
ROARING_TARBALL := CRoaring-$(ROARING_VERSION)-amalgamation.tar.gz
PATCH := patches/pg_ducklake-$(VERSION).patch

SOURCE_TARBALL ?= $(firstword $(wildcard \
	$(HOME)/ext/src/$(TARBALL) \
	$(HOME)/pgsty/repo/ext/src/$(TARBALL) \
	../SOURCES/$(TARBALL) \
	../../src/$(TARBALL)))
ROARING_SOURCE_TARBALL ?= $(firstword $(wildcard \
	$(HOME)/ext/src/$(ROARING_TARBALL) \
	$(HOME)/pgsty/repo/ext/src/$(ROARING_TARBALL) \
	../SOURCES/$(ROARING_TARBALL) \
	../../src/$(ROARING_TARBALL)))
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
SOURCE_CANDIDATE_DIR ?= $(CURDIR)/candidate
BUILD_DIR := build
PG_VERSIONS := 18 17 16 15 14
TAR_BIN := $(shell command -v gtar 2>/dev/null || command -v tar)

build:
	@set -e; for v in $(PG_VERSIONS); do $(MAKE) build$$v; done

source: refresh-source

refresh-source:
	VERSION=$(VERSION) OUT_DIR=$(SOURCE_CANDIDATE_DIR) ./prepare.sh
	@echo "candidate only; review it before promotion to the authoritative source store"

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing authoritative $(TARBALL); run pig build get first, or make source and review the candidate"; exit 1)
	@test -n "$(ROARING_SOURCE_TARBALL)" -a -f "$(ROARING_SOURCE_TARBALL)" || (echo "missing $(ROARING_TARBALL); copy only this tarball into ../SOURCES"; exit 1)

build18 build17 build16 build15 build14: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	$(TAR_BIN) --no-same-owner -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	patch -d $(BUILD_DIR) -p1 --fuzz=0 < $(PATCH)
	$(TAR_BIN) --no-same-owner -C $(BUILD_DIR) -xzf "$(ROARING_SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog
	sed -i "s/PGVERSION/$(@:build%=%)/g" $(BUILD_DIR)/debian/control
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all build source refresh-source check-src build18 build17 build16 build15 build14 move clean
