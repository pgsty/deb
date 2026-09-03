CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

all: setup build move

TARBALL := pgdog-0.1.56.tar.gz
VENDOR_TARBALL := pgdog-0.1.56-vendor.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
VENDOR_SOURCE_TARBALL ?= ../SOURCES/$(VENDOR_TARBALL)
SOURCE_PATCH := patches/pgdog-0.1.56.patch
RUST_TOOLCHAIN := 1.96.1
PGDOG_GIT_HASH := 5d81522
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get pgdog first; if stale, copy only $(TARBALL)"; exit 1)
	@test -f "$(VENDOR_SOURCE_TARBALL)" || (echo "missing $(VENDOR_SOURCE_TARBALL); copy only $(VENDOR_TARBALL) into ../SOURCES"; exit 1)
	@test -f "$(SOURCE_PATCH)" || (echo "missing $(SOURCE_PATCH)"; exit 1)

# prepare directory
setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	mkdir -p $(BUILD_DIR)/vendor
	tar -C $(BUILD_DIR)/vendor --strip-components=1 -xf "$(VENDOR_SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	@(cd $(BUILD_DIR) && patch -p1 --fuzz=0 < "../$(SOURCE_PATCH)")
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

# building deb
build:
	cd $(BUILD_DIR) && RUSTUP_TOOLCHAIN=$(RUST_TOOLCHAIN) cargo fetch --locked
	cd $(BUILD_DIR) && RUSTUP_TOOLCHAIN=$(RUST_TOOLCHAIN) PGDOG_GIT_HASH=$(PGDOG_GIT_HASH) dpkg-buildpackage -b -us -uc -d

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

# remove building craps
clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
