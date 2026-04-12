all: setup build move

TARBALL := apache-datasketches-postgresql-1.7.0-src.tar.gz
CORE_TARBALL := apache-datasketches-cpp-5.0.0-src.tar.gz
CORE_SOURCE_DIR := apache-datasketches-cpp-5.0.0-src
SOURCE_DIR ?= $(or $(wildcard $(HOME)/pgsty/repo/ext/src),../SOURCES)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_DIR)/$(TARBALL)" || (echo "missing $(SOURCE_DIR)/$(TARBALL)"; exit 1)
	@test -f "$(SOURCE_DIR)/$(CORE_TARBALL)" || (echo "missing $(SOURCE_DIR)/$(CORE_TARBALL)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_DIR)/$(TARBALL)"
	tar -C $(BUILD_DIR) -xf "$(SOURCE_DIR)/$(CORE_TARBALL)"
	ln -sfn $(CORE_SOURCE_DIR) $(BUILD_DIR)/datasketches-cpp
	ln -sfn /usr/include $(BUILD_DIR)/boost
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
