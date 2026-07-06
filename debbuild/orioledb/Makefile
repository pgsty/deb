all: orioledb

PG_MAJOR ?= 18
BUILD_DIR := build
SOURCE_DIR ?= ../SOURCES
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

ORIOLEDB_VERSION := 1.8
ORIOLEDB_BETA := beta16
ORIOLEDB_DEB_VERSION := 1.8-0.beta16
ORIOLEDB_TARBALL := orioledb-$(ORIOLEDB_BETA).tar.gz
ORIOLEDB_SOURCE_TARBALL ?= $(SOURCE_DIR)/$(ORIOLEDB_TARBALL)

ifeq ($(PG_MAJOR),16)
ORIOLEDB_PATCHSET_VERSION := 47
PATCHSET_LABEL := 16_47
PG_UPSTREAM_VERSION := 16.13
PG_PATCH_TARBALL := postgres-patches16_47.tar.gz
CHANGELOG_DATE := Mon, 06 Jul 2026 00:00:00 +0000
else ifeq ($(PG_MAJOR),17)
ORIOLEDB_PATCHSET_VERSION := 20
PATCHSET_LABEL := 17_20
PG_UPSTREAM_VERSION := 17.9
PG_PATCH_TARBALL := postgres-patches17_20.tar.gz
CHANGELOG_DATE := Mon, 06 Jul 2026 00:00:00 +0000
else ifeq ($(PG_MAJOR),18)
ORIOLEDB_PATCHSET_VERSION := 1
PATCHSET_LABEL := 18_1
PG_UPSTREAM_VERSION := 18.4
PG_PATCH_TARBALL := postgres-patches18_1.tar.gz
CHANGELOG_DATE := Mon, 06 Jul 2026 00:00:00 +0000
else
$(error unsupported PG_MAJOR=$(PG_MAJOR), expected 16, 17, or 18)
endif

SOURCE_PACKAGE := orioledb-$(PG_MAJOR)
PACKAGE := orioledb-$(PG_MAJOR)
PG_PATCH_SOURCE_TARBALL ?= $(SOURCE_DIR)/$(PG_PATCH_TARBALL)

check-src:
	@test -f "$(PG_PATCH_SOURCE_TARBALL)" || (echo "missing $(PG_PATCH_SOURCE_TARBALL), run pig build get first; if needed, copy $(PG_PATCH_TARBALL) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(ORIOLEDB_SOURCE_TARBALL)" || (echo "missing $(ORIOLEDB_SOURCE_TARBALL), run pig build get first; if needed, copy $(ORIOLEDB_TARBALL) into $(SOURCE_DIR)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(PG_PATCH_SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	rm -rf $(BUILD_DIR)/.orioledb-src $(BUILD_DIR)/contrib/orioledb
	mkdir -p $(BUILD_DIR)/.orioledb-src
	tar -C $(BUILD_DIR)/.orioledb-src -xf "$(ORIOLEDB_SOURCE_TARBALL)"
	orioledb_src=$$(find $(BUILD_DIR)/.orioledb-src -mindepth 1 -maxdepth 1 -type d | head -n 1); \
	if [ -z "$$orioledb_src" ]; then \
		echo "cannot locate extracted OrioleDB source tree" >&2; \
		exit 1; \
	fi; \
	mv "$$orioledb_src" $(BUILD_DIR)/contrib/orioledb; \
	rmdir $(BUILD_DIR)/.orioledb-src
	if ! grep -Eq '^[[:space:]]*orioledb[[:space:]]*\\[[:space:]]*$$' $(BUILD_DIR)/contrib/Makefile; then \
		sed -ri 's/^([[:space:]]*)vacuumlo$$/\1orioledb\t\\\n\1vacuumlo/' $(BUILD_DIR)/contrib/Makefile; \
	fi
	grep -Eq '^[[:space:]]*orioledb[[:space:]]*\\[[:space:]]*$$' $(BUILD_DIR)/contrib/Makefile || (echo "failed to inject orioledb into contrib/Makefile" >&2; exit 1)
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	PACKAGE_VERSION="$(ORIOLEDB_DEB_VERSION)PIGSTY~$${OS_CODENAME}"; \
	sed -e 's|@SOURCE_PACKAGE@|$(SOURCE_PACKAGE)|g' \
		-e 's|@PACKAGE@|$(PACKAGE)|g' \
		-e 's|@PG_MAJOR@|$(PG_MAJOR)|g' \
		-e 's|@PATCHSET_LABEL@|$(PATCHSET_LABEL)|g' \
		-e 's|@PG_UPSTREAM_VERSION@|$(PG_UPSTREAM_VERSION)|g' \
		$(BUILD_DIR)/debian/control.in > $(BUILD_DIR)/debian/control; \
	{ \
		printf '%s\n' "$(SOURCE_PACKAGE) ($${PACKAGE_VERSION}) unstable; urgency=medium"; \
		printf '%s\n' ""; \
		printf '%s\n' "  * Merge the OriolePG kernel and OrioleDB extension into bundled $(PACKAGE)."; \
		printf '%s\n' "  * Build from PostgreSQL $(PG_UPSTREAM_VERSION) patchset $(PATCHSET_LABEL) and OrioleDB $(ORIOLEDB_VERSION) $(ORIOLEDB_BETA)."; \
		printf '%s\n' ""; \
		printf '%s\n' " -- Ruohang Feng <rh@vonng.com>  $(CHANGELOG_DATE)"; \
		printf '%s\n' ""; \
	} > $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && PG_MAJOR=$(PG_MAJOR) ORIOLEDB_PATCHSET_VERSION=$(ORIOLEDB_PATCHSET_VERSION) ORIOLEDB_VERSION=$(ORIOLEDB_VERSION) ORIOLEDB_BETA=$(ORIOLEDB_BETA) dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp $(PACKAGE)_*.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

orioledb: orioledb-18

orioledb-16:
	$(MAKE) PG_MAJOR=16 clean setup build move

orioledb-17:
	$(MAKE) PG_MAJOR=17 clean setup build move

orioledb-18:
	$(MAKE) PG_MAJOR=18 clean setup build move

orioledb-all:
	$(MAKE) orioledb-16
	$(MAKE) orioledb-17
	$(MAKE) orioledb-18

build16: orioledb-16
build17: orioledb-17
build18: orioledb-18
build-all: orioledb-all

.PHONY: all check-src setup build move clean orioledb orioledb-16 orioledb-17 orioledb-18 orioledb-all build16 build17 build18 build-all ls
