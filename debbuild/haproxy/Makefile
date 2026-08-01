VERSION := 3.4.3
TARBALL := haproxy-$(VERSION).tar.gz
SOURCE_SHA256 := 7fa666d36d198275999e2a68dda44d3d37960f2f7aed3a595fb811f4fd0515b5
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
DEBIAN_TARBALL := haproxy_3.4.2-1~bpo13+1.debian.tar.xz
SOURCE_DEBIAN ?= ../SOURCES/$(DEBIAN_TARBALL)

all: check-src setup build move

check-src:
	@test -f "$(SOURCE_DEBIAN)" || (echo "missing $(SOURCE_DEBIAN), run pig build get $(DEBIAN_TARBALL) first; if unavailable copy only $(DEBIAN_TARBALL) into ../SOURCES"; exit 1)
	@echo "032140846988aab434d00e35276fdc47c02c1c7dc589b7c8f78fb4ce09bdc556  $(SOURCE_DEBIAN)" | sha256sum -c -
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed copy $(TARBALL) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)
	@printf '%s  %s\n' '$(SOURCE_SHA256)' '$(SOURCE_TARBALL)' | sha256sum -c - >/dev/null || (echo "SHA-256 mismatch for $(SOURCE_TARBALL)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	cp -a debian $(BUILD_DIR)/debian
	tar -C $(BUILD_DIR) -xf "$(SOURCE_DEBIAN)" debian/dconv
	patch --batch --fuzz=0 -d $(BUILD_DIR) -p1 < dconv.patch
	@codename=$$(. /etc/os-release && echo $$VERSION_CODENAME); \
		test -n "$$codename" && \
		sed -i "1s/1PIGSTY) unstable/1PIGSTY~$$codename) $$codename/" $(BUILD_DIR)/debian/changelog
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR)
	find . -maxdepth 1 -type f \( -name '*.deb' -o -name '*.ddeb' \) -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
