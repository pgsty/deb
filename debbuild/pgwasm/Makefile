CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

all: setup build move

TARBALL := pgwasm-0.1.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
SOURCE_SHA256 := 9a1dbfa6b34c182542de79e20f415a5049f118a92e64423aa105ab781ed5e327
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 14 15 16 17 18
PGRX_VERSION := 0.19.1
CRATE_DIR := .
SOURCE_PATCH := patches/pgwasm-0.1.0.patch

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL); fetch upstream snapshot 535b53363f8208af139e757e508e66c46309ee29 and save it as $(TARBALL)"; exit 1)
	@echo "$(SOURCE_SHA256)  $(SOURCE_TARBALL)" | sha256sum -c -

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
	perl -0pi -e "s/PGSTY\)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: building packaging

building: check-pgrx
	PATH="$$HOME/.cargo/bin:$$PATH" rustup target add wasm32-wasip2
	cd $(BUILD_DIR)/$(CRATE_DIR) && \
	PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx init \
	    --pg14=/usr/lib/postgresql/14/bin/pg_config \
	    --pg15=/usr/lib/postgresql/15/bin/pg_config \
	    --pg16=/usr/lib/postgresql/16/bin/pg_config \
	    --pg17=/usr/lib/postgresql/17/bin/pg_config \
	    --pg18=/usr/lib/postgresql/18/bin/pg_config \
	    --no-run
	cd $(BUILD_DIR) && find . -path '*/target' -prune -o -type f -name Cargo.lock -print0 | sort -z | xargs -0 sha256sum > .pgrx-locks.before
	cd $(BUILD_DIR)/$(CRATE_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" CARGO_NET_GIT_FETCH_WITH_CLI=true cargo fetch --locked
	cd $(BUILD_DIR)/$(CRATE_DIR) && \
	for manifest in pgwasm/tests/guests/*/Cargo.toml; do \
	    PATH="$$HOME/.cargo/bin:$$PATH" CARGO_NET_GIT_FETCH_WITH_CLI=true cargo fetch --locked --manifest-path "$$manifest"; \
	done
	cd $(BUILD_DIR)/$(CRATE_DIR) && \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=true cargo pgrx package -v --no-default-features --features pg$$PG_VERSION --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	done
	cd $(BUILD_DIR) && find . -path '*/target' -prune -o -type f -name Cargo.lock -print0 | sort -z | xargs -0 sha256sum > .pgrx-locks.after
	cd $(BUILD_DIR) && cmp .pgrx-locks.before .pgrx-locks.after && rm -f .pgrx-locks.before .pgrx-locks.after
	cd $(BUILD_DIR) && for PG_VERSION in $(PG_VERSIONS); do readelf -Ws target/release/pgwasm-pg$$PG_VERSION/usr/lib/postgresql/$$PG_VERSION/lib/pgwasm.so | grep -q _PG_init; done

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
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src check-patch setup build building check-pgrx packaging move clean
