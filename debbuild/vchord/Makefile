all: setup build move

TARBALL := VectorChord-1.1.1.tar.gz
SEMVER := $(shell echo $(TARBALL) | sed -E 's/^VectorChord-([0-9A-Za-z.+~-]+)\.tar\.gz/\1/')

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	sed -i -E "/^\[workspace.package\]/,/^\[/{s/^version = \".*\"/version = \"$(SEMVER)\"/}" build/Cargo.toml
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

build: building packaging
building:
	cd build && cargo update && \
	CC_BIN=$$(command -v clang-18 || command -v clang-17 || command -v clang-16 || command -v clang || true) && \
	CXX_BIN=$$(command -v clang++-18 || command -v clang++-17 || command -v clang++-16 || command -v clang++ || true) && \
	if [ -z "$$CC_BIN" ]; then echo "No clang compiler found (need clang >= 16)." >&2; exit 1; fi && \
	if [ -z "$$CXX_BIN" ]; then CXX_BIN=$$CC_BIN; fi && \
	for PG_VERSION in 14 15 16 17 18; do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    PG_CONFIG=/usr/lib/postgresql/$$PG_VERSION/bin/pg_config \
	    CC=$$CC_BIN CXX=$$CXX_BIN \
	    cargo pgrx package -v && \
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

.PHONY: all setup update build building packaging move clean ls
