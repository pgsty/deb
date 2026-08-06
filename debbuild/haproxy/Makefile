VERSION := 3.4.3
TARBALL := haproxy-$(VERSION).tar.gz
UTILS_TARBALL := haproxy-utils-$(VERSION).tar.gz
SOURCE_SHA256 := 7fa666d36d198275999e2a68dda44d3d37960f2f7aed3a595fb811f4fd0515b5
UTILS_SHA256 := 6fb18a31be22e21d57c2f26a4bb9160cc2853f5e98e74cbf7e50a06ae57f79db
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
UTILS_SOURCE ?= ../SOURCES/$(UTILS_TARBALL)

all: check-src setup build move

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed copy $(TARBALL) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)
	@test -f "$(UTILS_SOURCE)" || (echo "missing $(UTILS_SOURCE), copy $(UTILS_TARBALL) from ~/pgsty/repo/ext/src/ into ../SOURCES"; exit 1)
	@printf '%s  %s\n' '$(SOURCE_SHA256)' '$(SOURCE_TARBALL)' | sha256sum -c - >/dev/null || (echo "SHA-256 mismatch for $(SOURCE_TARBALL)"; exit 1)
	@printf '%s  %s\n' '$(UTILS_SHA256)' '$(UTILS_SOURCE)' | sha256sum -c - >/dev/null || (echo "SHA-256 mismatch for $(UTILS_SOURCE)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	# Downstream packaging assets shared byte for byte with the RPM spec,
	# which consumes the very same archive as its second source.
	mkdir -p $(BUILD_DIR)/utils
	tar -C $(BUILD_DIR)/utils --strip-components=1 -xf "$(UTILS_SOURCE)"
	cp -a debian $(BUILD_DIR)/debian
	@codename=$$(. /etc/os-release && echo $$VERSION_CODENAME); \
		test -n "$$codename" && \
		sed -i "1s/2PIGSTY) unstable/2PIGSTY~$$codename) $$codename/" $(BUILD_DIR)/debian/changelog
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR)
	find . -maxdepth 1 -type f \( -name '*.deb' -o -name '*.ddeb' \) -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
