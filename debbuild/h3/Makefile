all: setup build move

VERSION := 4.5.0
TARBALL := h3-pg-$(VERSION).tar.gz
CORE_TARBALL := h3-$(VERSION).tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
CORE_SOURCE_TARBALL ?= ../SOURCES/$(CORE_TARBALL)
SOURCE_SHA256 := c54c119e1d9a578d5cbcce22f6c66dab2b5a45219fc2b260619807f7f061e53a
CORE_SHA256 := 0da8a392a6ff77e76b60e6a331a49497d0935b6b7b6899da7a3e2786139b0441
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS ?= 14 15 16 17 18

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get $(TARBALL) first"; exit 1)
	@test -f "$(CORE_SOURCE_TARBALL)" || (echo "missing $(CORE_SOURCE_TARBALL), run pig build get $(CORE_TARBALL) first"; exit 1)
	@test "$$(sha256sum "$(SOURCE_TARBALL)" | awk '{print $$1}')" = "$(SOURCE_SHA256)" || (echo "sha256 mismatch: $(SOURCE_TARBALL)"; exit 1)
	@test "$$(sha256sum "$(CORE_SOURCE_TARBALL)" | awk '{print $$1}')" = "$(CORE_SHA256)" || (echo "sha256 mismatch: $(CORE_SOURCE_TARBALL)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	mkdir -p $(BUILD_DIR)/vendor/h3
	tar -C $(BUILD_DIR)/vendor/h3 --strip-components=1 -xf "$(CORE_SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	cp $(BUILD_DIR)/vendor/h3/LICENSE $(BUILD_DIR)/H3-LICENSE
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog
	cd $(BUILD_DIR) && pg_buildext updatecontrol

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	@set -e; mkdir -p $(PKG_OUTPUT_DIR); \
	for v in $(PG_VERSIONS); do \
		set -- postgresql-$$v-h3_$(VERSION)-*.deb; \
		test "$$#" -eq 1 -a -f "$$1" || (echo "expected exactly one PG $$v main package"; exit 1); \
		cp "$$1" $(PKG_OUTPUT_DIR)/; \
	done
	find . -maxdepth 1 -type f \( -name '*.ddeb' -o -name '*-dbgsym_*.deb' \) -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
