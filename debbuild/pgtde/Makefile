include versions.mk

all: setup build move

BUILD_DIR := build

check-src:
	@test -f "$(CORE_SOURCE)" || (echo "missing $(CORE_SOURCE), run: pig build get $(CORE_TARBALL); if needed, copy only $(CORE_TARBALL) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(TDE_SOURCE)" || (echo "missing $(TDE_SOURCE), run: pig build get $(TDE_TARBALL); if needed, copy only $(TDE_TARBALL) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(PG_CONFIG_SOURCE)" || (echo "missing $(PG_CONFIG_SOURCE), copy only $(PG_CONFIG_WRAPPER) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(SFCGAL_CONFIG_SOURCE)" || (echo "missing $(SFCGAL_CONFIG_SOURCE), copy only $(SFCGAL_CONFIG_WRAPPER) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(POSTGIS_SOURCE)" || (echo "missing $(POSTGIS_SOURCE), copy only $(POSTGIS_TARBALL) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(PGVECTOR_SOURCE)" || (echo "missing $(PGVECTOR_SOURCE), copy only $(PGVECTOR_TARBALL) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(WAL2JSON_SOURCE)" || (echo "missing $(WAL2JSON_SOURCE), copy only $(WAL2JSON_TARBALL) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(PGREPACK_SOURCE)" || (echo "missing $(PGREPACK_SOURCE), copy only $(PGREPACK_TARBALL) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(PGAUDIT_SOURCE)" || (echo "missing $(PGAUDIT_SOURCE), copy only $(PGAUDIT_TARBALL) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(SET_USER_SOURCE)" || (echo "missing $(SET_USER_SOURCE), copy only $(SET_USER_TARBALL) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(PG_STAT_MONITOR_SOURCE)" || (echo "missing $(PG_STAT_MONITOR_SOURCE), copy only $(PG_STAT_MONITOR_TARBALL) into $(SOURCE_DIR)"; exit 1)
	@test -f "$(PG_GATHER_SOURCE)" || (echo "missing $(PG_GATHER_SOURCE), copy only $(PG_GATHER_TARBALL) into $(SOURCE_DIR)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(CORE_SOURCE)"
	tar -C $(BUILD_DIR) -xf "$(TDE_SOURCE)"
	mv $(BUILD_DIR)/percona-pg_tde$(PG_MAJOR)-$(PGTDE_VERSION) $(BUILD_DIR)/.pg_tde-src
	tar -C $(BUILD_DIR) -xf "$(POSTGIS_SOURCE)"
	mv $(BUILD_DIR)/percona-postgis-$(POSTGIS_VERSION) $(BUILD_DIR)/.postgis-src
	tar -C $(BUILD_DIR) -xf "$(PGVECTOR_SOURCE)"
	mv $(BUILD_DIR)/percona-pgvector_$(PG_MAJOR)-$(PGVECTOR_VERSION) $(BUILD_DIR)/.pgvector-src
	tar -C $(BUILD_DIR) -xf "$(WAL2JSON_SOURCE)"
	mv $(BUILD_DIR)/percona-wal2json-$(WAL2JSON_VERSION) $(BUILD_DIR)/.wal2json-src
	tar -C $(BUILD_DIR) -xf "$(PGREPACK_SOURCE)"
	mv $(BUILD_DIR)/percona-pg_repack-$(PGREPACK_VERSION) $(BUILD_DIR)/.pg_repack-src
	tar -C $(BUILD_DIR) -xf "$(PGAUDIT_SOURCE)"
	mv $(BUILD_DIR)/percona-pgaudit-$(PGAUDIT_VERSION) $(BUILD_DIR)/.pgaudit-src
	tar -C $(BUILD_DIR) -xf "$(SET_USER_SOURCE)"
	mv $(BUILD_DIR)/percona-pgaudit$(PG_MAJOR)_set_user-$(SET_USER_VERSION) $(BUILD_DIR)/.set_user-src
	tar -C $(BUILD_DIR) -xf "$(PG_STAT_MONITOR_SOURCE)"
	mv $(BUILD_DIR)/percona-pg-stat-monitor$(PG_MAJOR)-$(PG_STAT_MONITOR_VERSION) $(BUILD_DIR)/.pg_stat_monitor-src
	tar -C $(BUILD_DIR) -xf "$(PG_GATHER_SOURCE)"
	mv $(BUILD_DIR)/percona-pg_gather-$(PG_GATHER_VERSION) $(BUILD_DIR)/.pg_gather-src
	cp "$(PG_CONFIG_SOURCE)" $(BUILD_DIR)/.pgtde-pg-config
	chmod 0755 $(BUILD_DIR)/.pgtde-pg-config
	cp "$(SFCGAL_CONFIG_SOURCE)" $(BUILD_DIR)/.pgtde-sfcgal-config
	chmod 0755 $(BUILD_DIR)/.pgtde-sfcgal-config
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
