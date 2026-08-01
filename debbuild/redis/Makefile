all: setup build move

VERSION := 7.2.15
TARBALL := redis-$(VERSION).tar.gz
SOURCEDIR ?= ../SOURCES
SOURCE := $(SOURCEDIR)/$(TARBALL)
SOURCE_URL := https://download.redis.io/releases/$(TARBALL)
SOURCE_SHA256 := 7bf7975331511fdb788e85dae63964b128fccee1df026a10db57444babc9c9c4
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
		if command -v curl >/dev/null 2>&1; then \
			curl -fL "$(SOURCE_URL)" -o "$(SOURCE)"; \
		else \
			wget -O "$(SOURCE)" "$(SOURCE_URL)"; \
		fi; \
	fi

verify: $(SOURCE)
	echo "$(SOURCE_SHA256)  $(SOURCE)" | sha256sum -c -

# prepare directory
setup: verify
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf $(SOURCE)
	rm -rf build/debian; cp -r debian build/debian
	sed -i "s/@RELEASE@/$(OS_CODENAME)/g" build/debian/changelog
	chmod +x build/debian/rules
	cd build && QUILT_PATCHES=debian/patches quilt push -a

# build redis, redis-dev, and redis-dbgsym
build:
	cd build && DEB_BUILD_OPTIONS="$(DEB_BUILD_OPTIONS)" dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg
	@set -e; found=0; for pkg in ./*.deb ./*.ddeb; do \
		[ -e "$$pkg" ] || continue; cp "$$pkg" ~/ext/pkg/; found=1; \
	done; test "$$found" -eq 1

# remove build artifacts
clean:
	rm -rf build *.buildinfo *.changes *.ddeb *.deb

.PHONY: all deps verify setup build move clean
