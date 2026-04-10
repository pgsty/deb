all: build

TARBALL := timescaledb-2.26.0.tar.gz

build: build18 build17 build16 build15

define build_one
	rm -rf build-$(1); mkdir -p build-$(1)
	tar -C build-$(1) --strip-components=1 -xf ../SOURCES/$(TARBALL)
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

.PHONY: all setup update build move clean ls
