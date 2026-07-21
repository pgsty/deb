VERSION := 3.4.2
TARBALL := haproxy-$(VERSION).tar.gz
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)

all: check-src setup build move

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed copy $(TARBALL) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	cp -a debian $(BUILD_DIR)/debian
	@codename=$$(. /etc/os-release && echo $$VERSION_CODENAME); \
		test -n "$$codename"; \
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
