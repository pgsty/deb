export RUSTUP_TOOLCHAIN ?= 1.100.0
CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

DPKG_EXPORT_BUILDFLAGS = 1
# Clang compiles the SIMD C shim; GCC's -flto=auto cannot be passed to it.
export DEB_BUILD_MAINT_OPTIONS = hardening=+all optimize=-lto
include /usr/share/dpkg/buildflags.mk

all: setup build move
.NOTPARALLEL:

# GitHub tag archive: https://github.com/pgsty/vchord/archive/refs/tags/1.5.0.tar.gz
# Tag commit: 68886c5590de12f756dc8161f71e20552b05900e
# Source SHA256: 38c3beb9b7577c9846b025ef715534ca5b6956b7ff87f6caee05724422bf700d
# No downstream patch is applied.
TARBALL := vchord-1.5.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
SEMVER := $(shell echo $(TARBALL) | sed -E 's/^vchord-([0-9A-Za-z.+~-]+)\.tar\.gz/\1/')
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS ?= $(shell cat debian/pgversions)
export CARGO_TARGET_DIR ?= $(abspath $(BUILD_DIR)/target)
CARGO_NET_GIT_FETCH_WITH_CLI ?= true
LOCK_SHA256 := faf0b707aba2572d5f9569fcfe955901f332a9d812742ea17f8c13b4ad15172d
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

build: building packaging
building:
	cd $(BUILD_DIR) && echo '$(LOCK_SHA256)  Cargo.lock' | sha256sum -c -
	cd $(BUILD_DIR) && CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) cargo fetch --locked
	set -e; cd $(BUILD_DIR) && \
	CC_BIN=$$(for candidate in clang-23 clang-22 clang-21 clang-20 clang-19 clang-18 clang-17 clang-16 clang; do if command -v "$$candidate" >/dev/null 2>&1; then command -v "$$candidate"; break; fi; done) && \
	CXX_BIN=$$(for candidate in clang++-23 clang++-22 clang++-21 clang++-20 clang++-19 clang++-18 clang++-17 clang++-16 clang++; do if command -v "$$candidate" >/dev/null 2>&1; then command -v "$$candidate"; break; fi; done) && \
	if [ -z "$$CC_BIN" ]; then echo "No clang compiler found (need clang >= 16)." >&2; exit 1; fi && \
	CLANG_MAJOR=$$($$CC_BIN --version | sed -n 's/.*clang version \([0-9][0-9]*\).*/\1/p' | head -1) && \
	case "$$CLANG_MAJOR" in ''|*[!0-9]*) echo "Unable to determine clang version from $$CC_BIN." >&2; exit 1;; esac && \
	if [ "$$CLANG_MAJOR" -lt 16 ]; then echo "vchord requires clang >= 16, found $$CLANG_MAJOR." >&2; exit 1; fi && \
	if [ -z "$$CXX_BIN" ]; then CXX_BIN=$$CC_BIN; fi && \
	CLANG_LIB=$$($$CC_BIN -print-file-name=libclang.so) && \
	if [ -f "$$CLANG_LIB" ]; then export LIBCLANG_PATH=$$(cd "$$(dirname "$$CLANG_LIB")" && pwd -P); elif [ -d /usr/lib/llvm-$$CLANG_MAJOR/lib ]; then export LIBCLANG_PATH=/usr/lib/llvm-$$CLANG_MAJOR/lib; fi && \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    CLANG_PATH=$$CC_BIN CLANG_NO_DEFAULT_CONFIG=1 CC=$$CC_BIN CXX=$$CXX_BIN RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections" \
	    CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) \
	    PG_CONFIG=/usr/lib/postgresql/$$PG_VERSION/bin/pg_config $(MAKE) build; \
	    PG_CONFIG=/usr/lib/postgresql/$$PG_VERSION/bin/pg_config $(MAKE) DESTDIR=$(CARGO_TARGET_DIR)/release/vchord-pg$$PG_VERSION install; \
	    EXT_DIR=$(CARGO_TARGET_DIR)/release/vchord-pg$$PG_VERSION/usr/share/postgresql/$$PG_VERSION/extension; \
	    grep -q "default_version = '$(SEMVER)'" $$EXT_DIR/vchord.control; \
	    test -f $$EXT_DIR/vchord--1.4.0--$(SEMVER).sql; \
	done
	cd $(BUILD_DIR) && echo '$(LOCK_SHA256)  Cargo.lock' | sha256sum -c -

packaging:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	# The builder supplies the pinned Rust toolchain outside dpkg.
	cd $(BUILD_DIR) && PG_VERSIONS="$(PG_VERSIONS)" dpkg-buildpackage -b -us -uc -d

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

# remove building craps
clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup build building packaging move clean
