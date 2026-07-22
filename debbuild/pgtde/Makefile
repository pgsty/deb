include versions.mk

all: setup build move

BUILD_DIR := build

check-src:
	@test -f "$(CORE_SOURCE)" || (echo "missing $(CORE_SOURCE), run: pig build get $(CORE_TARBALL); if needed, copy only $(CORE_TARBALL) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(TDE_SOURCE)" || (echo "missing $(TDE_SOURCE), run: pig build get $(TDE_TARBALL); if needed, copy only $(TDE_TARBALL) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(PG_CONFIG_SOURCE)" || (echo "missing $(PG_CONFIG_SOURCE), copy only $(PG_CONFIG_WRAPPER) into $(SOURCE_DIR)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(CORE_SOURCE)"
	tar -C $(BUILD_DIR) -xf "$(TDE_SOURCE)"
	mv $(BUILD_DIR)/percona-pg_tde$(PG_MAJOR)-$(PGTDE_VERSION) $(BUILD_DIR)/.pg_tde-src
	cp "$(PG_CONFIG_SOURCE)" $(BUILD_DIR)/.pgtde-pg-config
	chmod 0755 $(BUILD_DIR)/.pgtde-pg-config
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	find $(BUILD_DIR)/debian -type f -exec perl -pi -e \
		's/\@PG_MAJOR\@/$(PG_MAJOR)/g; s/\@PG_VERSION\@/$(PG_VERSION)/g; s/\@PERCONA_RELEASE\@/$(PERCONA_RELEASE)/g; s/\@PGTDE_VERSION\@/$(PGTDE_VERSION)/g; s/\@PKG_REV\@/$(PKG_REV)/g' {} +
	OS_CODENAME=$$(lsb_release -sc 2>/dev/null || true); \
	if [ -z "$$OS_CODENAME" ] && [ -r /etc/os-release ]; then \
		. /etc/os-release; \
		OS_CODENAME=$${VERSION_CODENAME:-$${UBUNTU_CODENAME:-}}; \
	fi; \
	OS_CODENAME=$${OS_CODENAME:-unknown}; \
	perl -pi -e 'if ($$. == 1) { s/PIGSTY\)/PIGSTY~'"$${OS_CODENAME}"'\)/; s/\) unstable;/\) '"$${OS_CODENAME}"';/ }' $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR)
	cp $(PACKAGE)_*.deb $(PACKAGE)-contrib_*.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

pgtde-18:
	$(MAKE) PG_MAJOR=18 all

.PHONY: all check-src setup build move clean pgtde-18
