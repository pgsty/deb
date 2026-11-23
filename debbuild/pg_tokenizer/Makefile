export RUSTUP_TOOLCHAIN ?= 1.100.0
CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

all: setup build move
.NOTPARALLEL:

# GitHub tag archive: https://github.com/pgsty/pg_tokenizer/archive/refs/tags/v1.2.0.tar.gz
TARBALL := pg_tokenizer-1.2.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
CARGO_TARGET_DIR ?= $(abspath $(BUILD_DIR)/target)
export CARGO_TARGET_DIR
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS ?= $(shell cat debian/pgversions)
PGRX_VERSION := 0.20.1
export PGRX_HOME ?= $(abspath $(BUILD_DIR)/.pgrx)
PGRX_INIT_ARGS := $(foreach v,$(PG_VERSIONS),--pg$(v)=/usr/lib/postgresql/$(v)/bin/pg_config)
CRATE_DIR := .
CARGO_NET_GIT_FETCH_WITH_CLI ?= true
LOCK_SHA256 := 9e9104a0e4b00d8bbef22dc020cdca16bf0f18e733384db5787322c716c03f4b
LIBCLANG_PATH ?= $(lastword $(sort $(wildcard /usr/lib/llvm-*/lib)))
export LIBCLANG_PATH

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	patch --batch --fuzz=0 -p1 -d $(BUILD_DIR) < patches/pg_tokenizer-1.2.0-pgrx-0.20.1.patch
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$(lsb_release -sc 2>/dev/null || (test -f /etc/os-release && . /etc/os-release && echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) || echo unknown); \
	perl -0pi -e "s/PGSTY\\)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: building packaging

building: check-pgrx
	cd $(BUILD_DIR)/$(CRATE_DIR) && \
	PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx init $(PGRX_INIT_ARGS) --no-run
	cd $(BUILD_DIR) && echo '$(LOCK_SHA256)  Cargo.lock' | sha256sum -c -
	cd $(BUILD_DIR)/$(CRATE_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) cargo fetch --locked
	set -e; cd $(BUILD_DIR)/$(CRATE_DIR) && \
	export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"; \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) \
	    cargo pgrx package -v --no-default-features --features pg$$PG_VERSION --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	done
	cd $(BUILD_DIR) && echo '$(LOCK_SHA256)  Cargo.lock' | sha256sum -c -

check-pgrx:
	@CURRENT=$$(cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    echo "cargo-pgrx $(PGRX_VERSION) is required; run pig build pgrx -v $(PGRX_VERSION) before building" >&2; \
	    exit 1; \
	fi

packaging:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	# Builder images provide Rust/Clang toolchains outside dpkg, so skip strict Build-Depends checks here.
	cd $(BUILD_DIR) && PG_VERSIONS="$(PG_VERSIONS)" dpkg-buildpackage -b -us -uc -d

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build building check-pgrx packaging move clean
