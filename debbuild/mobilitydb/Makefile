all: setup build move

VERSION := 1.3.0
TARBALL := mobilitydb-$(VERSION).tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
SOURCE_SHA256 := 2851c322a6250d7502d91817d9e4a4fb56715c403c1eeb5aa32990041b076dfe
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 18

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get $(TARBALL) first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)
	@test "$$(sha256sum "$(SOURCE_TARBALL)" | awk '{print $$1}')" = "$(SOURCE_SHA256)" || (echo "sha256 mismatch: $(SOURCE_TARBALL)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog
	cd $(BUILD_DIR) && pg_buildext updatecontrol

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	@set -e; mkdir -p $(PKG_OUTPUT_DIR); \
	for v in $(PG_VERSIONS); do \
		set -- postgresql-$$v-mobilitydb_$(VERSION)-*.deb; \
		test "$$#" -eq 1 -a -f "$$1" || (echo "expected exactly one PG $$v package"; exit 1); \
		cp "$$1" $(PKG_OUTPUT_DIR)/; \
	done

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
