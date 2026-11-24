all: build move

# PG-major builds share one directory and one content-keyed DuckDB cache.
.NOTPARALLEL:
PG_VERSIONS := 19 18 17 16 15
TARBALL := pg_duckdb-1.2.2.tar.gz
CURL_TARBALL := curl-8.23.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
CURL_SOURCE_TARBALL ?= ../SOURCES/$(CURL_TARBALL)
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL); run pig build get pg_duckdb first"; exit 1)
	@if ! pkg-config --atleast-version=7.85.0 libcurl; then \
		test -f "$(CURL_SOURCE_TARBALL)" || (echo "missing $(CURL_SOURCE_TARBALL); run pig build get $(CURL_TARBALL) first"; exit 1); \
	fi

build: $(addprefix build,$(PG_VERSIONS))

$(addprefix build,$(PG_VERSIONS)): build%: check-src
	rm -rf build
	mkdir -p build
	tar -C build --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf build/debian
	cp -r debian build/debian
	sha256sum "$(SOURCE_TARBALL)" | awk '{print $$1}' > build/debian/duckdb-source-sha256
	if ! pkg-config --atleast-version=7.85.0 libcurl; then \
		tar -C build -xf "$(CURL_SOURCE_TARBALL)"; \
		sha256sum "$(CURL_SOURCE_TARBALL)" | awk '{print $$1}' > build/debian/duckdb-curl-source-sha256; \
	fi
	OS_CODENAME=$$(lsb_release -sc); \
		sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog
	sed 's/PGVERSION/$*/g' debian/control.in > build/debian/control
	cd build && PATH=/usr/lib/postgresql/$*/bin:$(PATH) dpkg-buildpackage -b -us -uc
	$(MAKE) move

move:
	mkdir -p "$(PKG_OUTPUT_DIR)"
	find . -maxdepth 1 -type f \( -name '*.deb' -o -name '*.ddeb' \) -exec cp {} "$(PKG_OUTPUT_DIR)/" \;

clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src build $(addprefix build,$(PG_VERSIONS)) move clean
