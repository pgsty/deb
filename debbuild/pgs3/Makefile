CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

all: move

VERSION := 0.1.1
TARBALL := pgs3-0.1.1.tar.gz
TARBALL_SHA256 := 03d5ba5f221167a6ea28a72e1a23bbe21151203e5736542ae5670944b287fcd7
SOURCE_TARBALL ?= $(or $(wildcard $(HOME)/ext/src/$(TARBALL)),$(wildcard ../SOURCES/$(TARBALL)))
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 17 18
PGRX_VERSION := 0.19.2
PGRX_INIT_ARGS := $(foreach v,$(PG_VERSIONS),--pg$(v)=/usr/lib/postgresql/$(v)/bin/pg_config)
LOCK_SNAPSHOT := $(CURDIR)/$(BUILD_DIR)/.pgrx-locks.before

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing $(TARBALL) under $(HOME)/ext/src or ../SOURCES, run pig build get first; if needed, copy it there"; exit 1)
	@printf '%s  %s\n' '$(TARBALL_SHA256)' '$(SOURCE_TARBALL)' | sha256sum --check --status || (echo "SHA-256 mismatch for $(SOURCE_TARBALL)"; exit 1)

clean-artifacts:
	rm -f *.deb *.ddeb *.buildinfo *.changes

setup: clean-artifacts check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	grep -Eq '^version[[:space:]]*=[[:space:]]*"$(VERSION)"[[:space:]]*$$' $(BUILD_DIR)/Cargo.toml
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$(lsb_release -sc 2>/dev/null || (test -f /etc/os-release && . /etc/os-release && echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) || echo unknown); \
	perl -0pi -e "s/PGSTY\\)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: packaging

building: setup check-pgrx
	cd $(BUILD_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx init $(PGRX_INIT_ARGS) --no-run
	cd $(BUILD_DIR) && sha256sum Cargo.lock > $(LOCK_SNAPSHOT)
	cd $(BUILD_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" cargo fetch --locked
	cd $(BUILD_DIR) && \
	set -e; export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"; \
	for PG_VERSION in $(PG_VERSIONS); do \
		PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
		CARGO_NET_OFFLINE=true cargo pgrx package -v --no-default-features --features pg$$PG_VERSION --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	done
	cd $(BUILD_DIR) && sha256sum --check $(LOCK_SNAPSHOT)

check-pgrx:
	@CURRENT=$$(cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
		echo "cargo-pgrx $(PGRX_VERSION) is required; run pig build pgrx -v $(PGRX_VERSION) before building" >&2; \
		exit 1; \
	fi

packaging: building
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS="$(PG_VERSIONS)" pg_buildext updatecontrol
	# Builder images provide Rust/Clang toolchains outside dpkg, so skip strict Build-Depends checks here.
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS="$(PG_VERSIONS)" PG_VERSIONS="$(PG_VERSIONS)" dpkg-buildpackage -b -us -uc -d

move: build
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src clean-artifacts setup build building check-pgrx packaging move clean
