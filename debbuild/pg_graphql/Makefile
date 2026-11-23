CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

all: move

TARBALL := pg_graphql-1.6.3.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 15 16 17 18 19
PGRX_VERSION := 0.20.1
RUST_VERSION := 1.100.0
export RUSTUP_TOOLCHAIN ?= $(RUST_VERSION)
CARGO_BUILD_JOBS ?= 2
export CARGO_BUILD_JOBS
SOURCE_PATCH := patches/pg-graphql-1.6.3-pgrx-0.19.3.patch

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
	patch --batch --fuzz=0 -p1 -d $(BUILD_DIR) < patches/pg-graphql-1.6.3-pgrx-0.20.1.patch

apply-patches:
	@echo "apply $(SOURCE_PATCH)"
	@(cd $(BUILD_DIR) && patch -p1 --fuzz=0 < "../$(SOURCE_PATCH)")

build: packaging

building: check-build-deps
	cd $(BUILD_DIR) && \
	PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx init \
	    $(foreach major,$(PG_VERSIONS),--pg$(major)=/usr/lib/postgresql/$(major)/bin/pg_config) \
	    --no-run
	cd $(BUILD_DIR) && find . -path '*/target' -prune -o -type f -name Cargo.lock -print0 | sort -z | xargs -0 sha256sum > .pgrx-locks.before
	cd $(BUILD_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" cargo fetch --locked
	cd $(BUILD_DIR) && \
	set -eu; export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"; \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
		    CARGO_NET_OFFLINE=true cargo pgrx package -v --no-default-features --features pg$$PG_VERSION --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
		    EXT_DIR=target/release/pg_graphql-pg$$PG_VERSION/usr/share/postgresql/$$PG_VERSION/extension; \
		    find sql -maxdepth 1 -type f -name 'pg_graphql--*--*.sql' -exec cp -t "$$EXT_DIR" {} +; \
		done

	cd $(BUILD_DIR) && find . -path '*/target' -prune -o -type f -name Cargo.lock -print0 | sort -z | xargs -0 sha256sum > .pgrx-locks.after && cmp .pgrx-locks.before .pgrx-locks.after

check-build-deps: setup check-pgrx
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS="$(PG_VERSIONS)" pg_buildext updatecontrol && dpkg-checkbuilddeps

check-pgrx:
	@test "$$(rustc --version | awk '{print $$2}')" = "$(RUST_VERSION)" || (echo "Rust $(RUST_VERSION) is required in the selected Rustup toolchain" >&2; exit 1)
	@CURRENT=$$(cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    echo "cargo-pgrx $(PGRX_VERSION) is required; run pig build pgrx -v $(PGRX_VERSION) before building" >&2; \
	    exit 1; \
	fi

packaging: building
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS="$(PG_VERSIONS)" pg_buildext updatecontrol
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS="$(PG_VERSIONS)" PG_VERSIONS="$(PG_VERSIONS)" dpkg-buildpackage -b -us -uc

move: build
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src check-patches setup apply-patches build building check-build-deps check-pgrx packaging move clean
