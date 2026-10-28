CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

# Source: https://api.github.com/repos/Manuelreyesbravo/pg_agent_gate/tarball/v0.3.0
# SHA256: 07f3c91aa54d03b51f9a4101ed8edc47d65cf7072b7b32b94c9b50a56eb3a7c0
TARBALL := pg_agent_gate-0.3.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS ?= 18
PGRX_VERSION := 0.19.3

all: move

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	cd $(BUILD_DIR) && patch --batch --fuzz=0 -p1 < ../patches/pg-agent-gate-0.3.0-pgrx-0.19.3.patch
	cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$(lsb_release -sc); sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

check-pgrx:
	@CURRENT=$$(PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    echo "cargo-pgrx $(PGRX_VERSION) is required; run pig build pgrx -v $(PGRX_VERSION)" >&2; exit 1; \
	fi

building: setup check-pgrx
	set -e; cd $(BUILD_DIR); \
	export PATH="$$HOME/.cargo/bin:$$PATH"; \
	sha256sum Cargo.lock > .lock.before; \
	cargo fetch --locked; \
	export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"; \
	for PG_VERSION in $(PG_VERSIONS); do \
	    cargo pgrx init --pg$$PG_VERSION=/usr/lib/postgresql/$$PG_VERSION/bin/pg_config --no-run; \
	    CARGO_NET_OFFLINE=true cargo pgrx package -v --no-default-features --features pg$$PG_VERSION --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	done; \
	sha256sum -c .lock.before

build: building
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS="$(PG_VERSIONS)" pg_buildext updatecontrol
	cd $(BUILD_DIR) && PG_SUPPORTED_VERSIONS="$(PG_VERSIONS)" dpkg-buildpackage -b -us -uc

move: build
	mkdir -p $(PKG_OUTPUT_DIR)
	cp *.deb $(PKG_OUTPUT_DIR)/
	find . -maxdepth 1 -type f -name '*.ddeb' -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup check-pgrx building build move clean
