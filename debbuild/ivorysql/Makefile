include versions.mk

all: setup build move

BUILD_DIR := build

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run: pig build get $(TARBALL); if needed, copy $(TARBALL) into $(SOURCE_DIR)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	find $(BUILD_DIR)/debian -type f -exec perl -pi -e \
		's/\@PG_MAJOR\@/$(PG_MAJOR)/g; s/\@PG_VERSION\@/$(PG_VERSION)/g; s/\@IVORY_MAJOR\@/$(IVORY_MAJOR)/g; s/\@IVORY_VERSION\@/$(IVORY_VERSION)/g; s/\@PKG_REV\@/$(PKG_REV)/g' {} +
	OS_CODENAME=$$(lsb_release -sc 2>/dev/null || true); \
	if [ -z "$$OS_CODENAME" ] && [ -r /etc/os-release ]; then \
		. /etc/os-release; \
		OS_CODENAME=$${VERSION_CODENAME:-$${UBUNTU_CODENAME:-}}; \
	fi; \
	OS_CODENAME=$${OS_CODENAME:-unknown}; \
	perl -pi -e 'if ($$. == 1) { s/PIGSTY\)/PIGSTY~'"$${OS_CODENAME}"'\)/ }' $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp $(PACKAGE)_*.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

ivorysql-18:
	$(MAKE) PG_MAJOR=18 all

.PHONY: all check-src setup build move clean ivorysql-18
