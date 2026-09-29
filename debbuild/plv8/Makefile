all: pre setup build move

export DPKG_EXPORT_BUILDFLAGS = 1
include /usr/share/dpkg/buildflags.mk

SRC_DIR ?= $(HOME)/plv8
SRC_PARENT := $(patsubst %/,%,$(dir $(SRC_DIR)))
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PKG_NAME := plv8

# Source: https://github.com/plv8/plv8/archive/refs/tags/v3.2.5.tar.gz
# Bundle v8-cmake at the upstream gitlink 90d6634d820af06f14c642a9ef3a7bfa7ab4667a.
# The source bundle excludes .git and Apple metadata; patches are applied below.
TARBALL := plv8-3.2.5.tar.gz
SOURCE_PATCH := patches/plv8-3.2.5.patch
PLV8_BUILD_JOBS ?= 4

# Preserve the Debian debug flags in both the bundled V8 engine and plv8's own
# objects so dh_strip can split full DWARF into the dbgsym packages.
pre:
	apt install -y build-essential pkg-config libstdc++-12-dev cmake git #libtinfo5
	rm -rf $(SRC_DIR)
	mkdir -p $(SRC_DIR)
	tar -C $(SRC_DIR) --strip-components=1 -xf ../SOURCES/$(TARBALL)
	patch -d $(SRC_DIR) -p1 --fuzz=0 < $(SOURCE_PATCH)
	cd $(SRC_DIR) && $(MAKE) NUMPROC=$(PLV8_BUILD_JOBS) V8_CXXFLAGS="$(CXXFLAGS)" OPTFLAGS="-std=c++17 -fno-rtti $(CXXFLAGS)"
	# The pre-build above uses the default pg_config (normally the newest PG).
	# Remove only wrapper outputs so pg_buildext must compile PG14 afresh while
	# retaining the expensive, platform-specific V8 cache for every PG build.
	cd $(SRC_DIR) && $(MAKE) clean
	test -s $(SRC_DIR)/deps/v8-cmake/build/libv8_compiler.a
	test -x $(SRC_DIR)/deps/v8-cmake/build/mksnapshot

# prepare directory
setup:
	rm -rf $(SRC_DIR)/debian
	cp -r debian $(SRC_DIR)/debian
	cd $(SRC_DIR) && pg_buildext updatecontrol
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(SRC_DIR)/debian/changelog

# building deb
build:
	cd $(SRC_DIR) && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR); cp -f $(SRC_PARENT)/*plv8*.deb $(PKG_OUTPUT_DIR)/ && find $(SRC_PARENT) -maxdepth 1 -type f -name '*plv8*.ddeb' -exec cp {} $(PKG_OUTPUT_DIR)/ \;

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all pre setup update build move clean
