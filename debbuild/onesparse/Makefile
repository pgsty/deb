# Select the recipe targets, including PG19 on older postgresql-common.
export PG_SUPPORTED_VERSIONS ?= $(shell cat debian/pgversions)

all:
	@set -e; for pg in $(PG_VERSIONS); do \
		$(MAKE) build-version PG_VERSION=$$pg; \
	done

build-version: move

TARBALL := onesparse-1.0.0.tar.gz
PG_VERSIONS ?= $(if $(PG_VERSION),$(PG_VERSION),$(filter $(PG_SUPPORTED_VERSIONS),$(shell cat debian/pgversions)))
SOURCE_TARBALL ?= $(or $(wildcard $(HOME)/ext/src/$(TARBALL)),$(wildcard ../SOURCES/$(TARBALL)))
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing $(TARBALL) under $(HOME)/ext/src or ../SOURCES, run pig build get first; if needed, copy it there"; exit 1)

setup: check-src
	@case "$(PG_VERSION)" in 18|19) ;; *) echo "set PG_VERSION=18 or PG_VERSION=19 for a single build" >&2; exit 1 ;; esac
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	sed -i -e "s/postgresql-18/postgresql-$(PG_VERSION)/g" -e "s/PostgreSQL 18/PostgreSQL $(PG_VERSION)/g" $(BUILD_DIR)/debian/control
	sed -i -e "s@postgresql/18/@postgresql/$(PG_VERSION)/@g" -e "s/postgresql-18/postgresql-$(PG_VERSION)/g" $(BUILD_DIR)/debian/rules
	patch -d $(BUILD_DIR) -p1 --forward -f < debian/patches/onesparse-1.0.0.patch
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i.bak "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog && rm -f $(BUILD_DIR)/debian/changelog.bak

build: setup
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move: build
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all build-version check-src setup build move clean
