all: setup build move

VERSION := 0.20.5
TARBALL := pg_net-$(VERSION).tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
SUITE ?= $(shell (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}))
SUPPORTED_SUITES := bookworm trixie noble resolute

check-suite:
	@case "$(SUITE)" in \
	  bookworm|trixie|noble|resolute) ;; \
	  *) echo "unsupported pg_net build suite: $(SUITE); pg_net $(VERSION) requires libcurl >= 7.83; supported suites: $(SUPPORTED_SUITES)" >&2; exit 1 ;; \
	esac

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get $(TARBALL) first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

setup: check-suite check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	sed -i "1s/PIGSTY)/PIGSTY~$(SUITE))/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-suite check-src setup build move clean
