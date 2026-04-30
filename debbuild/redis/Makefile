all: setup build move

VERSION := 7.2.7
TARBALL := redis-$(VERSION).tar.gz
SOURCEDIR ?= ../SOURCES
SOURCE := $(SOURCEDIR)/$(TARBALL)
SOURCE_URL := https://download.redis.io/releases/$(TARBALL)
SOURCE_SHA256 := 72c081e3b8cfae7144273d26d76736f08319000af46c01515cad5d29765cead5
OS_CODENAME ?= $(shell command -v lsb_release >/dev/null 2>&1 && lsb_release -sc || (. /etc/os-release 2>/dev/null && echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) || echo unknown)

deps:
	apt-get update
	apt-get install -y build-essential ca-certificates curl debhelper dpkg-dev libssl-dev libsystemd-dev lsb-release pkg-config

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
	echo "$(SOURCE_SHA256)  $(SOURCE)" | sha256sum -c -

# prepare directory
setup: $(SOURCE)
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf $(SOURCE)
	rm -rf build/debian; cp -r debian build/debian
	sed -i "s/@RELEASE@/$(OS_CODENAME)/g" build/debian/changelog
	chmod +x build/debian/rules build/debian/bin/generate-systemd-service-files

# build redis, redis-server, redis-sentinel, redis-tools
build:
	cd build && DEB_BUILD_PROFILES=nocheck dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove build artifacts
clean:
	rm -rf build *.buildinfo *.changes *.ddeb *.deb

.PHONY: all deps setup build move clean
