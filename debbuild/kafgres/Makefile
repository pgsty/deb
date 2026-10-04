CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

all: setup build move
.NOTPARALLEL:

PGRX_BIN_DIR ?= $(HOME)/.cargo/bin
export PATH := $(PGRX_BIN_DIR):$(PATH)

# Unmodified upstream 0.3.0 release and committed pgrx 0.16.1 lockfile.
TARBALL := kafgres-0.3.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 16
PGRX_VERSION := 0.16.1
CRATE_DIR := extension

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$(lsb_release -sc 2>/dev/null || (test -f /etc/os-release && . /etc/os-release && echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) || echo unknown); \
	perl -0pi -e "s/PGSTY\\)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: building packaging

building: check-pgrx
	cd $(BUILD_DIR)/$(CRATE_DIR) && set -eu; for PG_VERSION in $(PG_VERSIONS); do \
	    cargo pgrx init --pg$$PG_VERSION=/usr/lib/postgresql/$$PG_VERSION/bin/pg_config --no-run; \
	done
	cd $(BUILD_DIR) && find . -path '*/target' -prune -o -name Cargo.lock -type f -print0 | sort -z | xargs -0 -r sha256sum > .pgrx0161-cargo-locks.before
	@test -s $(BUILD_DIR)/.pgrx0161-cargo-locks.before
	cd $(BUILD_DIR)/$(CRATE_DIR) && RUSTUP_TOOLCHAIN=stable PATH="$(PGRX_BIN_DIR):$$HOME/.cargo/bin:$$PATH" cargo fetch --locked
	cd $(BUILD_DIR)/$(CRATE_DIR) && \
	set -eu; export RUSTUP_TOOLCHAIN=stable; \
	for PG_VERSION in $(PG_VERSIONS); do \
		    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$(PGRX_BIN_DIR):$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
		    CARGO_NET_OFFLINE=true cargo pgrx package -v --no-default-features --features pg$$PG_VERSION --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
		done
	cd $(BUILD_DIR) && find . -path '*/target' -prune -o -name Cargo.lock -type f -print0 | sort -z | xargs -0 -r sha256sum > .pgrx0161-cargo-locks.after
	cmp $(BUILD_DIR)/.pgrx0161-cargo-locks.before $(BUILD_DIR)/.pgrx0161-cargo-locks.after
	rm -f $(BUILD_DIR)/.pgrx0161-cargo-locks.before $(BUILD_DIR)/.pgrx0161-cargo-locks.after

check-pgrx:
	@CURRENT=$$(cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    echo "cargo-pgrx $(PGRX_VERSION) is required; run pig build pgrx -v $(PGRX_VERSION) before building" >&2; \
	    exit 1; \
	fi

packaging:
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS="$(PG_VERSIONS)" pg_buildext updatecontrol
	# Builder images use rustup and versioned Clang; the locked build above checks the actual tools.
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS="$(PG_VERSIONS)" PG_VERSIONS="$(PG_VERSIONS)" dpkg-buildpackage -b -us -uc -d

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build building check-pgrx packaging move clean
