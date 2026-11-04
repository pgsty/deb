CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

all: setup build move

TARBALL := pg_parquet-v0.5.1.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PGRX_VERSION := 0.19.3
PG_VERSIONS ?= 14 15 16 17 18
PGRX_INIT_ARGS := $(foreach v,$(PG_VERSIONS),--pg$(v)=/usr/lib/postgresql/$(v)/bin/pg_config)
CARGO_NET_GIT_FETCH_WITH_CLI ?= true
LOCK_SNAPSHOT := $(CURDIR)/$(BUILD_DIR)/.Cargo.lock.before
LOCK_EXPECTED := 428de8eff063e6d7e207aec170247e18700007e401034d9b46395aebabf5dac2
LIBCLANG_PATH ?= $(lastword $(sort $(wildcard /usr/lib/llvm-*/lib)))
export LIBCLANG_PATH

.NOTPARALLEL:

# prepare directory
setup:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL)"; exit 1)
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	patch -d $(BUILD_DIR) -p1 < patches/pg-parquet-0.5.1.patch
	cd $(BUILD_DIR) && echo "$(LOCK_EXPECTED)  Cargo.lock" | sha256sum -c -
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
	set -e; cd $(BUILD_DIR); \
	export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"; \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) \
	    cargo pgrx package -v --no-default-features --features "pg$$PG_VERSION" --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
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
