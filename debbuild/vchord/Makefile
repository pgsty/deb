all: setup build move

TARBALL := VectorChord-1.1.1.tar.gz
SEMVER := $(shell echo $(TARBALL) | sed -E 's/^VectorChord-([0-9A-Za-z.+~-]+)\.tar\.gz/\1/')
PATCH := patches/vchord-1.1.1.patch
PGRX_VERSION := 0.18.1
PG_VERSIONS := $(shell tr '\n' ' ' < debian/pgversions)
PGRX_INIT_ARGS := $(foreach v,$(PG_VERSIONS),--pg$(v)=/usr/lib/postgresql/$(v)/bin/pg_config)

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	patch -d build -p1 < $(PATCH)
	rm -rf build/debian; cp -r debian build/debian
	sed -i -E "/^\[workspace.package\]/,/^\[/{s/^version = \".*\"/version = \"$(SEMVER)\"/}" build/Cargo.toml
	OS_CODENAME=$$(lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

check-pgrx:
	@cargo pgrx --version 2>/dev/null | grep -q "cargo-pgrx $(PGRX_VERSION)" || (cargo pgrx --version 2>/dev/null || true; echo "expected cargo-pgrx $(PGRX_VERSION) in builder" >&2; exit 1)

build: check-pgrx building packaging
building:
	cd build && cargo pgrx init $(PGRX_INIT_ARGS)
	cd build && cargo update -p pgrx --precise $(PGRX_VERSION)
	cd build && CC_BIN=$$(command -v clang-18 || command -v clang-17 || command -v clang-16 || command -v clang || true) && \
	CXX_BIN=$$(command -v clang++-18 || command -v clang++-17 || command -v clang++-16 || command -v clang++ || true) && \
	if [ -z "$$CC_BIN" ]; then echo "No clang compiler found (need clang >= 16)." >&2; exit 1; fi && \
	if [ -z "$$CXX_BIN" ]; then CXX_BIN=$$CC_BIN; fi && \
	for PG_VERSION in $(PG_VERSIONS); do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    CC=$$CC_BIN CXX=$$CXX_BIN \
	    cargo pgrx package -v --no-default-features --features "pg$$PG_VERSION,simd/init" --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config && \
	    EXT_DIR=target/release/vchord-pg$$PG_VERSION/usr/share/postgresql/$$PG_VERSION/extension && \
	    cp -f sql/upgrade/vchord--*.sql $$EXT_DIR/ && \
	    cp -f sql/install/vchord--$(SEMVER).sql $$EXT_DIR/vchord--$(SEMVER).sql && \
	    grep -q "default_version = '$(SEMVER)'" $$EXT_DIR/vchord.control && \
	    test $$(ls -1 $$EXT_DIR/vchord--*.sql | wc -l) -gt 1 && \
	    test -f $$EXT_DIR/vchord--$(SEMVER).sql; \
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
