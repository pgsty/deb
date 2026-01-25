all: build move

TARBALL := age-1.7.0.tar.gz

#==============================================================#
#                         DEB Builder                          #
#==============================================================#
build: build18

build18:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
	echo '18' > build/debian/pgversions
	cd build && pg_buildext updatecontrol
	cd build && PATH=/usr/lib/postgresql/18/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb build

.PHONY: all build build18 move clean
