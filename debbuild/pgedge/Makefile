include versions.mk

all: setup build move

PG_TARBALL := postgresql-$(PG_VERSION).tar.gz
SPOCK_TARBALL := spock-$(SPOCK_VERSION).tar.gz
BUILD_DIR := build

check-src:
	@test -f "$(SOURCE_DIR)/$(PG_TARBALL)" || (echo "missing $(SOURCE_DIR)/$(PG_TARBALL), run: pig build get -m $(PG_TARBALL)"; exit 1)
	@test -f "$(SOURCE_DIR)/$(SPOCK_TARBALL)" || (echo "missing $(SOURCE_DIR)/$(SPOCK_TARBALL), run: pig build get -m $(SPOCK_TARBALL)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf $(SOURCE_DIR)/$(PG_TARBALL)
	mkdir -p $(BUILD_DIR)/.spock-src
	tar -C $(BUILD_DIR)/.spock-src --strip-components=1 -xf $(SOURCE_DIR)/$(SPOCK_TARBALL)
	cd $(BUILD_DIR) && \
		PATCH_DIR=""; \
		if [ -d .spock-src/patches/pg17 ]; then PATCH_DIR=.spock-src/patches/pg17; \
		elif [ -d .spock-src/patches/17 ]; then PATCH_DIR=.spock-src/patches/17; \
		else echo "unable to find pg17 patch directory in spock source"; exit 1; fi; \
		for p in $$(find "$$PATCH_DIR" -maxdepth 1 -type f -name '*.diff' | sort); do \
			echo "apply $$p"; \
			patch -p1 < "$$p"; \
		done
	rm -rf $(BUILD_DIR)/.spock-src
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	sed -i -E "1s/\([^)]+\)/($(PG_VERSION)-$(PKG_REV))/" $(BUILD_DIR)/debian/changelog
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && SPOCK_VERSION=$(SPOCK_VERSION) dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
