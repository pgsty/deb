all: pre build

TARBALL := timescaledb-2.28.3.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)

pre:
	apt-get update -qq
	apt-get install -y cmake libcurl4-openssl-dev libicu-dev libssl-dev

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get $(TARBALL); if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

build: check-src build18 build17 build16 build15

define build_one
	rm -rf build-$(1); mkdir -p build-$(1)
	tar -C build-$(1) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	sed -i 's/^version = 2.28.3-dev$$/version = 2.28.3/' build-$(1)/version.config
	cd build-$(1) && PATH=/usr/lib/postgresql/$(1)/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./bootstrap -DSEND_TELEMETRY_DEFAULT=NO -DREGRESS_CHECKS=OFF
	cd build-$(1)/build && $(MAKE) -j1
	rm -rf build-$(1)/build/debian; cp -r debian build-$(1)/build/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build-$(1)/build/debian/changelog
	echo '$(1)' > build-$(1)/build/debian/pgversions
	cd build-$(1)/build && pg_buildext updatecontrol
	cd build-$(1)/build && CFLAGSPATH=" -fPIC -pie" CXXFLAGS=" -fPIC -pie" PATH=/usr/lib/postgresql/$(1)/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p ~/ext/pkg && cp build-$(1)/*.deb ~/ext/pkg/
endef

build18:
	$(call build_one,18)

build17:
	$(call build_one,17)

build16:
	$(call build_one,16)

build15:
	$(call build_one,15)

# remove building craps
clean:
	rm -rf build-* *.buildinfo *.changes *.ddeb *.deb

.PHONY: all pre setup update build move clean ls
