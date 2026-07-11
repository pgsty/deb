all: move

VERSION := 3.4.0
TARBALL := pg_lake-$(VERSION).tar.gz
BUILD_DIR := build
PG_VERSIONS := 16 17 18
VCPKG_VERSION := 2025.10.17
VCPKG_COMMIT := 74e6536215718009aae747d86d84b78376bf9e09
UPSTREAM_COMMIT := 9242798331c415358490587670e4b81a9d4eb4e7
AVRO_COMMIT := 2b11dba4fb28c7bb6ff08b40509a6a71fcaf4c21
DUCKDB_COMMIT := 6ddac802ffa9bcfbcc3f5f0d71de5dff9b0bc250
DUCKDB_POSTGRES_COMMIT := b63ef4b1eb007320840b6d1760f3c9b139bb3b49
DUCKDB_HTTPFS_COMMIT := 13f8a814d41a978c3f19eb1dc76069489652ea6f
DUCKDB_AWS_COMMIT := bc15d211f282d1d78fc0d9fda3d09957ba776423
DUCKDB_AZURE_COMMIT := 7e1ac3333d946a6bf5b4552722743e03f30a47cd
SOURCE_SHA256 := fd9fd38b723448a93f3a8265f60655560f8044198cf9c96df26b992cd0b2f2c0
PATCH_SHA256 := 6220c36c4c363a1a15144ebeb895261228f8593c8080fc34ba1a464e3d50f60c

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
SOURCE_PATCHES := patches/pg_lake-3.4.0-pg-libdir.patch
TAR_BIN := $(shell command -v gtar 2>/dev/null || command -v tar)
SHA256_BIN := $(shell command -v sha256sum 2>/dev/null || command -v gsha256sum 2>/dev/null)

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing authoritative $(TARBALL); run make source to create a candidate, then review and promote it"; exit 1)
	@test -n "$(SHA256_BIN)" || (echo "missing sha256sum/gsha256sum"; exit 1)
	@test "$$($(SHA256_BIN) "$(SOURCE_TARBALL)" | awk '{print $$1}')" = "$(SOURCE_SHA256)" || (echo "sha256 mismatch: $(SOURCE_TARBALL)"; exit 1)
	@test "$$($(SHA256_BIN) "$(SOURCE_PATCHES)" | awk '{print $$1}')" = "$(PATCH_SHA256)" || (echo "sha256 mismatch: $(SOURCE_PATCHES)"; exit 1)

source: refresh-source

refresh-source:
	VERSION=$(VERSION) OUT_DIR=$(SOURCE_CANDIDATE_DIR) ./prepare.sh
	@echo "candidate only; promote it to the authoritative source store and update both DEB/RPM SHA256 constants after review"

setup: check-src
	@set -e; for v in $(PG_VERSIONS); do rm -f postgresql-$$v-pg-lake_$(VERSION)-*.deb; done
	rm -f pg-lake_$(VERSION)-*.buildinfo pg-lake_$(VERSION)-*.changes
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	$(TAR_BIN) --no-same-owner -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	test -f $(BUILD_DIR)/SOURCE_MANIFEST
	test -f $(BUILD_DIR)/avro/lang/c/CMakeLists.txt
	test -f $(BUILD_DIR)/duckdb_pglake/duckdb/CMakeLists.txt
	test -f $(BUILD_DIR)/duckdb_pglake/duckdb-postgres/CMakeLists.txt
	grep -qx 'version=$(VERSION)' $(BUILD_DIR)/SOURCE_MANIFEST
	grep -qx 'upstream_commit=$(UPSTREAM_COMMIT)' $(BUILD_DIR)/SOURCE_MANIFEST
	grep -qx 'avro_commit=$(AVRO_COMMIT)' $(BUILD_DIR)/SOURCE_MANIFEST
	grep -qx 'duckdb_commit=$(DUCKDB_COMMIT)' $(BUILD_DIR)/SOURCE_MANIFEST
	grep -qx 'duckdb_postgres_commit=$(DUCKDB_POSTGRES_COMMIT)' $(BUILD_DIR)/SOURCE_MANIFEST
	grep -q 'GIT_TAG $(DUCKDB_HTTPFS_COMMIT)' $(BUILD_DIR)/duckdb_pglake/extension_config.cmake
	grep -q 'GIT_TAG $(DUCKDB_AWS_COMMIT)' $(BUILD_DIR)/duckdb_pglake/extension_config.cmake
	grep -q 'GIT_TAG $(DUCKDB_AZURE_COMMIT)' $(BUILD_DIR)/duckdb_pglake/extension_config.cmake
	test "$$(git -C $(BUILD_DIR) rev-parse HEAD)" = "$(UPSTREAM_COMMIT)"
	test "$$(git -C $(BUILD_DIR)/avro rev-parse HEAD)" = "$(AVRO_COMMIT)"
	test "$$(git -C $(BUILD_DIR)/duckdb_pglake/duckdb rev-parse HEAD)" = "$(DUCKDB_COMMIT)"
	test "$$(git -C $(BUILD_DIR)/duckdb_pglake/duckdb-postgres rev-parse HEAD)" = "$(DUCKDB_POSTGRES_COMMIT)"
	@test "$$(git -C $(BUILD_DIR) status --porcelain --untracked-files=all --ignore-submodules=dirty)" = "?? SOURCE_MANIFEST"
	@set -e; for repo in \
		$(BUILD_DIR)/avro \
		$(BUILD_DIR)/duckdb_pglake/duckdb \
		$(BUILD_DIR)/duckdb_pglake/duckdb-postgres; do \
		test -z "$$(git -C "$$repo" status --porcelain --untracked-files=all --ignore-submodules=dirty)"; \
	done
	git -C $(BUILD_DIR) config submodule.test_common/rest_catalog/polaris.update none
	@set -e; for p in $(SOURCE_PATCHES); do echo "apply $$p"; git -C $(BUILD_DIR) apply --whitespace=nowarn "$(CURDIR)/$$p"; done
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog
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

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

distclean: clean
	rm -rf $(VCPKG_ROOT)

.PHONY: all check-src source refresh-source setup vcpkg build move clean distclean
