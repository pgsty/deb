all: setup build move

VERSION := 2.0.1
DUCKDB_VERSION := 1.5.5
TARBALL := duckdb_fdw-$(VERSION)+git20260529.9354241.tar.gz
DUCKDB_HEADERS_TARBALL := duckdb-$(DUCKDB_VERSION)-headers.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
DUCKDB_HEADERS_SOURCE ?= ../SOURCES/$(DUCKDB_HEADERS_TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)
	@test -f "$(DUCKDB_HEADERS_SOURCE)" || (echo "missing $(DUCKDB_HEADERS_SOURCE), copy only $(DUCKDB_HEADERS_TARBALL) into ../SOURCES"; exit 1)

# prepare directory
setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(DUCKDB_HEADERS_SOURCE)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

# building deb
build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

# remove building craps
clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
