all: check-src setup build move
.NOTPARALLEL:

TARBALL := apache-arrow-9.0.0.tar.gz
XSIMD_TARBALL := xsimd-8.1.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
BUILD_JOBS ?= 3
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed copy $(TARBALL) into ../SOURCES"; exit 1)
	@test -f "../SOURCES/$(XSIMD_TARBALL)" || (echo "missing ../SOURCES/$(XSIMD_TARBALL), run pig build get first"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian
	cp -a debian $(BUILD_DIR)/debian
	cp ../SOURCES/$(XSIMD_TARBALL) $(BUILD_DIR)/debian/
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
