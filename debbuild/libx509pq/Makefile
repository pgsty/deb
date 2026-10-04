TARBALL := libx509pq-1.3-bed05c6e87d7.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS ?= 14 15 16 17 18
export PG_VERSIONS

all: move

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL); run pig build get libx509pq first" >&2; exit 1)
	@echo "4f840143f771b588e654073e7d12fe2cbfb46c8adeb8c6b386abb5b6b701d8e4  $(SOURCE_TARBALL)" | sha256sum -c -

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian
	cp -r debian $(BUILD_DIR)/debian
	patch -d $(BUILD_DIR) -p1 < patches/libx509pq-1.3-openssl11.patch
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
