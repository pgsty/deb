all: setup build move

# Keep the filename normalized because the local archive is repacked from the
# upstream PGXN zip release into a tarball for builder compatibility.
TARBALL := pg_stat_ch-0.4.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
VCPKG_COMMIT := cd61e1e26a038e82d6550a3ebbe0fbbfe7da78e3
VCPKG_ROOT ?= $(HOME)/.cache/pg_stat_ch/vcpkg-$(VCPKG_COMMIT)
VCPKG_BINARY_CACHE ?= $(HOME)/.cache/pg_stat_ch/vcpkg-archives
PATCHES := $(sort $(wildcard patches/*.patch))

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	@set -e; for p in $(PATCHES); do echo "apply $$p"; (cd $(BUILD_DIR) && patch -p1 < "../$$p"); done
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

vcpkg: setup
	@set -e; \
	if [ ! -d "$(VCPKG_ROOT)/.git" ]; then \
		mkdir -p "$$(dirname "$(VCPKG_ROOT)")"; \
		git init -q "$(VCPKG_ROOT)"; \
		git -C "$(VCPKG_ROOT)" remote add origin https://github.com/microsoft/vcpkg.git; \
		git -C "$(VCPKG_ROOT)" fetch --depth=1 origin "$(VCPKG_COMMIT)"; \
		git -C "$(VCPKG_ROOT)" checkout -q --detach FETCH_HEAD; \
	fi
	@test "$$(git -C "$(VCPKG_ROOT)" rev-parse HEAD)" = "$(VCPKG_COMMIT)"
	@if [ ! -x "$(VCPKG_ROOT)/vcpkg" ]; then cd "$(VCPKG_ROOT)" && ./bootstrap-vcpkg.sh -disableMetrics; fi
	mkdir -p "$(VCPKG_BINARY_CACHE)"

build: vcpkg
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && \
		VCPKG_ROOT="$(VCPKG_ROOT)" \
		VCPKG_DISABLE_METRICS=1 \
		VCPKG_DEFAULT_BINARY_CACHE="$(VCPKG_BINARY_CACHE)" \
		dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup vcpkg build move clean
