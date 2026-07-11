all: setup build move

TARBALL := pg_fact_loader-2.0.1.tar.gz

setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog; \
	if [ "$${OS_CODENAME}" != "resolute" ]; then printf '18\n' > build/debian/pgversions; fi

build:
	cd build && pg_buildext updatecontrol
	cd build && dpkg-buildpackage -b -us -uc

move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

clean:
	rm -rf build *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup build move clean
