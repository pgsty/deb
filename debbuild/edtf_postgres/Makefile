TARBALL := edtf_postgres-1.3.5.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
SOURCE_PATCH := patches/edtf-postgres-1.3.5-pgrx-0.20.0.patch
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS ?= 15 16 17 18 19
export PG_VERSIONS

all: move

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL); run pig build get edtf_postgres first" >&2; exit 1)
	@echo "2fb81d8ef1b20c1ab33697c492054c4b071aea04dd1bd42a6ed1da7ca9e7f8d0  $(SOURCE_TARBALL)" | sha256sum -c -
	@test -f "$(SOURCE_PATCH)" || (echo "missing $(SOURCE_PATCH)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	patch --batch --fuzz=0 -p1 -d $(BUILD_DIR) < $(SOURCE_PATCH)
	rm -rf $(BUILD_DIR)/debian
	cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$(lsb_release -sc); sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: setup
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move: build
	mkdir -p $(PKG_OUTPUT_DIR)
	find . -maxdepth 1 -type f \( -name '*.deb' -o -name '*.ddeb' \) -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
