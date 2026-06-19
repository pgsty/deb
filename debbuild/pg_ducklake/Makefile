all: build move

TARBALL := pg_ducklake-1.0.0.tar.gz
ROARING_TARBALL := CRoaring-4.7.1-amalgamation.tar.gz
PATCH := patches/pg-ducklake-1.0.0-tarball-build.patch
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
ROARING_SOURCE_TARBALL ?= ../SOURCES/$(ROARING_TARBALL)
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
BUILD_DIR := build
PG_VERSIONS := 18 17 16 15 14

build: $(addprefix build,$(PG_VERSIONS))

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)
	@test -f "$(ROARING_SOURCE_TARBALL)" || (echo "missing $(ROARING_SOURCE_TARBALL), copy $(ROARING_TARBALL) into ../SOURCES"; exit 1)

build18 build17 build16 build15 build14: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	patch -d $(BUILD_DIR) -p1 < $(PATCH)
	tar -C $(BUILD_DIR) -xzf "$(ROARING_SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$(lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog
	sed -i "s/PGVERSION/$(@:build%=%)/g" $(BUILD_DIR)/debian/control
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all build check-src build18 build17 build16 build15 build14 move clean
