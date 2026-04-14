all: check-src setup build move

DSC_FILE := rdkit_202503.6-4.dsc
ORIG_FILE := rdkit_202503.6.orig.tar.xz
DEBIAN_FILE := rdkit_202503.6-4.debian.tar.xz
BUILD_DIR := build
ENABLE_INCHI ?= 0
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
SOURCE_DSC ?= ../SOURCES/$(DSC_FILE)
SOURCE_ORIG ?= ../SOURCES/$(ORIG_FILE)
SOURCE_DEBIAN ?= ../SOURCES/$(DEBIAN_FILE)

check-src:
	@test -f "$(SOURCE_DSC)" || (echo "missing $(SOURCE_DSC), run pig build get rdkit first; if it is unavailable, copy $(DSC_FILE) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)
	@test -f "$(SOURCE_ORIG)" || (echo "missing $(SOURCE_ORIG), run pig build get rdkit first; if it is unavailable, copy $(ORIG_FILE) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)
	@test -f "$(SOURCE_DEBIAN)" || (echo "missing $(SOURCE_DEBIAN), run pig build get rdkit first; if it is unavailable, copy $(DEBIAN_FILE) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	dpkg-source -x "$(SOURCE_DSC)" $(BUILD_DIR)
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian
	cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog; \
	if [ "$$OS_CODENAME" = "noble" ] && [ "$(ENABLE_INCHI)" != "1" ]; then \
		sed -i '/libinchi-dev/d' $(BUILD_DIR)/debian/control.in; \
	fi
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS=installed pg_buildext updatecontrol

build:
	cd $(BUILD_DIR) && ENABLE_INCHI=$(ENABLE_INCHI) dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
