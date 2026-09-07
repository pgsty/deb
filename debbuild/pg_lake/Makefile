all: move

VERSION := 3.4.4
TARBALL := pg_lake-$(VERSION).tar.gz
BUILD_DIR := build
PG_VERSIONS := 16 17 18
VCPKG_VERSION := 2025.10.17
VCPKG_COMMIT := 74e6536215718009aae747d86d84b78376bf9e09
VCPKG_MAX_CONCURRENCY ?= 2
PG_LAKE_BUILD_JOBS ?= 2
PG_LAKE_LTO_JOBS ?= 1
VCPKG_DEB_ARCH := $(shell dpkg --print-architecture)
VCPKG_RELEASE_ARCH := $(if $(filter arm64,$(VCPKG_DEB_ARCH)),arm64,x64)
VCPKG_TARGET_TRIPLET ?= $(VCPKG_RELEASE_ARCH)-linux-release
VCPKG_HOST_TRIPLET ?= $(VCPKG_RELEASE_ARCH)-linux-release
VCPKG_INSTALL_FLAGS ?=
# vcpkg dependencies keep function and line-table DWARF only (-g1).  Key the
# binary cache by these flags so a flag change never reuses older archives.
VCPKG_CFLAGS := $(shell dpkg-buildflags --get CFLAGS | sed 's/-flto=auto/-flto=$(PG_LAKE_LTO_JOBS)/g') -g1
VCPKG_CXXFLAGS := $(shell dpkg-buildflags --get CXXFLAGS | sed 's/-flto=auto/-flto=$(PG_LAKE_LTO_JOBS)/g') -g1
VCPKG_LDFLAGS := $(shell dpkg-buildflags --get LDFLAGS | sed 's/-flto=auto/-flto=$(PG_LAKE_LTO_JOBS)/g')
VCPKG_DEFAULT_BINARY_CACHE ?= $(HOME)/.cache/pg_lake/vcpkg-archives-$(shell printf '%s\n' '$(VCPKG_CFLAGS)' '$(VCPKG_CXXFLAGS)' '$(VCPKG_LDFLAGS)' | sha256sum | cut -c1-12)

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
	mkdir -p "$(VCPKG_DEFAULT_BINARY_CACHE)"
	cd $(BUILD_DIR)/duckdb_pglake && \
		VCPKG_DISABLE_METRICS=1 \
		VCPKG_MAX_CONCURRENCY="$(VCPKG_MAX_CONCURRENCY)" \
		VCPKG_DEFAULT_BINARY_CACHE="$(VCPKG_DEFAULT_BINARY_CACHE)" \
		VCPKG_KEEP_ENV_VARS='CPPFLAGS;CFLAGS;CXXFLAGS;LDFLAGS' \
		CPPFLAGS="$$(dpkg-buildflags --get CPPFLAGS)" \
		CFLAGS="$(VCPKG_CFLAGS)" \
		CXXFLAGS="$(VCPKG_CXXFLAGS)" \
		LDFLAGS="$(VCPKG_LDFLAGS)" \
		"$(VCPKG_ROOT)/vcpkg" install \
			--triplet "$(VCPKG_TARGET_TRIPLET)" \
			--host-triplet "$(VCPKG_HOST_TRIPLET)" \
			$(VCPKG_INSTALL_FLAGS)

build: vcpkg
	cd $(BUILD_DIR) && \
		VCPKG_TOOLCHAIN_PATH="$(VCPKG_TOOLCHAIN_PATH)" \
		VCPKG_DISABLE_METRICS=1 \
		VCPKG_DEFAULT_BINARY_CACHE="$(VCPKG_DEFAULT_BINARY_CACHE)" \
		VCPKG_MAX_CONCURRENCY="$(VCPKG_MAX_CONCURRENCY)" \
		VCPKG_TARGET_TRIPLET="$(VCPKG_TARGET_TRIPLET)" \
		VCPKG_HOST_TRIPLET="$(VCPKG_HOST_TRIPLET)" \
		dpkg-buildpackage -b -us -uc

move: build
	@set -e; mkdir -p $(PKG_OUTPUT_DIR); \
	for v in $(PG_VERSIONS); do \
		set -- postgresql-$$v-pg-lake_$(VERSION)-*.deb; \
		test "$$#" -eq 1 -a -f "$$1" || (echo "expected exactly one PG $$v package"; exit 1); \
		cp "$$1" $(PKG_OUTPUT_DIR)/; \
		dbg=$$(find . -maxdepth 1 -type f \( -name "postgresql-$$v-pg-lake-dbgsym_$(VERSION)-*.deb" -o -name "postgresql-$$v-pg-lake-dbgsym_$(VERSION)-*.ddeb" \) -print); \
		test "$$(printf '%s\n' "$$dbg" | sed '/^$$/d' | wc -l)" -eq 1 || (echo "expected exactly one PG $$v dbgsym package"; exit 1); \
		cp "$$dbg" $(PKG_OUTPUT_DIR)/; \
	done

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

distclean: clean
	rm -rf $(VCPKG_ROOT)

.PHONY: all check-src source refresh-source setup vcpkg build move clean distclean
