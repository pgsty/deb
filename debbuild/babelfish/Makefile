all: setup build move

PG_MAJOR ?= 17
PG_VERSION ?= 17.7
BBF_VERSION ?= 5.4.0
DEB_VERSION ?= $(BBF_VERSION)-1PIGSTY
TARBALL := babelfish-$(PG_MAJOR)-$(PG_VERSION)-$(BBF_VERSION).tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build

build17:
	$(MAKE) PG_MAJOR=17 PG_VERSION=17.7 BBF_VERSION=5.4.0

build18:
	$(MAKE) PG_MAJOR=18 PG_VERSION=18.3 BBF_VERSION=6.0.0

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get babelfish-$(PG_MAJOR) first"; exit 1)

# prepare directory
setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf $(SOURCE_TARBALL)
	mkdir -p $(BUILD_DIR)/buildsrc/contrib
	cp -a $(BUILD_DIR)/postgresql_modified_for_babelfish/. $(BUILD_DIR)/buildsrc/
	for ext in babelfishpg_money babelfishpg_common babelfishpg_tsql babelfishpg_tds; do \
		cp -a $(BUILD_DIR)/babelfish_extensions/contrib/$$ext $(BUILD_DIR)/buildsrc/contrib/; \
	done
	rm -rf $(BUILD_DIR)/buildsrc/debian; cp -r debian $(BUILD_DIR)/buildsrc/debian
	OS_CODENAME=$$(lsb_release -sc 2>/dev/null || true); \
	if [ -z "$$OS_CODENAME" ] && [ -r /etc/os-release ]; then \
		. /etc/os-release; \
		OS_CODENAME=$${VERSION_CODENAME:-$${UBUNTU_CODENAME:-}}; \
	fi; \
	OS_CODENAME=$${OS_CODENAME:-unknown}; \
	perl -pi -e "s/\\@PG_MAJOR\\@/$(PG_MAJOR)/g; s/\\@PG_VERSION\\@/$(PG_VERSION)/g; s/\\@BBF_VERSION\\@/$(BBF_VERSION)/g; s/\\@DEB_VERSION\\@/$(DEB_VERSION)~$${OS_CODENAME}/g" \
		$(BUILD_DIR)/buildsrc/debian/control \
		$(BUILD_DIR)/buildsrc/debian/changelog \
		$(BUILD_DIR)/buildsrc/debian/install \
		$(BUILD_DIR)/buildsrc/debian/rules; \
	if [ "$$OS_CODENAME" = "resolute" ]; then \
		perl -pi -e 's/typedef bool \(\*pltsql_is_partitioned_table_reloptions_allowed_hook_type\)\(\);/typedef bool (*pltsql_is_partitioned_table_reloptions_allowed_hook_type)(Datum reloptions);/g' \
			$(BUILD_DIR)/buildsrc/src/include/access/reloptions.h; \
		perl -pi -e 's/char[[:space:]]*\*pos;/const char *pos;/' $(BUILD_DIR)/buildsrc/contrib/babelfishpg_tds/src/backend/tds/tdsrpc.c; \
	fi

# building deb
build:
	cd $(BUILD_DIR)/buildsrc && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp $(BUILD_DIR)/*.deb ~/ext/pkg/

# remove building artifacts
clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all build17 build18 check-src setup update build move clean ls
