all: setup build move

BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
SUITE ?= $(shell (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}))

ifeq ($(SUITE),jammy)
VERSION := 0.9.2
PACKAGING_OVERLAY := debian-legacy
else
VERSION := 0.20.5
PACKAGING_OVERLAY :=
endif

TARBALL := pg_net-$(VERSION).tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
SUPPORTED_SUITES := bookworm trixie jammy noble resolute

check-suite:
	@case "$(SUITE)" in \
	  bookworm|trixie|jammy|noble|resolute) ;; \
	  *) echo "unsupported pg_net build suite: $(SUITE); supported suites: $(SUPPORTED_SUITES)" >&2; exit 1 ;; \
	esac

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get $(TARBALL) first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

setup: check-suite check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	if [ -n "$(PACKAGING_OVERLAY)" ]; then \
		cp $(PACKAGING_OVERLAY)/changelog $(BUILD_DIR)/debian/changelog; \
		cp $(PACKAGING_OVERLAY)/control.in $(BUILD_DIR)/debian/control.in; \
	fi
	sed -i "1s/PGSTY)/PGSTY~$(SUITE))/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-suite check-src setup build move clean
