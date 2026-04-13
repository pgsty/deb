all: setup build move

TARBALL := pg_kazsearch-2.0.0.tar.gz
SOURCE_TARBALL ?= $(firstword $(wildcard $(HOME)/ext/src/$(TARBALL) $(HOME)/pgsty/repo/ext/src/$(TARBALL) ../SOURCES/$(TARBALL) ../../src/$(TARBALL)))
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PACKAGE_VERSION := 2.0.0
PG_VERSIONS := 16 17 18
PGRX_VERSION := 0.17.0
PGRX_PATCH := patches/pgrx-0.17.0-pbox-nonnull.patch

check-src:
	@test -n "$(SOURCE_TARBALL)" || (echo "missing $(TARBALL), run: pig build get pg_kazsearch; if unavailable, place the GitHub source archive under $(HOME)/pgsty/repo/ext/src or ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) -name '._*' -delete
	sed -i -E '/^\[package\]/,/^\[/{s/^version = ".*"/version = "$(PACKAGE_VERSION)"/}' $(BUILD_DIR)/pg_ext/Cargo.toml
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: building packaging

building: ensure-pgrx
	cd $(BUILD_DIR) && \
	PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx init \
	    --pg16=/usr/lib/postgresql/16/bin/pg_config \
	    --pg17=/usr/lib/postgresql/17/bin/pg_config \
	    --pg18=/usr/lib/postgresql/18/bin/pg_config \
	    --no-run
	cd $(BUILD_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" cargo fetch
	@PBOX="$$(find "$$HOME/.cargo/registry/src" -path '*/pgrx-$(PGRX_VERSION)/src/palloc/pbox.rs' | head -n 1)"; \
	test -n "$$PBOX"; \
	if ! grep -q 'NonNull::from(\&mut datum)' "$$PBOX"; then \
	    (cd "$$(dirname "$$PBOX")" && patch -p0 < "$(CURDIR)/$(PGRX_PATCH)"); \
	fi
	cd $(BUILD_DIR) && \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    cargo pgrx package -v -p pg_kazsearch --no-default-features --features pg$$PG_VERSION --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
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

.PHONY: all check-src setup build building ensure-pgrx packaging move clean
