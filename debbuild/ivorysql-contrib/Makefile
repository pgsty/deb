include versions.mk

all: setup build verify move

BUILD_DIR := build

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL); copy $(TARBALL) into $(SOURCE_DIR)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	cp -p ivorysql-contrib-build.sh sfcgal-config-pkgconf $(BUILD_DIR)/
	cp -p EXTENSIONS.md $(BUILD_DIR)/
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	find $(BUILD_DIR)/debian -type f -exec perl -pi -e \
		's/\@PG_MAJOR\@/$(PG_MAJOR)/g; s/\@IVORY_MAJOR\@/$(IVORY_MAJOR)/g; s/\@IVORY_VERSION\@/$(IVORY_VERSION)/g; s/\@PKG_REV\@/$(PKG_REV)/g' {} +
	OS_CODENAME=$$(lsb_release -sc 2>/dev/null || true); \
	if [ -z "$$OS_CODENAME" ] && [ -r /etc/os-release ]; then \
		. /etc/os-release; \
		OS_CODENAME=$${VERSION_CODENAME:-$${UBUNTU_CODENAME:-}}; \
	fi; \
	OS_CODENAME=$${OS_CODENAME:-unknown}; \
	perl -pi -e 'if ($$. == 1) { s/PIGSTY\)/PIGSTY~'"$${OS_CODENAME}"'\)/ }' $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

verify:
	@deb=$$(ls $(PACKAGE)_*.deb); \
	actual=$$(dpkg-deb -f "$$deb" Depends | tr ',' '\n' | \
		sed -E 's/^[[:space:]]+//; s/[[:space:]]+$$//' | \
		grep '^ivorysql-$(PG_MAJOR) ' | LC_ALL=C sort); \
	expected=$$(printf '%s\n' \
		'ivorysql-$(PG_MAJOR) (<< 6.0)' \
		'ivorysql-$(PG_MAJOR) (>= 5.0)' | LC_ALL=C sort); \
	printf '%s\n' "$$actual"; \
	test "$$actual" = "$$expected"

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp $(PACKAGE)_*.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

ivorysql-18-contrib:
	$(MAKE) PG_MAJOR=18 all

.PHONY: all check-src setup build verify move clean ivorysql-18-contrib
