CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

all: setup build move

# GitHub tag archive: https://github.com/pgsty/vchord_bm25/archive/refs/tags/1.1.0.tar.gz
# No downstream patch is applied.
TARBALL := vchord_bm25-1.1.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
SEMVER := $(shell echo $(TARBALL) | sed -E 's/^vchord_bm25-([0-9A-Za-z.+~-]+)\.tar\.gz/\1/')
BUILD_DIR := build
CARGO_TARGET_DIR ?= $(abspath $(BUILD_DIR)/target)
export CARGO_TARGET_DIR
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PGRX_VERSION := 0.19.3
PG_VERSIONS ?= 18
PGRX_INIT_ARGS := $(foreach v,$(PG_VERSIONS),--pg$(v)=/usr/lib/postgresql/$(v)/bin/pg_config)
CARGO_NET_GIT_FETCH_WITH_CLI ?= true
LOCK_SNAPSHOT := /tmp/pgrx0193-vchord-bm25-cargo-locks.before
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
	set -e; cd $(BUILD_DIR) && for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections" \
	    CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) \
	    cargo pgrx package -v --features "pg$$PG_VERSION" --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	    EXT_DIR=$(CARGO_TARGET_DIR)/release/vchord_bm25-pg$$PG_VERSION/usr/share/postgresql/$$PG_VERSION/extension; \
	    cp -f sql/upgrade/vchord_bm25--*.sql $$EXT_DIR/; \
	    cp -f sql/install/vchord_bm25--$(SEMVER).sql $$EXT_DIR/vchord_bm25--$(SEMVER).sql; \
	    grep -q "default_version = '$(SEMVER)'" $$EXT_DIR/vchord_bm25.control; \
	    test -f $$EXT_DIR/vchord_bm25--$(SEMVER).sql; \
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
