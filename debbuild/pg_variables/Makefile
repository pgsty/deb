all: setup build move

TARBALL := pg_variables-1.2.5.tar.gz
SOURCE_DIR ?= $(or $(wildcard $(HOME)/pgsty/repo/ext/src),../SOURCES)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PATCHES := patches/pg_variables-1.2.5-pgpro-7614.patch patches/pg_variables-1.2.5-pg18-compact-attribute.patch

check-src:
	@test -f "$(SOURCE_DIR)/$(TARBALL)" || (echo "missing $(SOURCE_DIR)/$(TARBALL), download the official v1.2.5 source tarball from https://github.com/postgrespro/pg_variables/archive/refs/tags/v1.2.5.tar.gz"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf $(SOURCE_DIR)/$(TARBALL)
	@$(MAKE) apply-patches
	pg_buildext updatecontrol
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

apply-patches:
	@set -e; \
	for p in $(PATCHES); do \
		echo "apply $$p"; \
		(cd $(BUILD_DIR) && patch -p1 < "../$$p"); \
	done

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup apply-patches build move clean
