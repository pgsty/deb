all: setup build move

TARBALL := multicorn2-3.2.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
SOURCE_PATCH := patches/multicorn2-3.2-debian-build.patch
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

check-patches:
	@test -f "$(SOURCE_PATCH)" || (echo "missing $(SOURCE_PATCH), keep patch name aligned with $(TARBALL)"; exit 1)

setup: check-src check-patches
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	patch -d $(BUILD_DIR) -p1 --forward -f < "$(SOURCE_PATCH)"
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	OS_CODENAME=$$(lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p "$(PKG_OUTPUT_DIR)" && cp *.deb "$(PKG_OUTPUT_DIR)"

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup build move clean check-src check-patches
