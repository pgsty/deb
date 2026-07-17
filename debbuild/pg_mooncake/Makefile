all: setup build move

TARBALL := pg_mooncake-0.2.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
PATCH := patches/pg-mooncake-0.2.0.patch
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PGRX_VERSION := 0.19.1
PG_VERSIONS ?= 18
PGRX_INIT_ARGS := $(foreach v,$(PG_VERSIONS),--pg$(v)=/usr/lib/postgresql/$(v)/bin/pg_config)
CARGO_NET_GIT_FETCH_WITH_CLI ?= true
LOCK_SNAPSHOT := /tmp/pgrx0191-pg-mooncake-cargo-locks.before

# prepare directory
setup:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL)"; exit 1)
	@test -f "$(PATCH)" || (echo "missing $(PATCH)"; exit 1)
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	patch -d $(BUILD_DIR) -p1 < $(PATCH)
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$(lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

check-pgrx:
	@cargo pgrx --version 2>/dev/null | grep -q "cargo-pgrx $(PGRX_VERSION)" || (cargo pgrx --version 2>/dev/null || true; echo "expected cargo-pgrx $(PGRX_VERSION) in builder" >&2; exit 1)

build: check-pgrx building packaging
building:
	cd $(BUILD_DIR) && cargo pgrx init $(PGRX_INIT_ARGS) --no-run
	cd $(BUILD_DIR) && find . -type d -name target -prune -o -type f -name Cargo.lock -print | LC_ALL=C sort | while IFS= read -r lock; do sha256sum "$$lock"; done > $(LOCK_SNAPSHOT)
	@test -s $(LOCK_SNAPSHOT)
	cd $(BUILD_DIR) && CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) cargo fetch --locked
	cd $(BUILD_DIR) && for PG_VERSION in $(PG_VERSIONS); do \
	    export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"; \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) \
	    cargo pgrx package -v --no-default-features --features "pg$$PG_VERSION,bgworker" --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	done
	cd $(BUILD_DIR) && find . -type d -name target -prune -o -type f -name Cargo.lock -print | LC_ALL=C sort | while IFS= read -r lock; do sha256sum "$$lock"; done > $(LOCK_SNAPSHOT).after
	cmp $(LOCK_SNAPSHOT) $(LOCK_SNAPSHOT).after
	rm -f $(LOCK_SNAPSHOT) $(LOCK_SNAPSHOT).after

packaging:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && PG_VERSIONS="$(PG_VERSIONS)" dpkg-buildpackage -b -us -uc -d

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

# remove building craps
clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update check-pgrx build building packaging move clean ls
