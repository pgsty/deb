all: setup build move

TARBALL := pg_typescript-0.1.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 16 17 18
PGRX_VERSION := 0.19.1
SOURCE_PATCHES := patches/pg-typescript-0.1.0.patch
V8_ARCHIVE := rusty_v8-149.4.0-simdutf-x86_64-unknown-linux-gnu.a.gz
RUSTY_V8_ARCHIVE ?= $(abspath ../SOURCES/$(V8_ARCHIVE))
RUSTY_V8_SHA256 := aa30f198b6e7be2188df6498f95053c4c052f212037a01f2c31414d7aca84b53
CARGO_NET_GIT_FETCH_WITH_CLI ?= true
CARGO_HTTP_TIMEOUT ?= 600
CARGO_NET_RETRY ?= 10

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)
	@test -f "$(RUSTY_V8_ARCHIVE)" || (echo "missing official rusty_v8 archive $(RUSTY_V8_ARCHIVE)"; exit 1)
	@test "$$(sha256sum "$(RUSTY_V8_ARCHIVE)" | awk '{print $$1}')" = "$(RUSTY_V8_SHA256)" || (echo "rusty_v8 archive checksum mismatch"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) -name '._*' -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	@$(MAKE) apply-patches
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

apply-patches:
	@set -e; \
	for p in $(SOURCE_PATCHES); do \
		test -f "$$p" || (echo "missing source patch $$p"; exit 1); \
		echo "apply $$p"; \
		patch -d $(BUILD_DIR) -p1 < "$$p"; \
	done

build: building packaging

building: check-pgrx
	cd $(BUILD_DIR) && \
	PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx init \
	    --pg16=/usr/lib/postgresql/16/bin/pg_config \
	    --pg17=/usr/lib/postgresql/17/bin/pg_config \
	    --pg18=/usr/lib/postgresql/18/bin/pg_config \
	    --no-run
	cd $(BUILD_DIR) && find . -path '*/target' -prune -o -name Cargo.lock -type f -print0 | sort -z | xargs -0 -r sha256sum > .pgrx0191-cargo-locks.before
	@test -s $(BUILD_DIR)/.pgrx0191-cargo-locks.before
	cd $(BUILD_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" RUSTY_V8_ARCHIVE="$(RUSTY_V8_ARCHIVE)" CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) CARGO_HTTP_TIMEOUT=$(CARGO_HTTP_TIMEOUT) CARGO_NET_RETRY=$(CARGO_NET_RETRY) cargo fetch --locked
	cd $(BUILD_DIR) && \
	export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"; \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    RUSTY_V8_ARCHIVE="$(RUSTY_V8_ARCHIVE)" CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) CARGO_HTTP_TIMEOUT=$(CARGO_HTTP_TIMEOUT) CARGO_NET_RETRY=$(CARGO_NET_RETRY) \
	    cargo pgrx package -v --no-default-features --features pg$$PG_VERSION --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	done
	cd $(BUILD_DIR) && find . -path '*/target' -prune -o -name Cargo.lock -type f -print0 | sort -z | xargs -0 -r sha256sum > .pgrx0191-cargo-locks.after
	cmp $(BUILD_DIR)/.pgrx0191-cargo-locks.before $(BUILD_DIR)/.pgrx0191-cargo-locks.after

check-pgrx:
	@CURRENT=$$(PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    echo "cargo-pgrx $(PGRX_VERSION) is required; run pig build pgrx -v $(PGRX_VERSION)" >&2; \
	    exit 1; \
	fi

packaging:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	# Builder images provide Rust/Clang toolchains outside dpkg, so skip strict Build-Depends checks here.
	cd $(BUILD_DIR) && PG_VERSIONS="$(PG_VERSIONS)" dpkg-buildpackage -b -us -uc -d

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup apply-patches build building check-pgrx packaging move clean
