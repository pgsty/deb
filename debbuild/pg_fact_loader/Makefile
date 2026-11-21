# Select the recipe targets, including PG19 on older postgresql-common.
export PG_SUPPORTED_VERSIONS ?= $(shell cat debian/pgversions)

all: setup build move

TARBALL := pg_fact_loader-2.0.1.tar.gz

setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog

build:
	cd build && pg_buildext updatecontrol
	cd build && dpkg-buildpackage -b -us -uc

move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} ~/ext/pkg/ \;

clean:
	rm -rf build *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup build move clean
