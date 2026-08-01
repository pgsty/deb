all: setup build move

VERSION := 9.1.1
TARBALL := valkey-$(VERSION).tar.gz
SOURCEDIR ?= ../SOURCES
SOURCE := $(SOURCEDIR)/$(TARBALL)
SOURCE_URL := https://github.com/valkey-io/valkey/archive/refs/tags/$(VERSION).tar.gz
SOURCE_SHA256 := 7d7232acd1b8a49b4e05d07a00b3ca8c801ae06ab633ca6a3423bc5f385ab7ee
OS_CODENAME ?= $(shell command -v lsb_release >/dev/null 2>&1 && lsb_release -sc || (. /etc/os-release 2>/dev/null && echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) || echo unknown)
DEB_BUILD_OPTIONS ?= parallel=$(shell nproc)

deps:
	apt-get update
	apt-get install -y build-essential ca-certificates curl debhelper dpkg-dev libssl-dev libsystemd-dev lsb-release openssl pkgconf procps quilt tcl tcl-tls

$(SOURCE):
	mkdir -p $(SOURCEDIR)
	@if command -v pig >/dev/null 2>&1; then \
		pig build get $(TARBALL) || true; \
	fi
	@if [ ! -f "$(SOURCE)" ]; then \
		for f in "$$HOME/ext/src/$(TARBALL)" "$$HOME/pgsty/repo/ext/src/$(TARBALL)" "/Users/vonng/pgsty/repo/ext/src/$(TARBALL)"; do \
			if [ -f "$$f" ]; then cp "$$f" "$(SOURCE)"; exit 0; fi; \
		done; \
		curl -fL "$(SOURCE_URL)" -o "$(SOURCE)"; \
	fi

verify: $(SOURCE)
	echo "$(SOURCE_SHA256)  $(SOURCE)" | sha256sum -c -

setup: verify
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf $(SOURCE)
	rm -rf build/debian; cp -r debian build/debian
	sed -i "s/@RELEASE@/$(OS_CODENAME)/g" build/debian/changelog
	chmod +x build/debian/rules
	cd build && QUILT_PATCHES=debian/patches quilt push -a

build:
	cd build && DEB_BUILD_OPTIONS="$(DEB_BUILD_OPTIONS)" dpkg-buildpackage -b -us -uc

move:
	mkdir -p ~/ext/pkg
	@set -e; found=0; for pkg in ./*.deb ./*.ddeb; do \
		[ -e "$$pkg" ] || continue; cp "$$pkg" ~/ext/pkg/; found=1; \
	done; test "$$found" -eq 1

clean:
	rm -rf build *.buildinfo *.changes *.ddeb *.deb

.PHONY: all deps verify setup build move clean
