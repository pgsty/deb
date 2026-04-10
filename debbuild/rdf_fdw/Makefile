all: setup build move

TARBALL := rdf_fdw-2.4.0.zip
SOURCE_DIR ?= $(or $(wildcard $(HOME)/pgsty/repo/ext/src),../SOURCES)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_DIR)/$(TARBALL)" || (echo "missing $(SOURCE_DIR)/$(TARBALL), place the source zip from RPM under $(SOURCE_DIR)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR) $(BUILD_DIR).src; mkdir -p $(BUILD_DIR) $(BUILD_DIR).src
	unzip -q "$(SOURCE_DIR)/$(TARBALL)" -d $(BUILD_DIR).src
	dir=$$(find $(BUILD_DIR).src -mindepth 1 -maxdepth 1 -type d ! -name '__MACOSX' | head -n1); \
	test -n "$$dir"; \
	cp -R "$$dir"/. $(BUILD_DIR)/
	rm -rf $(BUILD_DIR).src $(BUILD_DIR)/__MACOSX
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) $(BUILD_DIR).src *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
