all: setup build move

TARBALL := pg_search-0.20.4.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

build: building packaging
building:
	cd build/pg_search && cargo update && \
	for PG_VERSION in 14 15 16 17; do \
	    PATH=/usr/lib/postgresql/$$PG_VERSION/bin:~/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	    PG_CONFIG=/usr/lib/postgresql/$$PG_VERSION/bin/pg_config \
	    cargo pgrx package -v; \
	done

packaging:
	cd build && pg_buildext updatecontrol
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build building packaging move clean ls