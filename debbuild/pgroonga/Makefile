all: check-src setup build move

TARBALL := pgroonga-4.0.8.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get pgroonga first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf $(SOURCE_TARBALL)
	pg_buildext updatecontrol
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog; \
	if [ "$$OS_CODENAME" = "resolute" ]; then \
		sed -i 's/libgroonga0 (>= 15.1.7)/libgroonga0t64 | libgroonga0 (>= 15.1.7)/' build/debian/control.in; \
	fi

# building deb
build:
	cd build && pg_buildext updatecontrol
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup update build move clean ls
