all: setup build move

TARBALL := storage_engine-2.4.0.tar.gz
SOURCE_TARBALL ?= $(or $(wildcard $(HOME)/ext/src/$(TARBALL)),$(wildcard ../SOURCES/$(TARBALL)))

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing $(TARBALL) under $(HOME)/ext/src or ../SOURCES, run pig build get first; if needed, copy it there"; exit 1)

# prepare directory
setup: check-src
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog

# Build one selected major at a time because upstream uses a shared build tree.
PG_VERSIONS ?= $(shell cat debian/pgversions)
export PG_SUPPORTED_VERSIONS ?= $(PG_VERSIONS)

build:
	set -e; for v in $(PG_VERSIONS); do \
		printf '%s\n' "$$v" > build/debian/pgversions; \
		cd build; pg_buildext updatecontrol; \
		PATH=/usr/lib/postgresql/$$v/bin:$$PATH dpkg-buildpackage -b -us -uc; \
		cd ..; \
	done

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} ~/ext/pkg/ \;

# remove building artifacts
clean:
	rm -rf build *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
