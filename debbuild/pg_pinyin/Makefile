all: setup build move

TARBALL := pg_pinyin-0.0.4.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 14 15 16 17 18
PGRX_VERSION := 0.18.1

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

# prepare directory
setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	perl -0pi -e 's/pgrx = \{ version = "=0\.17\.0", optional = true \}/pgrx = { version = "=0.18.1", optional = true }/; s/pgrx-tests = \{ version = "=0\.17\.0", optional = true \}/pgrx-tests = { version = "=0.18.1", optional = true }/; s/lto = "fat"/lto = "off"/; s/codegen-units = 1/codegen-units = 16/' $(BUILD_DIR)/Cargo.toml
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: building packaging

building: check-pgrx
	cd $(BUILD_DIR) && \
	PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx init \
	    --pg14=/usr/lib/postgresql/14/bin/pg_config \
	    --pg15=/usr/lib/postgresql/15/bin/pg_config \
	    --pg16=/usr/lib/postgresql/16/bin/pg_config \
	    --pg17=/usr/lib/postgresql/17/bin/pg_config \
	    --pg18=/usr/lib/postgresql/18/bin/pg_config \
	    --no-run
	cd $(BUILD_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" cargo update -p pgrx --precise $(PGRX_VERSION)
	cd $(BUILD_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" cargo update -p pgrx-tests --precise $(PGRX_VERSION)
	cd $(BUILD_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" cargo fetch
	cd $(BUILD_DIR) && \
	export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"; \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    cargo pgrx package -v --no-default-features --features pg$$PG_VERSION --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	done

check-pgrx:
	@CURRENT=$$(cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    echo "cargo-pgrx $(PGRX_VERSION) is required; run pig build pgrx -v $(PGRX_VERSION) before building" >&2; \
	    exit 1; \
	fi

packaging:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	# Builder images provide Rust/Clang toolchains outside dpkg, so skip strict Build-Depends checks here.
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc -d

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

# remove building craps
clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup update build building check-pgrx packaging move clean ls
