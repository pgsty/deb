all: setup build move

TARBALL := VectorChord-1.1.1.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
SEMVER := $(shell echo $(TARBALL) | sed -E 's/^VectorChord-([0-9A-Za-z.+~-]+)\.tar\.gz/\1/')
PATCH := patches/vchord-1.1.1.patch
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PGRX_VERSION := 0.19.1
PG_VERSIONS ?= 18
PGRX_INIT_ARGS := $(foreach v,$(PG_VERSIONS),--pg$(v)=/usr/lib/postgresql/$(v)/bin/pg_config)
CARGO_NET_GIT_FETCH_WITH_CLI ?= true
LOCK_SNAPSHOT := /tmp/pgrx0191-vchord-cargo-locks.before

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
	sed -i -E "/^\[workspace.package\]/,/^\[/{s/^version = \".*\"/version = \"$(SEMVER)\"/}" $(BUILD_DIR)/Cargo.toml
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
	cd $(BUILD_DIR) && CC_BIN=$$(command -v clang-19 || command -v clang-18 || command -v clang-17 || command -v clang-16 || command -v clang || true) && \
	CXX_BIN=$$(command -v clang++-19 || command -v clang++-18 || command -v clang++-17 || command -v clang++-16 || command -v clang++ || true) && \
	if [ -z "$$CC_BIN" ]; then echo "No clang compiler found (need clang >= 16)." >&2; exit 1; fi && \
	if [ -z "$$CXX_BIN" ]; then CXX_BIN=$$CC_BIN; fi && \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    CC=$$CC_BIN CXX=$$CXX_BIN RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections" \
	    CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) \
	    cargo pgrx package -v --no-default-features --features "pg$$PG_VERSION,simd/init" --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config && \
	    EXT_DIR=target/release/vchord-pg$$PG_VERSION/usr/share/postgresql/$$PG_VERSION/extension && \
	    cp -f sql/upgrade/vchord--*.sql $$EXT_DIR/ && \
	    cp -f sql/install/vchord--$(SEMVER).sql $$EXT_DIR/vchord--$(SEMVER).sql && \
	    grep -q "default_version = '$(SEMVER)'" $$EXT_DIR/vchord.control && \
	    test $$(ls -1 $$EXT_DIR/vchord--*.sql | wc -l) -gt 1 && \
	    test -f $$EXT_DIR/vchord--$(SEMVER).sql; \
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
