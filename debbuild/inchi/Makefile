all: check-src setup build move

DSC_FILE := inchi_1.07.3+dfsg-1.dsc
ORIG_FILE := inchi_1.07.3+dfsg.orig.tar.xz
DEBIAN_FILE := inchi_1.07.3+dfsg-1.debian.tar.xz
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
SOURCE_DSC ?= ../SOURCES/$(DSC_FILE)
SOURCE_ORIG ?= ../SOURCES/$(ORIG_FILE)
SOURCE_DEBIAN ?= ../SOURCES/$(DEBIAN_FILE)

check-src:
	@test -f "$(SOURCE_DSC)" || (echo "missing $(SOURCE_DSC), fetch the Debian inchi source package first; if needed copy $(DSC_FILE) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)
	@test -f "$(SOURCE_ORIG)" || (echo "missing $(SOURCE_ORIG), fetch the Debian inchi source package first; if needed copy $(ORIG_FILE) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)
	@test -f "$(SOURCE_DEBIAN)" || (echo "missing $(SOURCE_DEBIAN), fetch the Debian inchi source package first; if needed copy $(DEBIAN_FILE) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	dpkg-source -x "$(SOURCE_DSC)" $(BUILD_DIR)
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/1.07.3+dfsg-1)/1.07.3+dfsg-1PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog; \
	if [ "$$OS_CODENAME" = "noble" ]; then \
		sed -i '2iexport DEB_BUILD_MAINT_OPTIONS = optimize=-lto' $(BUILD_DIR)/debian/rules; \
	fi

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
