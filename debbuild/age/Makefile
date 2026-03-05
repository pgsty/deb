all: build move

TARBALL := age-1.7.0.tar.gz

#==============================================================#
#                         DEB Builder                          #
#==============================================================#
build: build18 build17

# Single upstream source tarball with branch checkout per PG major.
build18:
	rm -rf build; mkdir -p build
	# Avoid preserving archive owner/perms to prevent git safe.directory issues in root builds.
	tar -C build --strip-components=1 --no-same-owner --no-same-permissions -xf ../SOURCES/$(TARBALL)
	cd build && git checkout PG18
	rm -rf build/debian; cp -r debian build/debian
	sed -i "1s/^age ([^)]*/age (1.7.0-1PIGSTY/" build/debian/changelog
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
	echo '18' > build/debian/pgversions
	cd build && pg_buildext updatecontrol
	cd build && PATH=/usr/lib/postgresql/18/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

build17:
	rm -rf build; mkdir -p build
	# Avoid preserving archive owner/perms to prevent git safe.directory issues in root builds.
	tar -C build --strip-components=1 --no-same-owner --no-same-permissions -xf ../SOURCES/$(TARBALL)
	cd build && git checkout PG17
	rm -rf build/debian; cp -r debian build/debian
	sed -i "1s/^age ([^)]*/age (1.7.0-1PIGSTY/" build/debian/changelog
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
	echo '17' > build/debian/pgversions
	cd build && pg_buildext updatecontrol
	cd build && PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# PG14/15/16 (AGE 1.6 branch) are intentionally disabled in this compromise.
# build16:
# 	rm -rf build; mkdir -p build
# 	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
# 	cd build && git checkout PG16
# 	rm -rf build/debian; cp -r debian build/debian
# 	sed -i "1s/^age ([^)]*/age (1.6.0-1PIGSTY/" build/debian/changelog
# 	OS_CODENAME=$(shell lsb_release -sc); \
# 	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
# 	echo '16' > build/debian/pgversions
# 	cd build && pg_buildext updatecontrol
# 	cd build && PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
# 	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/
#
# build15:
# 	rm -rf build; mkdir -p build
# 	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
# 	cd build && git checkout PG15
# 	rm -rf build/debian; cp -r debian build/debian
# 	sed -i "1s/^age ([^)]*/age (1.6.0-1PIGSTY/" build/debian/changelog
# 	OS_CODENAME=$(shell lsb_release -sc); \
# 	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
# 	echo '15' > build/debian/pgversions
# 	cd build && pg_buildext updatecontrol
# 	cd build && PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
# 	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/
#
# build14:
# 	rm -rf build; mkdir -p build
# 	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
# 	cd build && git checkout PG14
# 	rm -rf build/debian; cp -r debian build/debian
# 	sed -i "1s/^age ([^)]*/age (1.6.0-1PIGSTY/" build/debian/changelog
# 	OS_CODENAME=$(shell lsb_release -sc); \
# 	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
# 	echo '14' > build/debian/pgversions
# 	cd build && pg_buildext updatecontrol
# 	cd build && PATH=/usr/lib/postgresql/14/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
# 	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/
#
# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb build

.PHONY: all build build18 build17 move clean
