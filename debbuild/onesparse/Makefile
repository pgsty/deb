all: setup build move

TARBALL := onesparse-1.0.0.tar.gz
SOURCE_TARBALL ?= $(or $(wildcard $(HOME)/ext/src/$(TARBALL)),$(wildcard ../SOURCES/$(TARBALL)))
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing $(TARBALL) under $(HOME)/ext/src or ../SOURCES, run pig build get first; if needed, copy it there"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	patch -d $(BUILD_DIR) -p1 --forward -f < debian/patches/0001-use-system-suitesparse-packages.patch
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i.bak "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog && rm -f $(BUILD_DIR)/debian/changelog.bak

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
