all: check-suite check-src setup build move

BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
ENABLE_INCHI ?= 0
SUITE ?= $(shell (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}))

ifeq ($(SUITE),bookworm)
DSC_FILE := rdkit_202303.3-3.pgdg120+1.dsc
ORIG_FILE := rdkit_202303.3.orig.tar.xz
DEBIAN_FILE := rdkit_202303.3-3.pgdg120+1.debian.tar.xz
PACKAGING_DIR := debian-legacy
else ifeq ($(SUITE),jammy)
DSC_FILE := rdkit_202303.3-3.pgdg22.04+1.dsc
ORIG_FILE := rdkit_202303.3.orig.tar.xz
DEBIAN_FILE := rdkit_202303.3-3.pgdg22.04+1.debian.tar.xz
PACKAGING_DIR := debian-legacy
else ifneq ($(filter $(SUITE),trixie noble resolute),)
TARBALL := rdkit-Release_2026_09_1.tar.gz
PACKAGING_DIR := debian
else
DSC_FILE := unsupported
ORIG_FILE := unsupported
DEBIAN_FILE := unsupported
PACKAGING_DIR := unsupported
endif

SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
SOURCE_ENUM ?= ../SOURCES/better-enums-0.11.3-enum.h
SOURCE_RINGS ?= ../SOURCES/RingDecomposerLib-1.1.3_rdkit.tar.gz

SOURCE_DSC ?= ../SOURCES/$(DSC_FILE)
SOURCE_ORIG ?= ../SOURCES/$(ORIG_FILE)
SOURCE_DEBIAN ?= ../SOURCES/$(DEBIAN_FILE)

check-suite:
	@case "$(SUITE)" in \
	  bookworm|jammy|trixie|noble|resolute) ;; \
	  *) echo "unsupported RDKit build suite: $(SUITE)"; exit 1 ;; \
	esac

check-src:
ifeq ($(PACKAGING_DIR),debian)
	@for src in "$(SOURCE_TARBALL)" "$(SOURCE_ENUM)" "$(SOURCE_RINGS)"; do test -f "$$src" || { echo "missing $$src; run pig build get rdkit first, then copy only the missing input"; exit 1; }; done
else
	@test -f "$(SOURCE_DSC)" || (echo "missing $(SOURCE_DSC), run pig build get rdkit first; if it is unavailable, copy $(DSC_FILE) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)
	@test -f "$(SOURCE_ORIG)" || (echo "missing $(SOURCE_ORIG), run pig build get rdkit first; if it is unavailable, copy $(ORIG_FILE) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)
	@test -f "$(SOURCE_DEBIAN)" || (echo "missing $(SOURCE_DEBIAN), run pig build get rdkit first; if it is unavailable, copy $(DEBIAN_FILE) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)

endif

setup: check-src
	rm -rf $(BUILD_DIR)
ifeq ($(PACKAGING_DIR),debian)
	mkdir -p $(BUILD_DIR)
	tar -xzf "$(SOURCE_TARBALL)" --strip-components=1 -C $(BUILD_DIR)
	patch -d $(BUILD_DIR) -p1 --fuzz=0 < patches/rdkit-202609.1-offline.patch
	patch -d $(BUILD_DIR) -p1 --fuzz=0 < patches/rdkit-202603.6-extension-upgrade.patch
	patch -d $(BUILD_DIR) -p1 --fuzz=0 < patches/rdkit-202609.1-pg-config-version.patch
	cp "$(SOURCE_ENUM)" $(BUILD_DIR)/Code/RDGeneral/enum.h
	tar -xzf "$(SOURCE_RINGS)" -C $(BUILD_DIR)/External/RingFamilies
	mv $(BUILD_DIR)/External/RingFamilies/RingDecomposerLib-1.1.3_rdkit $(BUILD_DIR)/External/RingFamilies/RingDecomposerLib
else
	dpkg-source -x "$(SOURCE_DSC)" $(BUILD_DIR)
endif
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian
	cp -r $(PACKAGING_DIR) $(BUILD_DIR)/debian
	if [ "$(PACKAGING_DIR)" = "debian-legacy" ]; then \
		for patch in patches/rdkit-202303.3-toolkit-version.patch patches/rdkit-202303.3-cartridge-makefile.patch patches/rdkit-202303.3-pg17-operators.patch; do \
			patch -d $(BUILD_DIR) -p1 --fuzz=0 < "$$patch"; \
		done; \
		sed -i "1s/~SUITE)/~$(SUITE))/" $(BUILD_DIR)/debian/changelog; \
	fi
	if [ "$(PACKAGING_DIR)" = "debian" ]; then sed -i "1s/1PGSTY)/1PGSTY~$(SUITE))/" $(BUILD_DIR)/debian/changelog; fi
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS=installed pg_buildext updatecontrol

build:
	cd $(BUILD_DIR) && ENABLE_INCHI=$(ENABLE_INCHI) dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-suite check-src setup build move clean
