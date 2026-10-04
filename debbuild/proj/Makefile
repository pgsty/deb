all: check-src setup build move
.NOTPARALLEL:

TARBALL := proj-9.8.1.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
DATUMGRIDS_TARBALL := proj_9.8.1-1.pgdg24.04+1.debian.tar.xz
SOURCE_DATUMGRIDS ?= ../SOURCES/$(DATUMGRIDS_TARBALL)
BUILD_DIR := build
BUILD_JOBS ?= 3
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed copy $(TARBALL) into ../SOURCES"; exit 1)
	@test -f "$(SOURCE_DATUMGRIDS)" || (echo "missing $(SOURCE_DATUMGRIDS), run pig build get $(DATUMGRIDS_TARBALL) first; if unavailable copy only $(DATUMGRIDS_TARBALL) into ../SOURCES"; exit 1)
	@echo "4a0b97c3d6c8b4aaa451593813ffda4456648868fe4bb40c3f9b4b96a7edba2c  $(SOURCE_DATUMGRIDS)" | sha256sum -c -

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian
	cp -a debian $(BUILD_DIR)/debian
	tar -C $(BUILD_DIR) -xf "$(SOURCE_DATUMGRIDS)" debian/datumgrids.shar debian/datumgrids-ch.shar debian/libproj25.symbols
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
