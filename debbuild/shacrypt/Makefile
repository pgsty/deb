all: move

TARBALL := shacrypt-1.1.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

# prepare directory
setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

# building deb
build: setup
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

verify: build
	sh check-packages.sh $(BUILD_DIR)

# collect deb
move: verify
	mkdir -p $(PKG_OUTPUT_DIR)
	set -eu; version=$$(dpkg-parsechangelog -l$(BUILD_DIR)/debian/changelog -SVersion); \
	arch=$$(dpkg --print-architecture); \
	for v in $$(cd $(BUILD_DIR) && pg_buildext supported-versions); do \
		debug=postgresql-$$v-shacrypt-dbgsym_$${version}_$${arch}.ddeb; \
		if test ! -f "$$debug"; then debug=$${debug%.ddeb}.deb; fi; \
		cp postgresql-$$v-shacrypt_$${version}_$${arch}.deb \
		   "$$debug" $(PKG_OUTPUT_DIR)/; \
	done

# remove building craps
clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build verify move clean


