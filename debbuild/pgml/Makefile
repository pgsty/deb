CARGO_PROFILE_RELEASE_DEBUG ?= 2
CARGO_PROFILE_RELEASE_STRIP ?= none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP

all: setup build move

TARBALL := pgml-2.10.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 14 15 16 17
PGRX_VERSION := 0.12.9
RUST_VERSION := 1.84.0
OS_CODENAME := $(shell (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}))
CARGO_LOCK_SHA256 := f976f1aecf1b66d562e9a0cafec4748aaa7602be8db24af93f8e02ca6c5fe5d8
LIGHTGBM_RS_REV := 978dd69f6c7aafb8500ecb255f2248fde80ebc97
LIGHTGBM_REV := dce7e58b020bc14b69eefc31546c366971ecb2d9
LIGHTGBM_JSON11_SHA256 := 50721d4783935d481779f137c5459668c872ec02826193333d1ac1b2122770b2
LIGHTGBM_JSON11_PATCHED_SHA256 := 326748d9e9b14ed90638bd95cff58435d51a5008ea350aa86796dca4d5cc5ba2
LIGHTGBM_PATCH := patches/pgml-2.10.0-lightgbm-cstdint.patch

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)
	@test -f "$(LIGHTGBM_PATCH)" || (echo "missing $(LIGHTGBM_PATCH)"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	sed -i "1s/PGSTY)/PGSTY~$(OS_CODENAME))/" $(BUILD_DIR)/debian/changelog
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	dpkg-source --before-build $(BUILD_DIR)

build: building packaging

building: check-toolchain
	cd $(BUILD_DIR) && sha256sum Cargo.lock > .pgml-cargo-lock.before
	cd $(BUILD_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" cargo fetch --locked
	$(MAKE) patch-lightgbm
	cd $(BUILD_DIR) && set -e; \
	for PG_VERSION in $(PG_VERSIONS); do \
	    unset CMAKE_POLICY_VERSION_MINIMUM PYO3_USE_ABI3_FORWARD_COMPATIBILITY PYO3_PYTHON; \
	    if [ "$(OS_CODENAME)" = "resolute" ]; then \
	        export CMAKE_POLICY_VERSION_MINIMUM=3.5; \
	        export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1; \
	        export PYO3_PYTHON=/usr/bin/python3.14; \
	        test -x "$$PYO3_PYTHON"; \
	    fi; \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    PG_CONFIG=/usr/lib/postgresql/$$PG_VERSION/bin/pg_config \
	    PGRX_PG_CONFIG_PATH=/usr/lib/postgresql/$$PG_VERSION/bin/pg_config \
	    CARGO_NET_OFFLINE=true cargo pgrx package -v; \
	    TARGET_DIR=$${CARGO_TARGET_DIR:-target}; \
	    test -s "$$TARGET_DIR/release/pgml-pg$$PG_VERSION/usr/lib/postgresql/$$PG_VERSION/lib/pgml.so"; \
	    test -s "$$TARGET_DIR/release/pgml-pg$$PG_VERSION/usr/share/postgresql/$$PG_VERSION/extension/pgml.control"; \
	    test -n "$$(find "$$TARGET_DIR/release/pgml-pg$$PG_VERSION/usr/share/postgresql/$$PG_VERSION/extension" -maxdepth 1 -name 'pgml--*.sql' -type f -size +0c -print -quit)"; \
	done
	cd $(BUILD_DIR) && sha256sum Cargo.lock > .pgml-cargo-lock.after
	cmp $(BUILD_DIR)/.pgml-cargo-lock.before $(BUILD_DIR)/.pgml-cargo-lock.after

patch-lightgbm:
	@set -e; \
	LOCK_HASH=$$(sha256sum "$(BUILD_DIR)/Cargo.lock" | awk '{print $$1}'); \
	test "$$LOCK_HASH" = "$(CARGO_LOCK_SHA256)" || (echo "unexpected Cargo.lock sha256: $$LOCK_HASH" >&2; exit 1); \
	grep -Fq 'source = "git+https://github.com/postgresml/lightgbm-rs?branch=main#$(LIGHTGBM_RS_REV)"' "$(BUILD_DIR)/Cargo.lock" || (echo "locked lightgbm-rs revision mismatch" >&2; exit 1); \
	CARGO_HOME_DIR=$${CARGO_HOME:-$$HOME/.cargo}; \
	set -- $$(find "$$CARGO_HOME_DIR/git/checkouts" -type f -path '*/978dd69*/lightgbm-sys/lightgbm/src/io/json11.cpp' -print); \
	test "$$#" -eq 1 || (echo "expected one locked LightGBM json11.cpp, found $$#" >&2; exit 1); \
	JSON11=$$1; \
	CHECKOUT=$$(cd "$$(dirname "$$JSON11")/../../../.." && pwd); \
	SUBMODULE="$$CHECKOUT/lightgbm-sys/lightgbm"; \
	test "$$(git -c safe.directory="$$CHECKOUT" -C "$$CHECKOUT" rev-parse HEAD)" = "$(LIGHTGBM_RS_REV)" || (echo "lightgbm-rs checkout revision mismatch" >&2; exit 1); \
	test "$$(git -c safe.directory="$$SUBMODULE" -C "$$SUBMODULE" rev-parse HEAD)" = "$(LIGHTGBM_REV)" || (echo "LightGBM submodule revision mismatch" >&2; exit 1); \
	JSON11_HASH=$$(sha256sum "$$JSON11" | awk '{print $$1}'); \
	case "$$JSON11_HASH" in \
	    $(LIGHTGBM_JSON11_SHA256)) patch --fuzz=0 --batch --forward -d "$$CHECKOUT/lightgbm-sys" -p1 < "$(abspath $(LIGHTGBM_PATCH))" ;; \
	    $(LIGHTGBM_JSON11_PATCHED_SHA256)) : ;; \
	    *) echo "unexpected LightGBM json11.cpp sha256: $$JSON11_HASH" >&2; exit 1 ;; \
	esac; \
	test "$$(sha256sum "$$JSON11" | awk '{print $$1}')" = "$(LIGHTGBM_JSON11_PATCHED_SHA256)"

check-toolchain:
	@CURRENT=$$(cd $(BUILD_DIR) && PATH="$$HOME/.cargo/bin:$$PATH" rustc --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(RUST_VERSION)" ]; then \
	    echo "Rust $(RUST_VERSION) is required, found $${CURRENT:-missing}; run pig build rust $(RUST_VERSION) before building" >&2; \
	    exit 1; \
	fi
	@CURRENT=$$(PATH="$$HOME/.cargo/bin:$$PATH" cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    echo "cargo-pgrx $(PGRX_VERSION) is required, found $${CURRENT:-missing}; run pig build pgrx -v $(PGRX_VERSION) before building" >&2; \
	    exit 1; \
	fi

packaging:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build building patch-lightgbm check-toolchain packaging move clean
