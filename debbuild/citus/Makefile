all: build move

# The PostgreSQL targets share build/, so prepare and build them sequentially.
.NOTPARALLEL:

export DPKG_EXPORT_BUILDFLAGS = 1
include /usr/share/dpkg/buildflags.mk

TARBALL_13_5 := citus-13.5.0.tar.gz
TARBALL_14_3 := citus-14.3.0.tar.gz
PG_MAJOR ?= 18
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

ifeq ($(filter $(PG_MAJOR),15 16 17 18),)
$(error citus supports PostgreSQL 15-18; PG15 uses Citus 13.5.0)
endif
ifeq ($(PG_MAJOR),15)
TARBALL := $(TARBALL_13_5)
else
TARBALL := $(TARBALL_14_3)
endif

# prepare directory
setup:
	test -s ../SOURCES/$(TARBALL)
	rm -rf build
	mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian
	cp -r debian build/debian
ifeq ($(PG_MAJOR),15)
	sed -n '/^citus (13\.5\.0-9PGSTY)/,$$p' debian/changelog > build/debian/changelog
	test -s build/debian/changelog
endif
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog
	echo '$(PG_MAJOR)' > build/debian/pgversions
	cd build/ && pg_buildext updatecontrol

build: build18 build17 build16 build15

# building deb
build18 build17 build16 build15:
	$(MAKE) setup PG_MAJOR=$(patsubst build%,%,$@)
	cd build/ && PATH=/usr/lib/postgresql/$(patsubst build%,%,$@)/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
	cd build/ && PATH=/usr/lib/postgresql/$(patsubst build%,%,$@)/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p "$(PKG_OUTPUT_DIR)" && cp *.deb "$(PKG_OUTPUT_DIR)/" && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} "$(PKG_OUTPUT_DIR)/" \;

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup build build18 build17 build16 build15 move clean
