all: check-src setup build move
.NOTPARALLEL:

TARBALL := gdal-3.13.3-fedora.tar.xz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
DEBIAN_TARBALL := gdal_3.13.3+dfsg-1.pgdg24.04+1.debian.tar.xz
SOURCE_DEBIAN ?= ../SOURCES/$(DEBIAN_TARBALL)
BUILD_DIR := build
BUILD_JOBS ?= 3
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_DEBIAN)" || (echo "missing $(SOURCE_DEBIAN), run pig build get $(DEBIAN_TARBALL) first; if unavailable copy only $(DEBIAN_TARBALL) into ../SOURCES"; exit 1)
	@echo "d86f69b389d95d7b32ecc045d036ece0e054f5f28fa8a6015a23c7d30dea5826  $(SOURCE_DEBIAN)" | sha256sum -c -
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed copy $(TARBALL) into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian
	cp -a debian $(BUILD_DIR)/debian
	tar -C $(BUILD_DIR) -xf "$(SOURCE_DEBIAN)" debian/libgdal39.symbols
	@if [ "$$(lsb_release -sc)" = jammy ]; then \
		sed -i '/dh-sequence-pkgkde-symbolshelper,/d' $(BUILD_DIR)/debian/control; \
		sed -i 's/dh $$@/dh $$@ --with=pkgkde_symbolshelper/' $(BUILD_DIR)/debian/rules; \
	fi
	OS_CODENAME=$$(lsb_release -sc); sed -i "1s/1PGSTY)/1PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && DEB_BUILD_OPTIONS=parallel=$(BUILD_JOBS) dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR)
	cp *.deb $(PKG_OUTPUT_DIR)/
	find . -maxdepth 1 -type f -name '*.ddeb' -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
