all: check-src setup build move
.NOTPARALLEL:

TARBALL := libspatialite-5.1.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
BUILD_JOBS ?= 3
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed copy $(TARBALL) into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian
	cp -a debian $(BUILD_DIR)/debian
	@if [ "$$(lsb_release -sc)" = jammy ] || [ "$$(lsb_release -sc)" = bookworm ]; then \
		sed -i -e 's/libspatialite8t64/libspatialite8/g' -e '/dpkg-dev (>= 1.22.5),/d' -e '/^Provides: $${t64:Provides}/d' -e '/^Breaks: libspatialite8 /d' -e '/^Replaces: libspatialite8$$/d' $(BUILD_DIR)/debian/control; \
		for f in $(BUILD_DIR)/debian/libspatialite8t64.*; do sed -i 's/libspatialite8t64/libspatialite8/g' "$$f"; mv "$$f" "$$(printf '%s' "$$f" | sed 's/libspatialite8t64/libspatialite8/g')"; done; \
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
