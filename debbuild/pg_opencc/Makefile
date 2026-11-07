all: move

TARBALL := pg_opencc-0.1.0.tar.gz
TARBALL_SHA256 := 969440046835bda4c785cea88efa9062aff5c3ba61fee1c7036ccc381d95f282
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get pg_opencc first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)
	@printf '%s  %s\n' '$(TARBALL_SHA256)' '$(SOURCE_TARBALL)' | sha256sum --check --status

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$(lsb_release -sc); \
		test -n "$$OS_CODENAME" && sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: setup
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move: build
	mkdir -p "$(PKG_OUTPUT_DIR)"
	@set -e; files=$$(find . -maxdepth 1 -type f \( -name '*.deb' -o -name '*.ddeb' \)); test -n "$$files"; cp $$files "$(PKG_OUTPUT_DIR)/"

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
