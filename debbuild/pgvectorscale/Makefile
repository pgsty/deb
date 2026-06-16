all: setup build move

TARBALL := pgvectorscale-0.9.0.tar.gz
PATCH := patches/pgvectorscale-0.9.0.patch
PGRX_VERSION := 0.18.1
PG_VERSIONS := $(shell tr '\n' ' ' < debian/pgversions)
PGRX_INIT_ARGS := $(foreach v,$(PG_VERSIONS),--pg$(v)=/usr/lib/postgresql/$(v)/bin/pg_config)

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	patch -d build -p1 < $(PATCH)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$$(lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

check-pgrx:
	@cargo pgrx --version 2>/dev/null | grep -q "cargo-pgrx $(PGRX_VERSION)" || (cargo pgrx --version 2>/dev/null || true; echo "expected cargo-pgrx $(PGRX_VERSION) in builder" >&2; exit 1)

build: check-pgrx building packaging
building:
	cd build/pgvectorscale && cargo pgrx init $(PGRX_INIT_ARGS)
	cd build/pgvectorscale && cargo update -p pgrx --precise $(PGRX_VERSION)
	cd build/pgvectorscale && cargo update -p pgrx-tests --precise $(PGRX_VERSION)
	cd build/pgvectorscale && cargo update -p pgrx-pg-config --precise $(PGRX_VERSION)
	cd build/pgvectorscale && for PG_VERSION in $(PG_VERSIONS); do \
	    RUSTFLAGS="-C target-feature=+avx2,+fma" PATH=/usr/lib/postgresql/$$PG_VERSION/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    cargo pgrx package -v --no-default-features --features "pg$$PG_VERSION,build_parallel" --pg-config /usr/lib/postgresql/$$PG_VERSION/bin/pg_config; \
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
