all: setup build move

TARBALL := VectorChord-bm25-0.3.0.tar.gz
SEMVER := $(shell echo $(TARBALL) | sed -E 's/^VectorChord-bm25-([0-9A-Za-z.+~-]+)\.tar\.gz/\1/')
PATCH := patches/vchord-bm25-0.3.0.patch
PGRX_VERSION := 0.18.1
PG_VERSIONS := $(shell tr '\n' ' ' < debian/pgversions)
PGRX_INIT_ARGS := $(foreach v,$(PG_VERSIONS),--pg$(v)=/usr/lib/postgresql/$(v)/bin/pg_config)

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	patch -d build -p1 < $(PATCH)
	rm -rf build/debian; cp -r debian build/debian
	sed -i -E "/^\[package\]/,/^\[/{s/^version = \".*\"/version = \"$(SEMVER)\"/}" build/Cargo.toml
	OS_CODENAME=$$(lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

check-pgrx:
	@cargo pgrx --version 2>/dev/null | grep -q "cargo-pgrx $(PGRX_VERSION)" || (cargo pgrx --version 2>/dev/null || true; echo "expected cargo-pgrx $(PGRX_VERSION) in builder" >&2; exit 1)

build: check-pgrx building packaging
building:
	cd build && cargo pgrx init $(PGRX_INIT_ARGS)
	cd build && cargo update -p pgrx --precise $(PGRX_VERSION)
	cd build && cargo update -p pgrx-tests --precise $(PGRX_VERSION)
	cd build && for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    cargo pgrx package -v --features "pg$$PG_VERSION" --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config && \
	    EXT_DIR=target/release/vchord_bm25-pg$$PG_VERSION/usr/share/postgresql/$$PG_VERSION/extension && \
	    grep -q "default_version = '$(SEMVER)'" $$EXT_DIR/vchord_bm25.control && \
	    test -f $$EXT_DIR/vchord_bm25--$(SEMVER).sql; \
	done

packaging:
	cd build && pg_buildext updatecontrol
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update check-pgrx build building packaging move clean ls
