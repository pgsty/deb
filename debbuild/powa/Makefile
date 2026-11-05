all: setup build move

TARBALL := powa-5.3.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL); run pig build get powa first"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar --strip-components=1 -xf "$(SOURCE_TARBALL)" -C $(BUILD_DIR)
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	sed -i "1s/PGSTY)/PGSTY~$(shell lsb_release -sc))/" $(BUILD_DIR)/debian/changelog
	cd $(BUILD_DIR) && pg_buildext updatecontrol

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR)
	find . -maxdepth 1 -type f \( -name '*.deb' -o -name '*.ddeb' \) -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.deb *.ddeb *.buildinfo *.changes

.PHONY: all check-src setup build move clean
