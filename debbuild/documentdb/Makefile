all: pre build move

.NOTPARALLEL:
PG_VERSIONS ?= $(shell cat debian/pgversions)
export PG_SUPPORTED_VERSIONS ?= $(PG_VERSIONS)

TARBALL := documentdb-1.2-0.tar.gz
SOURCE_TARBALL ?= $(or $(wildcard $(HOME)/ext/src/$(TARBALL)),$(wildcard $(HOME)/pgsty/repo/ext/src/$(TARBALL)),$(wildcard ../SOURCES/$(TARBALL)))
INTEL_TARBALL := intelrdfpmath-applied-2.0u3-1.tar.gz
INTEL_SOURCE_TARBALL ?= $(or $(wildcard $(HOME)/ext/src/$(INTEL_TARBALL)),$(wildcard $(HOME)/pgsty/repo/ext/src/$(INTEL_TARBALL)),$(wildcard ../SOURCES/$(INTEL_TARBALL)))

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing $(TARBALL) under $(HOME)/ext/src, $(HOME)/pgsty/repo/ext/src, or ../SOURCES; run pig build get first if needed"; exit 1)
	@test -n "$(INTEL_SOURCE_TARBALL)" -a -f "$(INTEL_SOURCE_TARBALL)" || (echo "missing $(INTEL_TARBALL) under $(HOME)/ext/src, $(HOME)/pgsty/repo/ext/src, or ../SOURCES; copy the exact archived dependency first"; exit 1)

pre: check-src
	SOURCE="$(SOURCE_TARBALL)" INTELRDFPMATH_SOURCE="$(INTEL_SOURCE_TARBALL)" bash prepare.sh "$(TARBALL)" "$(INTEL_TARBALL)"
	apt-get update -qq
	apt install -y systemtap-sdt-dev libicu-dev pkg-config

# prepare directory
setup: check-src
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf "$(SOURCE_TARBALL)"
	sed -i '/internal\/pg_documentdb_distributed/d' build/Makefile
	pg_buildext updatecontrol
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog
	chown -R $(shell whoami):$(shell whoami) build/

# building deb
build: $(addprefix build,$(PG_VERSIONS))

build%: setup
	printf '%s\n' '$*' > build/debian/pgversions
	cd build/ && set -e; \
		cp debian/control.in debian/control.in.with-rum; \
		trap 'mv -f debian/control.in.with-rum debian/control.in' EXIT; \
		if [ '$*' -ge 18 ]; then sed -i 's/, postgresql-PGVERSION-rum//g' debian/control.in; fi; \
		PG_SUPPORTED_VERSIONS='$*' pg_buildext updatecontrol; \
		PATH=/usr/lib/postgresql/$*/bin:$(PATH) PG_SUPPORTED_VERSIONS='$*' dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} ~/ext/pkg/ \;

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src pre setup update build move clean
