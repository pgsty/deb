# Select the recipe targets, including PG19 on older postgresql-common.
export PG_SUPPORTED_VERSIONS ?= $(shell cat debian/pgversions)

all: setup build move

TARBALL := pg-uint128-1.3.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

# prepare directory
setup: check-src
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf "$(SOURCE_TARBALL)"
	pg_buildext updatecontrol
	rm -rf build/debian; cp -r debian build/debian
	patch -d build -p1 --fuzz=0 < patches/pg_uint128-1.3.0-pg19-int8-datum.patch
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog

# building deb
build:
	cd build && pg_buildext updatecontrol
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup update build move clean ls
