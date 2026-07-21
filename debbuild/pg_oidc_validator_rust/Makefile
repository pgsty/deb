all: setup build move

TARBALL := pg_oidc_validator_rust-0.1.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 18
PGRX_VERSION := 0.19.1
SOURCE_PATCH := patches/pg-oidc-validator-rust-0.1.0.patch

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL); fetch upstream snapshot b65bbbe288f84fab91d58b8304e8a526d1326af5 and save it as $(TARBALL)"; exit 1)

check-patch:
	@test -f "$(SOURCE_PATCH)" || (echo "missing $(SOURCE_PATCH)"; exit 1)

setup: check-src check-patch
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	patch -d $(BUILD_DIR) -p1 --forward -f < $(SOURCE_PATCH)
	OS_CODENAME=$$(lsb_release -sc 2>/dev/null || (. /etc/os-release && echo $${VERSION_CODENAME:-unknown})); \
	perl -0pi -e "s/PIGSTY\)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: building packaging

building: check-pgrx
	cd $(BUILD_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx init \
		--pg18=/usr/lib/postgresql/18/bin/pg_config --no-run
	cd $(BUILD_DIR) && sha256sum Cargo.lock > .pgrx-lock.before
	cd $(BUILD_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" CARGO_NET_GIT_FETCH_WITH_CLI=true cargo fetch --locked
	cd $(BUILD_DIR) && \
	export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"; \
	PATH=/usr/lib/postgresql/18/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	PG_CONFIG=/usr/lib/postgresql/18/bin/pg_config CARGO_NET_OFFLINE=true \
		cargo build --release --locked --no-default-features --features pg18
	cd $(BUILD_DIR) && sha256sum Cargo.lock > .pgrx-lock.after && cmp .pgrx-lock.before .pgrx-lock.after
	cd $(BUILD_DIR) && readelf -Ws target/release/liboidc_validator.so | grep -q _PG_oauth_validator_module_init

check-pgrx:
	@CURRENT=$$(PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
		echo "cargo-pgrx $(PGRX_VERSION) is required; run pig build pgrx -v $(PGRX_VERSION)" >&2; \
		exit 1; \
	fi

packaging:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	# Builder images provide Rust/Clang toolchains outside dpkg, so skip strict Build-Depends checks here.
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc -d

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src check-patch setup build building check-pgrx packaging move clean
