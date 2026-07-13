all: move

TARBALL := dbt2-0.61.7.tar.gz
TARBALL_SHA256 := 8f5740a26453cd0051e797a6abd1af086e7e2a4ef598003a5af912a6bc5636bc
SOURCE_TARBALL ?= $(or $(wildcard $(HOME)/ext/src/$(TARBALL)),$(wildcard ../SOURCES/$(TARBALL)))
ROOT_DIR := build-src
BUILD_DIR := $(ROOT_DIR)/storedproc/pgsql/c
PKG_PARENT := $(ROOT_DIR)/storedproc/pgsql
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing $(TARBALL) under $(HOME)/ext/src or ../SOURCES, run pig build get first; if needed, copy it there"; exit 1)
	@printf '%s  %s\n' '$(TARBALL_SHA256)' '$(SOURCE_TARBALL)' | sha256sum --check --status || (echo "SHA-256 mismatch for $(SOURCE_TARBALL)"; exit 1)

clean-artifacts:
	rm -f *.deb *.ddeb *.buildinfo *.changes

setup: clean-artifacts check-src
	rm -rf $(ROOT_DIR); mkdir -p $(ROOT_DIR)
	tar -C $(ROOT_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(ROOT_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	cp $(ROOT_DIR)/LICENSE $(ROOT_DIR)/README $(BUILD_DIR)/
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: setup
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move: build
	mkdir -p $(PKG_OUTPUT_DIR)
	@set -e; files=$$(find $(PKG_PARENT) -maxdepth 1 -type f \( -name '*.deb' -o -name '*.ddeb' \)); test -n "$$files"; cp $$files $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(ROOT_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src clean-artifacts setup build move clean
