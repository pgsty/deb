all: build move

# Every PG-major target reuses the same build directory.  Keep the outer
# recipe serial even when the builder exports a parallel MAKEFLAGS value;
# DuckDB's inner CMake/Ninja build remains parallel.
.NOTPARALLEL:

TARBALL := pg_duckdb-1.1.1.tar.gz
SOURCE_SHA256 := $(shell sha256sum ../SOURCES/$(TARBALL) | awk '{print $$1}')


#==============================================================#
#                         DEB Builder                          #
#==============================================================#
build: build18 build17 build16 build15 build14

build18:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	printf '%s\n' '$(SOURCE_SHA256)' > build/debian/duckdb-source-sha256
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog
	sed -i "s/PGVERSION/18/" build/debian/control
	export PATH=/usr/lib/postgresql/18/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;
	cd build && PATH=/usr/lib/postgresql/18/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} ~/ext/pkg/ \;

build17:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	printf '%s\n' '$(SOURCE_SHA256)' > build/debian/duckdb-source-sha256
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog
	sed -i "s/PGVERSION/17/" build/debian/control
	export PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;
	cd build && PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} ~/ext/pkg/ \;

build16:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	printf '%s\n' '$(SOURCE_SHA256)' > build/debian/duckdb-source-sha256
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog
	sed -i "s/PGVERSION/16/" build/debian/control
	export PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;
	cd build && PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} ~/ext/pkg/ \;

build15:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	printf '%s\n' '$(SOURCE_SHA256)' > build/debian/duckdb-source-sha256
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog
	sed -i "s/PGVERSION/15/" build/debian/control
	export PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;
	cd build && PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} ~/ext/pkg/ \;

build14:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	printf '%s\n' '$(SOURCE_SHA256)' > build/debian/duckdb-source-sha256
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog
	sed -i "s/PGVERSION/14/" build/debian/control
	export PATH=/usr/lib/postgresql/14/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;
	cd build && PATH=/usr/lib/postgresql/14/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} ~/ext/pkg/ \;

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} ~/ext/pkg/ \;

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all build build18 build17 build16 build15 build14 move clean
