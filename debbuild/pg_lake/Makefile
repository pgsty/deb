all: move

VERSION := 3.4.4
TARBALL := pg_lake-$(VERSION).tar.gz
BUILD_DIR := build
PG_VERSIONS := 16 17 18
VCPKG_VERSION := 2025.10.17
VCPKG_COMMIT := 74e6536215718009aae747d86d84b78376bf9e09

SOURCE_TARBALL ?= $(firstword $(wildcard \
	$(HOME)/ext/src/$(TARBALL) \
	$(HOME)/pgsty/repo/ext/src/$(TARBALL) \
	$(HOME)/pgext/repo/ext/src/$(TARBALL) \
	../SOURCES/$(TARBALL) \
	../../src/$(TARBALL)))
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
VCPKG_ROOT ?= $(HOME)/.cache/pg_lake/vcpkg-$(VCPKG_VERSION)
VCPKG_TOOLCHAIN_PATH := $(VCPKG_ROOT)/scripts/buildsystems/vcpkg.cmake
SOURCE_CANDIDATE_DIR ?= $(CURDIR)/candidate
SOURCE_PATCHES := patches/pg_lake-3.4.4.patch
TAR_BIN := $(shell command -v gtar 2>/dev/null || command -v tar)

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing authoritative $(TARBALL); run make source to create a candidate, then review and promote it"; exit 1)

source: refresh-source

refresh-source:
	VERSION=$(VERSION) OUT_DIR=$(SOURCE_CANDIDATE_DIR) ./prepare.sh
	@echo "candidate only; review it before promotion to the authoritative source store"

setup: check-src
	@set -e; for v in $(PG_VERSIONS); do rm -f postgresql-$$v-pg-lake_$(VERSION)-*.deb; done
	rm -f pg-lake_$(VERSION)-*.buildinfo pg-lake_$(VERSION)-*.changes
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	$(TAR_BIN) --no-same-owner -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	@set -e; for p in $(SOURCE_PATCHES); do echo "apply $$p"; patch -d $(BUILD_DIR) -p1 --fuzz=0 < "$$p"; done
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog
	cd $(BUILD_DIR) && pg_buildext updatecontrol

vcpkg: setup
	@if [ ! -d "$(VCPKG_ROOT)/.git" ]; then \
		rm -rf "$(VCPKG_ROOT)"; \
		mkdir -p "$$(dirname "$(VCPKG_ROOT)")"; \
		git clone --depth 1 --branch "$(VCPKG_VERSION)" https://github.com/microsoft/vcpkg.git "$(VCPKG_ROOT)"; \
	fi
	@test "$$(git -C "$(VCPKG_ROOT)" describe --tags --exact-match 2>/dev/null)" = "$(VCPKG_VERSION)"
	@test "$$(git -C "$(VCPKG_ROOT)" rev-parse HEAD)" = "$(VCPKG_COMMIT)"
	@test -z "$$(git -C "$(VCPKG_ROOT)" status --porcelain --untracked-files=all --ignore-submodules=dirty)"
	@if [ ! -x "$(VCPKG_ROOT)/vcpkg" ]; then cd "$(VCPKG_ROOT)" && ./bootstrap-vcpkg.sh -disableMetrics; fi
	cd $(BUILD_DIR)/duckdb_pglake && VCPKG_DISABLE_METRICS=1 "$(VCPKG_ROOT)/vcpkg" install

build: vcpkg
	cd $(BUILD_DIR) && \
		VCPKG_TOOLCHAIN_PATH="$(VCPKG_TOOLCHAIN_PATH)" \
		VCPKG_DISABLE_METRICS=1 \
		dpkg-buildpackage -b -us -uc

move: build
	@set -e; mkdir -p $(PKG_OUTPUT_DIR); \
	for v in $(PG_VERSIONS); do \
		set -- postgresql-$$v-pg-lake_$(VERSION)-*.deb; \
		test "$$#" -eq 1 -a -f "$$1" || (echo "expected exactly one PG $$v package"; exit 1); \
		cp "$$1" $(PKG_OUTPUT_DIR)/; \
	done
	find . -maxdepth 1 -type f -name '*.ddeb' -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

distclean: clean
	rm -rf $(VCPKG_ROOT)

.PHONY: all check-src source refresh-source setup vcpkg build move clean distclean
