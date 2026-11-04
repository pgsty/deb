CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

DPKG_EXPORT_BUILDFLAGS = 1
# Clang compiles the SIMD C shim; GCC's -flto=auto cannot be passed to it.
export DEB_BUILD_MAINT_OPTIONS = hardening=+all optimize=-lto
include /usr/share/dpkg/buildflags.mk

all: setup build move

# GitHub tag archive: https://github.com/pgsty/vchord/archive/refs/tags/1.2.0.tar.gz
# No downstream patch is applied.
TARBALL := vchord-1.2.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
SEMVER := $(shell echo $(TARBALL) | sed -E 's/^vchord-([0-9A-Za-z.+~-]+)\.tar\.gz/\1/')
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PGRX_VERSION := 0.19.3
PG_VERSIONS ?= 18
PGRX_INIT_ARGS := $(foreach v,$(PG_VERSIONS),--pg$(v)=/usr/lib/postgresql/$(v)/bin/pg_config)
CARGO_NET_GIT_FETCH_WITH_CLI ?= true
LOCK_SNAPSHOT := /tmp/pgrx0193-vchord-cargo-locks.before
LIBCLANG_PATH ?= $(lastword $(sort $(wildcard /usr/lib/llvm-*/lib)))
export LIBCLANG_PATH

# prepare directory
setup:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL)"; exit 1)
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$(lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

check-pgrx:
	@CURRENT=$$(cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
		echo "found cargo-pgrx $${CURRENT:-<missing>}; expected $(PGRX_VERSION)" >&2; \
		exit 1; \
	fi

build: check-pgrx building packaging
building:
	cd $(BUILD_DIR) && cargo pgrx init $(PGRX_INIT_ARGS) --no-run
	cd $(BUILD_DIR) && find . -type d -name target -prune -o -type f -name Cargo.lock -print | LC_ALL=C sort | while IFS= read -r lock; do sha256sum "$$lock"; done > $(LOCK_SNAPSHOT)
	@test -s $(LOCK_SNAPSHOT)
	cd $(BUILD_DIR) && CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) cargo fetch --locked
	set -e; cd $(BUILD_DIR) && \
	CC_BIN=$$(for candidate in clang-21 clang-20 clang-19 clang-18 clang-17 clang-16 clang; do if command -v "$$candidate" >/dev/null 2>&1; then command -v "$$candidate"; break; fi; done) && \
	CXX_BIN=$$(for candidate in clang++-21 clang++-20 clang++-19 clang++-18 clang++-17 clang++-16 clang++; do if command -v "$$candidate" >/dev/null 2>&1; then command -v "$$candidate"; break; fi; done) && \
	if [ -z "$$CC_BIN" ]; then echo "No clang compiler found (need clang >= 16)." >&2; exit 1; fi && \
	CLANG_MAJOR=$$($$CC_BIN --version | sed -n 's/.*clang version \([0-9][0-9]*\).*/\1/p' | head -1) && \
	case "$$CLANG_MAJOR" in ''|*[!0-9]*) echo "Unable to determine clang version from $$CC_BIN." >&2; exit 1;; esac && \
	if [ "$$CLANG_MAJOR" -lt 16 ]; then echo "vchord requires clang >= 16, found $$CLANG_MAJOR." >&2; exit 1; fi && \
	if [ -z "$$CXX_BIN" ]; then CXX_BIN=$$CC_BIN; fi && \
	CLANG_LIB=$$($$CC_BIN -print-file-name=libclang.so) && \
	if [ -f "$$CLANG_LIB" ]; then export LIBCLANG_PATH=$$(cd "$$(dirname "$$CLANG_LIB")" && pwd -P); fi && \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    CC=$$CC_BIN CXX=$$CXX_BIN RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections" \
	    CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) \
	    cargo pgrx package -v --no-default-features --features "pg$$PG_VERSION,simd/init" --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	    EXT_DIR=target/release/vchord-pg$$PG_VERSION/usr/share/postgresql/$$PG_VERSION/extension; \
	    cp -f sql/upgrade/vchord--*.sql $$EXT_DIR/; \
	    cp -f sql/install/vchord--$(SEMVER).sql $$EXT_DIR/vchord--$(SEMVER).sql; \
	    grep -q "default_version = '$(SEMVER)'" $$EXT_DIR/vchord.control; \
	    test $$(ls -1 $$EXT_DIR/vchord--*.sql | wc -l) -gt 1; \
	    test -f $$EXT_DIR/vchord--$(SEMVER).sql; \
	done
	cd $(BUILD_DIR) && find . -type d -name target -prune -o -type f -name Cargo.lock -print | LC_ALL=C sort | while IFS= read -r lock; do sha256sum "$$lock"; done > $(LOCK_SNAPSHOT).after
	cmp $(LOCK_SNAPSHOT) $(LOCK_SNAPSHOT).after
	rm -f $(LOCK_SNAPSHOT) $(LOCK_SNAPSHOT).after

packaging:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	# The builder provides rustup and cargo-pgrx outside dpkg; their versions are checked above.
	cd $(BUILD_DIR) && PG_VERSIONS="$(PG_VERSIONS)" dpkg-buildpackage -b -us -uc -d

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

# remove building craps
clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update check-pgrx build building packaging move clean ls
