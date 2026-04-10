all: setup build move

TARBALL := pg_trickle-0.16.0-complete.tar.gz
SOURCE_DIR ?= $(or $(wildcard $(HOME)/pgsty/repo/ext/src),../SOURCES)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 18
PGRX_VERSION := 0.17.0
PATCHES := $(sort $(wildcard patches/*.patch))

check-src:
	@test -f "$(SOURCE_DIR)/$(TARBALL)" || (echo "missing $(SOURCE_DIR)/$(TARBALL), run: pig build get pg_trickle or place the tarball manually"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf $(SOURCE_DIR)/$(TARBALL)
	find $(BUILD_DIR) -name '._*' -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	@$(MAKE) apply-patches
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

apply-patches:
	@set -e; \
	for p in $(PATCHES); do \
		echo "apply $$p"; \
		(cd $(BUILD_DIR) && patch -p1 < "../$$p"); \
	done

build: building packaging

building: ensure-pgrx
	cd $(BUILD_DIR) && \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    cargo pgrx package -v --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	done

ensure-pgrx:
	@CURRENT=$$(cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    cargo install --locked cargo-pgrx --version $(PGRX_VERSION); \
	fi

packaging:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	# Builder images provide Rust/Clang toolchains outside dpkg, so skip strict Build-Depends checks here.
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc -d

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup apply-patches build building ensure-pgrx packaging move clean
