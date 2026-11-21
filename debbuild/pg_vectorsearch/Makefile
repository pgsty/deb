# Select the recipe targets, including PG19 on older postgresql-common.
export PG_SUPPORTED_VERSIONS ?= $(shell cat debian/pgversions)

TARBALL := pg_vectorsearch-0.1.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS ?= $(if $(PG_VERSION),$(PG_VERSION),$(filter $(PG_SUPPORTED_VERSIONS),$(shell cat debian/pgversions)))

all:
	@set -e; for pg in $(PG_VERSIONS); do \
		$(MAKE) build-version PG_VERSION=$$pg; \
	done

build-version: move

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get $(TARBALL) first"; exit 1)
	cd "$(dir $(SOURCE_TARBALL))" && sha256sum -c "$(CURDIR)/sources.sha256"

setup: check-src
	@case "$(PG_VERSION)" in 18|19) ;; *) echo "set PG_VERSION=18 or PG_VERSION=19 for a single build" >&2; exit 1 ;; esac
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' "$(PG_VERSION)" > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$(lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: setup
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move: build
	mkdir -p "$(PKG_OUTPUT_DIR)"
	cp *.deb "$(PKG_OUTPUT_DIR)/"
	find . -maxdepth 1 -type f -name '*.ddeb' -exec cp {} "$(PKG_OUTPUT_DIR)/" \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all build-version check-src setup build move clean
