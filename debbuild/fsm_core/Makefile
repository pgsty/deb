all: setup build move

TARBALL := fsm_core-1.0.0.tar.gz
SOURCE_DIR ?= ../SOURCES
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS := 15 16 17 18
PGRX_VERSION := 0.17.0
CARGO_HOME_DIR := /tmp/cargo-fsm

check-src:
	@test -f "$(SOURCE_DIR)/$(TARBALL)" || (echo "missing $(SOURCE_DIR)/$(TARBALL), run: pig build get fsm_core or place the tarball manually"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf $(SOURCE_DIR)/$(TARBALL)
	find $(BUILD_DIR) -name '._*' -delete
	perl -0pi -e 's/pg13 = \["pgrx\/pg13", "pgrx-tests\/pg13" \]/pg13 = ["pgrx\/pg13"]/; s/pg14 = \["pgrx\/pg14", "pgrx-tests\/pg14" \]/pg14 = ["pgrx\/pg14"]/; s/pg15 = \["pgrx\/pg15", "pgrx-tests\/pg15" \]/pg15 = ["pgrx\/pg15"]/; s/pg16 = \["pgrx\/pg16", "pgrx-tests\/pg16" \]/pg16 = ["pgrx\/pg16"]/; s/pg17 = \["pgrx\/pg17", "pgrx-tests\/pg17" \]/pg17 = ["pgrx\/pg17"]/; s/pg18 = \["pgrx\/pg18", "pgrx-tests\/pg18" \]/pg18 = ["pgrx\/pg18"]/; s/\[dev-dependencies\]\n.*?(?=\n\[profile\.dev\])//s; s/lto = "fat"/lto = "off"/; s/codegen-units = 1/codegen-units = 16/' $(BUILD_DIR)/Cargo.toml
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: building packaging

building: ensure-pgrx
	mkdir -p $(CARGO_HOME_DIR) && \
	ln -sfn $(HOME)/.cargo/registry $(CARGO_HOME_DIR)/registry && \
	ln -sfn $(HOME)/.cargo/git $(CARGO_HOME_DIR)/git && \
	rm -f $(CARGO_HOME_DIR)/.package-cache
	cd $(BUILD_DIR) && \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:$$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    CARGO_HOME=$(CARGO_HOME_DIR) \
	    cargo pgrx package -v --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
	done

ensure-pgrx:
	@CURRENT=$$(cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    cargo install --locked cargo-pgrx --version $(PGRX_VERSION); \
	fi

packaging:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build building ensure-pgrx packaging move clean
