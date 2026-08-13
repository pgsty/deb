.NOTPARALLEL:

all: setup build verify move

VERSION := 1.2.42
DEB_RELEASE ?= 1PGSTY
ZLOG_VERSION := 1.2.18
PFS_COMMIT := d0c5dc6
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
TARBALL := polarstore-$(VERSION)-$(PFS_COMMIT).tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
DETECTED_CODENAME := $(shell (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-}}))
DETECTED_ARCH := $(shell dpkg --print-architecture 2>/dev/null)
DISTRO_CODENAME ?= $(DETECTED_CODENAME)
DEB_ARCH ?= $(DETECTED_ARCH)
DEB_FILE = polarstore_$(VERSION)-$(DEB_RELEASE)~$(DISTRO_CODENAME)_$(DEB_ARCH).deb

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

check-release:
	@printf '%s\n' "$(DEB_RELEASE)" | grep -Eq '^[1-9][0-9]*PGSTY$$' || \
		(echo "invalid DEB_RELEASE=$(DEB_RELEASE), expected <positive integer>PGSTY"; exit 1)

check-platform:
	@printf '%s\n' "$(DISTRO_CODENAME)" | grep -Eq '^(bookworm|trixie|jammy|noble|resolute)$$' || \
		(echo "invalid DISTRO_CODENAME=$(DISTRO_CODENAME), expected bookworm, trixie, jammy, noble, or resolute"; exit 1)
	@printf '%s\n' "$(DEB_ARCH)" | grep -Eq '^(amd64|arm64)$$' || \
		(echo "invalid DEB_ARCH=$(DEB_ARCH), expected amd64 or arm64"; exit 1)
	@test "$(DISTRO_CODENAME)" = "$(DETECTED_CODENAME)" || \
		(echo "DISTRO_CODENAME=$(DISTRO_CODENAME) does not match builder $(DETECTED_CODENAME)"; exit 1)
	@test "$(DEB_ARCH)" = "$(DETECTED_ARCH)" || \
		(echo "DEB_ARCH=$(DEB_ARCH) does not match builder $(DETECTED_ARCH)"; exit 1)

print-package-name: check-release check-platform
	@printf '%s\n' "$(DEB_FILE)"

setup: check-src check-release check-platform
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	test -f $(BUILD_DIR)/src/pfs_sdk/pfsd_sdk.h
	test -f $(BUILD_DIR)/src/pfs_sdk/pfsd_sdk.cc
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	sed -i "1s/-[0-9][0-9]*PGSTY)/-$(DEB_RELEASE)~$(DISTRO_CODENAME))/" $(BUILD_DIR)/debian/changelog
	grep -Fq "($(VERSION)-$(DEB_RELEASE)~$(DISTRO_CODENAME))" $(BUILD_DIR)/debian/changelog

check-zlog:
	@test "$$(dpkg-query -W -f='$${Version}' zlog 2>/dev/null)" = "$(ZLOG_VERSION)-$(DEB_RELEASE)~$(DISTRO_CODENAME)" || \
		(echo "installed zlog is not $(ZLOG_VERSION)-$(DEB_RELEASE)~$(DISTRO_CODENAME)"; exit 1)

build: check-zlog
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

verify:
	@test -f "$(DEB_FILE)" || (echo "missing expected package $(DEB_FILE)"; exit 1)
	@test "$$(dpkg-deb -f "$(DEB_FILE)" Package)" = "polarstore"
	@test "$$(dpkg-deb -f "$(DEB_FILE)" Version)" = "$(VERSION)-$(DEB_RELEASE)~$(DISTRO_CODENAME)"
	@test "$$(dpkg-deb -f "$(DEB_FILE)" Architecture)" = "$(DEB_ARCH)"
	@dpkg-deb -c "$(DEB_FILE)" | awk '$$NF == "./usr/local/polarstore/pfsd/include/pfsd_sdk.h" { found=1 } END { exit !found }'
	@dpkg-deb -c "$(DEB_FILE)" | awk '$$NF == "./usr/local/polarstore/pfsd/lib/libpfsd.a" { found=1 } END { exit !found }'

move: verify
	mkdir -p $(PKG_OUTPUT_DIR) && cp "$(DEB_FILE)" $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src check-release check-platform print-package-name check-zlog setup build verify move clean
