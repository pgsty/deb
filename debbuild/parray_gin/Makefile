all: setup build move

TARBALL := parray_gin-1.4.0.tar.gz
SOURCE_CANDIDATES := $(HOME)/pgsty/repo/ext/src $(HOME)/pgsty/rpm/src $(HOME)/pgsty/rpm/rpmbuild/SOURCES ../../src ../SOURCES
SOURCE_DIR ?= $(firstword $(foreach d,$(SOURCE_CANDIDATES),$(if $(wildcard $(d)/$(TARBALL)),$(d))))
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -n "$(SOURCE_DIR)" || (echo "missing $(TARBALL), looked in: $(SOURCE_CANDIDATES)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_DIR)/$(TARBALL)"
	find $(BUILD_DIR) -name '._*' -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
