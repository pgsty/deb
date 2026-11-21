all: move

VERSION := 1.5.6
ARCH := $(shell dpkg-architecture -qDEB_HOST_ARCH)
ifeq ($(ARCH),arm64)
TARBALL := libduckdb-$(VERSION)-arm64.tar.gz
else ifeq ($(ARCH),amd64)
TARBALL := libduckdb-$(VERSION)-amd64.tar.gz
else
$(error unsupported libduckdb architecture: $(ARCH))
endif
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

# prepare directory
setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR)/ -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

# building deb
build: setup
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

# collect deb
move: build
	mkdir -p "$(PKG_OUTPUT_DIR)"
	cp *.deb "$(PKG_OUTPUT_DIR)/"
	set -e; for pkg in *.ddeb; do \
		if test -f "$$pkg"; then cp "$$pkg" "$(PKG_OUTPUT_DIR)/"; fi; \
	done

# remove building craps
clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
