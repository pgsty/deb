CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

# Official untagged snapshot, preserved without repacking:
# https://codeload.github.com/planetscale/lead/tar.gz/e3ed2f4ce1388167b0254a0c0c706a61d0a37d83
TARBALL := lead-1.0.6.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS ?= 17 18
PGRX_VERSION := 0.19.1
PGRX_INIT_ARGS := $(foreach v,$(PG_VERSIONS),--pg$(v)=/usr/lib/postgresql/$(v)/bin/pg_config)

all: setup build move

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)
	@for v in $(PG_VERSIONS); do case "$$v" in 17|18) ;; *) echo "lead supports PostgreSQL 17 and 18"; exit 1;; esac; done

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$(lsb_release -sc 2>/dev/null || (. /etc/os-release && echo $${VERSION_CODENAME})); \
	perl -0pi -e "s/PGSTY\)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: building packaging

check-pgrx:
	@CURRENT=$$(cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    echo "cargo-pgrx $(PGRX_VERSION) is required; run pig build pgrx -v $(PGRX_VERSION) before building" >&2; exit 1; \
	fi

building: check-pgrx
	cd $(BUILD_DIR) && cargo pgrx init $(PGRX_INIT_ARGS) --no-run
	cd $(BUILD_DIR) && sha256sum Cargo.lock > .cargo-lock.before
	cd $(BUILD_DIR) && CARGO_NET_GIT_FETCH_WITH_CLI=true cargo fetch --locked
	set -eu; cd $(BUILD_DIR); \
	export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--unresolved-symbols=ignore-all -C link-arg=-Wl,--no-gc-sections"; \
	for PG_VERSION in $(PG_VERSIONS); do \
	    CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=true \
	    cargo pgrx package -v --package tin --no-default-features --features pg$$PG_VERSION \
	        --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	done
	cd $(BUILD_DIR) && sha256sum -c .cargo-lock.before

packaging:
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS="$(PG_VERSIONS)" pg_buildext updatecontrol
	# Rust 1.96.0 and cargo-pgrx 0.19.1 are installed by rustup/cargo outside dpkg.
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS="$(PG_VERSIONS)" dpkg-buildpackage -b -us -uc -d

move:
	mkdir -p $(PKG_OUTPUT_DIR)
	cp *.deb $(PKG_OUTPUT_DIR)/
	find . -maxdepth 1 -type f -name '*.ddeb' -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.NOTPARALLEL:
.PHONY: all check-src setup build building check-pgrx packaging move clean
