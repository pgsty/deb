all: move

TARBALL := pgmemento-0.7.4.tar.gz
TARBALL_SHA256 := 882f83862ae953b35c9c1ad65becc871e4fe5e32857743c716f1fd6379dc02bc
SOURCE_TARBALL ?= $(or $(wildcard $(HOME)/ext/src/$(TARBALL)),$(wildcard ../SOURCES/$(TARBALL)))
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing $(TARBALL) under $(HOME)/ext/src or ../SOURCES, run pig build get first; if needed, copy it there"; exit 1)
	@printf '%s  %s\n' '$(TARBALL_SHA256)' '$(SOURCE_TARBALL)' | sha256sum --check --status || (echo "SHA-256 mismatch for $(SOURCE_TARBALL)"; exit 1)

clean-artifacts:
	rm -f *.deb *.ddeb *.buildinfo *.changes

setup: clean-artifacts check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: setup
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move: build
	mkdir -p $(PKG_OUTPUT_DIR)
	@set -e; files=$$(find . -maxdepth 1 -type f \( -name '*.deb' -o -name '*.ddeb' \)); test -n "$$files"; cp $$files $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src clean-artifacts setup build move clean
