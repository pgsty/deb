all: setup build move

TARBALL := pg_uuid_v8-1.0.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
SOURCE_PATCH := patches/$(TARBALL:.tar.gz=.patch)

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

check-patches:
	@test -f "$(SOURCE_PATCH)" || (echo "missing $(SOURCE_PATCH), keep the source patch name aligned with $(TARBALL)"; exit 1)

setup: check-src check-patches
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	@$(MAKE) apply-patches
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

apply-patches:
	@echo "apply $(SOURCE_PATCH)"
	@(cd $(BUILD_DIR) && patch -p1 --forward -f < "../$(SOURCE_PATCH)")
	sed -i "s/^relocatable = true/relocatable = false\\nschema = 'public'/" $(BUILD_DIR)/pg_uuid_v8.control

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src check-patches setup apply-patches build move clean
