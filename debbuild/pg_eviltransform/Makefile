all: setup build move

TARBALL := pg_eviltransform-0.0.4.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 14 15 16 17 18
PGRX_VERSION := 0.19.1
CRATE_DIR := .
SOURCE_PATCH := patches/pg-eviltransform-0.0.4.patch
CARGO_NET_GIT_FETCH_WITH_CLI ?= true

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
	perl -0pi -e "s/PIGSTY\\)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

apply-patches:
	@echo "apply $(SOURCE_PATCH)"
	@(cd $(BUILD_DIR) && patch -p1 --forward -f < "../$(SOURCE_PATCH)")

build: building packaging

building: check-pgrx
	cd $(BUILD_DIR)/$(CRATE_DIR) && \
	PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx init \
	    --pg14=/usr/lib/postgresql/14/bin/pg_config \
	    --pg15=/usr/lib/postgresql/15/bin/pg_config \
	    --pg16=/usr/lib/postgresql/16/bin/pg_config \
	    --pg17=/usr/lib/postgresql/17/bin/pg_config \
	    --pg18=/usr/lib/postgresql/18/bin/pg_config \
	    --no-run
	cd $(BUILD_DIR) && find . -path '*/target' -prune -o -name Cargo.lock -type f -print0 | sort -z | xargs -0 -r sha256sum > .pgrx0191-cargo-locks.before
	@test -s $(BUILD_DIR)/.pgrx0191-cargo-locks.before
	cd $(BUILD_DIR)/$(CRATE_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) cargo fetch --locked
	cd $(BUILD_DIR)/$(CRATE_DIR) && \
	export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"; \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    CARGO_NET_OFFLINE=true CARGO_NET_GIT_FETCH_WITH_CLI=$(CARGO_NET_GIT_FETCH_WITH_CLI) cargo pgrx package -v --no-default-features --features pg$$PG_VERSION --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	done
	cd $(BUILD_DIR) && find . -path '*/target' -prune -o -name Cargo.lock -type f -print0 | sort -z | xargs -0 -r sha256sum > .pgrx0191-cargo-locks.after
	cmp $(BUILD_DIR)/.pgrx0191-cargo-locks.before $(BUILD_DIR)/.pgrx0191-cargo-locks.after

check-pgrx:
	@CURRENT=$$(cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    echo "cargo-pgrx $(PGRX_VERSION) is required; run pig build pgrx -v $(PGRX_VERSION) before building" >&2; \
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

.PHONY: all check-src check-patches setup apply-patches build building check-pgrx packaging move clean
