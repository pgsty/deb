all: setup build move

TARBALL := pg_auditor-0.3+git20250228.7c2edff.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
SOURCE_COMMIT := 7c2edff7a09c5882bfc8f1f8aa8f8d5d7e3b0c41
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

# prepare directory
setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

# building deb
build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup update build move clean ls
