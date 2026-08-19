all: setup build move

TARBALL := pg_base58-0.0.1.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 14 15 16 17 18
PGRX_VERSION := 0.19.1
CRATE_DIR := .
SOURCE_PATCH := patches/pg-base58-0.0.1.patch
PGRX_HOME := $(CURDIR)/$(BUILD_DIR)/.pgrx-0191

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

check-patches:
	@test -f "$(SOURCE_PATCH)" || (echo "missing $(SOURCE_PATCH), keep the source patch name aligned with $(TARBALL)"; exit 1)

setup: check-src check-patches
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	@$(MAKE) apply-patches
	OS_CODENAME=$$(lsb_release -sc 2>/dev/null || (test -f /etc/os-release && . /etc/os-release && echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) || echo unknown); \
	perl -0pi -e "s/PGSTY\\)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

apply-patches:
	@echo "apply $(SOURCE_PATCH)"
	@(cd $(BUILD_DIR) && patch -p1 --forward -f < "../$(SOURCE_PATCH)")

build: building packaging

building: check-pgrx
	cd $(BUILD_DIR)/$(CRATE_DIR) && \
	PGRX_HOME="$(PGRX_HOME)" cargo-pgrx-0191 init \
	    --pg14=/usr/lib/postgresql/14/bin/pg_config \
	    --pg15=/usr/lib/postgresql/15/bin/pg_config \
	    --pg16=/usr/lib/postgresql/16/bin/pg_config \
	    --pg17=/usr/lib/postgresql/17/bin/pg_config \
	    --pg18=/usr/lib/postgresql/18/bin/pg_config \
	    --no-run
	cd $(BUILD_DIR) && find . -path '*/target' -prune -o -type f -name Cargo.lock -print0 | sort -z | xargs -0 sha256sum > .pgrx-locks.before
	cd $(BUILD_DIR)/$(CRATE_DIR) && CARGO_NET_GIT_FETCH_WITH_CLI=true rust-toolchain cargo fetch --locked
	cd $(BUILD_DIR)/$(CRATE_DIR) && \
	export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"; \
	set -e; \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    PGRX_HOME="$(PGRX_HOME)" CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=true cargo-pgrx-0191 package -v --no-default-features --features pg$$PG_VERSION --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	done

	cd $(BUILD_DIR) && find . -path '*/target' -prune -o -type f -name Cargo.lock -print0 | sort -z | xargs -0 sha256sum > .pgrx-locks.after && cmp .pgrx-locks.before .pgrx-locks.after && rm -f .pgrx-locks.before .pgrx-locks.after

check-pgrx:
	@CURRENT=$$(cargo-pgrx-0191 --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    echo "cargo-pgrx-0191 $(PGRX_VERSION) is required" >&2; \
	    exit 1; \
	fi; \
	RUST_VERSION=$$(rust-toolchain rustc --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$(printf '%s\n' 1.96.0 "$$RUST_VERSION" | sort -V | head -1)" != "1.96.0" ]; then echo "rust-toolchain 1.96 or newer is required, found $$RUST_VERSION" >&2; exit 1; fi

packaging:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && PG_VERSIONS="$(PG_VERSIONS)" dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src check-patches setup apply-patches build building check-pgrx packaging move clean
