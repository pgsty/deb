TARBALL := pg_lexo-0.6.1.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS ?= 16 17 18
export PG_VERSIONS

all: move

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL); run pig build get pg_lexo first" >&2; exit 1)
	@echo "a9a7e21538f20199d4cdfb7168c8eb51761464bac38c5b73aa77c8e4c57f65a3  $(SOURCE_TARBALL)" | sha256sum -c -

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian
	cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	echo "19ac620c120b6b1f5a3681ec768f304898b527d8f864a4a6bb470f080076813a  ../SOURCES/pg_lexo-0.6.1-Cargo.lock" | sha256sum -c -
	cp ../SOURCES/pg_lexo-0.6.1-Cargo.lock $(BUILD_DIR)/Cargo.lock
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
