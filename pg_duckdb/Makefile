all: build move

TARBALL := pg_duckdb-1.0.0.tar.gz


#==============================================================#
#                         DEB Builder                          #
#==============================================================#
build: build18 build17 build16 build15 build14

build18:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
	sed -i "s/PGVERSION/18/" build/debian/control
	export PATH=/usr/lib/postgresql/18/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;
	cd build && PATH=/usr/lib/postgresql/18/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make && PATH=/usr/lib/postgresql/18/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p /tmp/deb && cp *.deb /tmp/deb/

build17:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
	sed -i "s/PGVERSION/17/" build/debian/control
	export PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;
	cd build && PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make && PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p /tmp/deb && cp *.deb /tmp/deb/

build16:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
	sed -i "s/PGVERSION/16/" build/debian/control
	export PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;
	cd build && PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make && PATH=/usr/lib/postgresql/16/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p /tmp/deb && cp *.deb /tmp/deb/

build15:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
	sed -i "s/PGVERSION/15/" build/debian/control
	export PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;
	cd build && PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make && PATH=/usr/lib/postgresql/15/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p /tmp/deb && cp *.deb /tmp/deb/

build14:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog
	sed -i "s/PGVERSION/14/" build/debian/control
	export PATH=/usr/lib/postgresql/14/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;
	cd build && PATH=/usr/lib/postgresql/14/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make && PATH=/usr/lib/postgresql/14/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc
	mkdir -p /tmp/deb && cp *.deb /tmp/deb/

# collect deb
move:
	mkdir -p /tmp/deb && cp *.deb /tmp/deb/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: all build build17 build16 build15 build14 move clean ls
