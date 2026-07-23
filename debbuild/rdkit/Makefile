all: check-suite check-src setup build move

BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
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
else ifeq ($(SUITE),resolute)
DSC_FILE := rdkit_202503.6-4.dsc
ORIG_FILE := rdkit_202503.6.orig.tar.xz
DEBIAN_FILE := rdkit_202503.6-4.debian.tar.xz
PACKAGING_DIR := debian
else
DSC_FILE := unsupported
ORIG_FILE := unsupported
DEBIAN_FILE := unsupported
PACKAGING_DIR := unsupported
endif

SOURCE_DSC ?= ../SOURCES/$(DSC_FILE)
SOURCE_ORIG ?= ../SOURCES/$(ORIG_FILE)
SOURCE_DEBIAN ?= ../SOURCES/$(DEBIAN_FILE)

check-suite:
	@case "$(SUITE)" in \
	  bookworm|jammy|resolute) ;; \
	  trixie|noble) echo "RDKit PG14-18 is provided by PGDG on $(SUITE); refusing a duplicate Pigsty build"; exit 1 ;; \
	  *) echo "unsupported RDKit build suite: $(SUITE)"; exit 1 ;; \
	esac

check-src:
	@test -f "$(SOURCE_DSC)" || (echo "missing $(SOURCE_DSC), run pig build get rdkit first; if it is unavailable, copy $(DSC_FILE) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)
	@test -f "$(SOURCE_ORIG)" || (echo "missing $(SOURCE_ORIG), run pig build get rdkit first; if it is unavailable, copy $(ORIG_FILE) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)
	@test -f "$(SOURCE_DEBIAN)" || (echo "missing $(SOURCE_DEBIAN), run pig build get rdkit first; if it is unavailable, copy $(DEBIAN_FILE) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	dpkg-source -x "$(SOURCE_DSC)" $(BUILD_DIR)
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian
	cp -r $(PACKAGING_DIR) $(BUILD_DIR)/debian
	if [ "$(PACKAGING_DIR)" = "debian-legacy" ]; then \
		for patch in patches/rdkit-202303.3-toolkit-version.patch patches/rdkit-202303.3-cartridge-makefile.patch patches/rdkit-202303.3-pg17-operators.patch; do \
			patch -d $(BUILD_DIR) -p1 < "$$patch"; \
		done; \
		sed -i "1s/~SUITE)/~$(SUITE))/" $(BUILD_DIR)/debian/changelog; \
	fi
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS=installed pg_buildext updatecontrol

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-suite check-src setup build move clean
