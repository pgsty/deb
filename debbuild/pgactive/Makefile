# Select the recipe targets, including PG19 on older postgresql-common.
export PG_SUPPORTED_VERSIONS ?= $(shell cat debian/pgversions)

.NOTPARALLEL:

all: setup build move

export DPKG_EXPORT_BUILDFLAGS = 1
include /usr/share/dpkg/buildflags.mk

TARBALL := pgactive-2.1.10.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
PG_VERSIONS ?= 18 17 16 15 19
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get $(TARBALL) first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

# prepare directory
setup: check-src
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog

# building deb
build: $(addprefix build,$(PG_VERSIONS))
build%:
	@case "$*" in 15|16|17|18|19) ;; *) echo "unsupported PostgreSQL major: $*"; exit 1;; esac
	echo "$*" > build/debian/pgversions
	cd build && pg_buildext updatecontrol
	cd build && PATH=/usr/lib/postgresql/$*/bin:$$PATH ./configure
	cd build && make clean
	cd build && PATH=/usr/lib/postgresql/$*/bin:$$PATH dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup update build move clean ls
