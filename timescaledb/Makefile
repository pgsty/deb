all: build

TARBALL := timescaledb-2.21.1.tar.gz

build: build17 build16 build15

# building deb
build17:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	cd build/ && PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./bootstrap -DSEND_TELEMETRY_DEFAULT=NO -DREGRESS_CHECKS=OFF
	rm -rf build/build/debian; cp -r debian build/build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/build/debian/changelog
	echo '17' > build/build/debian/pgversions
	cd build/build/ && pg_buildext updatecontrol
	cd build/build/ && CFLAGSPATH=" -fPIC -pie" CXXFLAGS=" -fPIC -pie" PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p /tmp/deb
	cp build/*.deb /tmp/deb

build16:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	cd build/ && PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./bootstrap -DSEND_TELEMETRY_DEFAULT=NO -DREGRESS_CHECKS=OFF
	rm -rf build/build/debian; cp -r debian build/build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/build/debian/changelog
	echo '16' > build/build/debian/pgversions
	cd build/build/ && pg_buildext updatecontrol
	cd build/build/ && CFLAGSPATH=" -fPIC -pie" CXXFLAGS=" -fPIC -pie" PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p /tmp/deb
	cp build/*.deb /tmp/deb

build15:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	cd build/ && PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./bootstrap -DSEND_TELEMETRY_DEFAULT=NO -DREGRESS_CHECKS=OFF
	rm -rf build/build/debian; cp -r debian build/build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/build/debian/changelog
	echo '15' > build/build/debian/pgversions
	cd build/build/ && pg_buildext updatecontrol
	cd build/build/ && CFLAGSPATH=" -fPIC -pie" CXXFLAGS=" -fPIC -pie" PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p /tmp/deb
	cp build/*.deb /tmp/deb

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls
