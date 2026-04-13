all: check-src setup build move

DSC_FILE := rdkit_202503.6-4.dsc
ORIG_FILE := rdkit_202503.6.orig.tar.xz
DEBIAN_FILE := rdkit_202503.6-4.debian.tar.xz
BUILD_DIR := build
PG_MAJOR ?= 18
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
SOURCE_DIR ?= $(if $(wildcard $(HOME)/pgsty/repo/ext/sol/src),$(HOME)/pgsty/repo/ext/sol/src,$(if $(wildcard $(HOME)/pgsty/repo/ext/src),$(HOME)/pgsty/repo/ext/src,../SOURCES))

check-src:
	@test -f "$(SOURCE_DIR)/$(DSC_FILE)" || (echo "missing $(SOURCE_DIR)/$(DSC_FILE)"; exit 1)
	@test -f "$(SOURCE_DIR)/$(ORIG_FILE)" || (echo "missing $(SOURCE_DIR)/$(ORIG_FILE)"; exit 1)
	@test -f "$(SOURCE_DIR)/$(DEBIAN_FILE)" || (echo "missing $(SOURCE_DIR)/$(DEBIAN_FILE)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	dpkg-source -x "$(SOURCE_DIR)/$(DSC_FILE)" $(BUILD_DIR)
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian
	cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog; \
	sed -i "s/@PG_MAJOR@/$(PG_MAJOR)/g" $(BUILD_DIR)/debian/control $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
