all: check-src setup build move
.NOTPARALLEL:

TARBALL := geos-3.14.1.tar.bz2
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
DEBIAN_TARBALL := geos_3.14.1-2.pgdg24.04+1.debian.tar.xz
SOURCE_DEBIAN ?= ../SOURCES/$(DEBIAN_TARBALL)
BUILD_DIR := build
BUILD_JOBS ?= 3
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_DEBIAN)" || (echo "missing $(SOURCE_DEBIAN), run pig build get $(DEBIAN_TARBALL) first; if unavailable copy only $(DEBIAN_TARBALL) into ../SOURCES"; exit 1)
	@echo "7a41e68ce6679c15271ee3fcc3cb745c7271c8cc437eacbd3ca3487ab6c4e766  $(SOURCE_DEBIAN)" | sha256sum -c -
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed copy $(TARBALL) into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian
	cp -a debian $(BUILD_DIR)/debian
	tar -C $(BUILD_DIR) -xf "$(SOURCE_DEBIAN)" debian/libgeos3.14.1.symbols debian/libgeos-c1t64.symbols
	@if [ "$$(lsb_release -sc)" = jammy ] || [ "$$(lsb_release -sc)" = bookworm ]; then \
		sed -i -e 's/libgeos-c1t64/libgeos-c1v5/g' -e '/dpkg-dev (>= 1.22.5),/d' -e '/^Provides: $${t64:Provides}/d' -e '/^Breaks: libgeos-c1v5/d' -e '/^Replaces: libgeos-c1v5/d' -e '/^X-Time64-Compat:/d' $(BUILD_DIR)/debian/control; \
		for f in $(BUILD_DIR)/debian/libgeos-c1t64.*; do sed -i 's/libgeos-c1t64/libgeos-c1v5/g' "$$f"; mv "$$f" "$$(printf '%s' "$$f" | sed 's/libgeos-c1t64/libgeos-c1v5/g')"; done; \
	fi
	@if [ "$$(lsb_release -sc)" = jammy ]; then \
		sed -i '/dh-sequence-pkgkde-symbolshelper,/d' $(BUILD_DIR)/debian/control; \
		sed -i 's/--builddirectory=build/--with=pkgkde_symbolshelper --builddirectory=build/' $(BUILD_DIR)/debian/rules; \
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
