all: setup
	$(MAKE) build
	$(MAKE) move

VERSION := 2.0.2
DUCKDB_VERSION := 2.0.1
TARBALL := duckdb_fdw-$(VERSION).tar.gz
DUCKDB_TARBALL := duckdb-$(DUCKDB_VERSION).tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
DUCKDB_SOURCE_TARBALL ?= ../SOURCES/$(DUCKDB_TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
# Empty means the recipe's PG15-19 list; upstream 2.0.2 does not build on PG14.
PG_VERSIONS ?=
export PG_SUPPORTED_VERSIONS ?= $(shell cat debian/pgversions)

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; copy only the missing archive if needed"; exit 1)
	@test -f "$(DUCKDB_SOURCE_TARBALL)" || (echo "missing $(DUCKDB_SOURCE_TARBALL), run pig build get first; copy only the missing archive if needed"; exit 1)
	@for v in $(PG_VERSIONS); do case $$v in 15|16|17|18|19) ;; *) echo "unsupported PostgreSQL major: $$v"; exit 1 ;; esac; done

setup: check-src
	echo '1ed7935b009211915434fd65083b0562389e3faf1722865f81633d70a0c0fc8b  $(SOURCE_TARBALL)' | sha256sum -c -
	echo '1deae9d4917bd069c46c25c6ddbe51a2ef06cc7c12e6a10132af4fa0fb834a14  $(DUCKDB_SOURCE_TARBALL)' | sha256sum -c -
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/duckdb
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	tar -C $(BUILD_DIR)/duckdb --strip-components=1 -xf "$(DUCKDB_SOURCE_TARBALL)"
	cp -r debian $(BUILD_DIR)/debian
	@if test -n "$(PG_VERSIONS)"; then printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions; fi
	OS_CODENAME=$$(lsb_release -sc); sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p "$(PKG_OUTPUT_DIR)"
	cp *.deb "$(PKG_OUTPUT_DIR)/"
	find . -maxdepth 1 -type f -name '*.ddeb' -exec cp {} "$(PKG_OUTPUT_DIR)/" \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
