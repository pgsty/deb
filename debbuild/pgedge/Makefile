include versions.mk

all: setup build move

PG_TARBALL := postgresql-$(PG_VERSION).tar.gz
SPOCK_TARBALL := spock-$(SPOCK_VERSION).tar.gz
LOLOR_TARBALL := lolor-$(LOLOR_VERSION).tar.gz
SNOWFLAKE_TARBALL := snowflake-$(SNOWFLAKE_VERSION).tar.gz
SPOCK_PATCHSET_REBASE := patches/pgedge-spock-5.0.11-pg17-pg18.patch
BUILD_DIR := build

check-src:
	@test -f "$(SOURCE_DIR)/$(PG_TARBALL)" || (echo "missing $(SOURCE_DIR)/$(PG_TARBALL), run: pig build get -m $(PG_TARBALL)"; exit 1)
	@test -f "$(SOURCE_DIR)/$(SPOCK_TARBALL)" || (echo "missing $(SOURCE_DIR)/$(SPOCK_TARBALL), run: pig build get -m $(SPOCK_TARBALL)"; exit 1)
	@test -f "$(SOURCE_DIR)/$(LOLOR_TARBALL)" || (echo "missing $(SOURCE_DIR)/$(LOLOR_TARBALL), run: pig build get -m $(LOLOR_TARBALL)"; exit 1)
	@test -f "$(SOURCE_DIR)/$(SNOWFLAKE_TARBALL)" || (echo "missing $(SOURCE_DIR)/$(SNOWFLAKE_TARBALL), run: pig build get -m $(SNOWFLAKE_TARBALL)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf $(SOURCE_DIR)/$(PG_TARBALL)
	mkdir -p $(BUILD_DIR)/.spock $(BUILD_DIR)/.lolor $(BUILD_DIR)/.snowflake
	tar -C $(BUILD_DIR)/.spock --strip-components=1 -xf $(SOURCE_DIR)/$(SPOCK_TARBALL)
	tar -C $(BUILD_DIR)/.lolor --strip-components=1 -xf $(SOURCE_DIR)/$(LOLOR_TARBALL)
	tar -C $(BUILD_DIR)/.snowflake --strip-components=1 -xf $(SOURCE_DIR)/$(SNOWFLAKE_TARBALL)
	@test "$(SPOCK_VERSION)" = "5.0.11" || (echo "rebase $(SPOCK_PATCHSET_REBASE) is specific to Spock 5.0.11"; exit 1)
	patch -d $(BUILD_DIR)/.spock -p1 --fuzz=0 < $(SPOCK_PATCHSET_REBASE)
	cd $(BUILD_DIR) && \
		PATCH_DIR=""; \
		if [ -d .spock/patches/pg$(PG_MAJOR) ]; then PATCH_DIR=.spock/patches/pg$(PG_MAJOR); \
		elif [ -d .spock/patches/$(PG_MAJOR) ]; then PATCH_DIR=.spock/patches/$(PG_MAJOR); \
		else echo "unable to find pg$(PG_MAJOR) patch directory in spock source"; exit 1; fi; \
		for p in $$(find "$$PATCH_DIR" -maxdepth 1 -type f -name '*.diff' | sort); do \
			echo "apply $$p"; \
			patch -p1 --fuzz=0 < "$$p"; \
		done
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	find $(BUILD_DIR)/debian -type f -exec sed -i \
		-e "s/@PG_MAJOR@/$(PG_MAJOR)/g" \
		-e "s/@PG_VERSION@/$(PG_VERSION)/g" \
		-e "s/@SPOCK_VERSION@/$(SPOCK_VERSION)/g" \
		-e "s/@LOLOR_VERSION@/$(LOLOR_VERSION)/g" \
		-e "s/@SNOWFLAKE_VERSION@/$(SNOWFLAKE_VERSION)/g" \
		-e "s/@PKG_REV@/$(PKG_REV)/g" {} +
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && SPOCK_VERSION=$(SPOCK_VERSION) dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp pgedge-$(PG_MAJOR)_*.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name '*.ddeb' -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

pgedge-15:
	$(MAKE) PG_MAJOR=15 clean setup build move

pgedge-16:
	$(MAKE) PG_MAJOR=16 clean setup build move

pgedge-17:
	$(MAKE) PG_MAJOR=17 clean setup build move

pgedge-18:
	$(MAKE) PG_MAJOR=18 clean setup build move

.PHONY: all check-src setup build move clean pgedge-15 pgedge-16 pgedge-17 pgedge-18
