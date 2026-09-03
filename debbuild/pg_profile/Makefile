all: setup build move

TARBALL := pg_profile-4.15.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)

# prepare directory
setup: check-src
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf $(SOURCE_TARBALL)
	pg_buildext updatecontrol
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" build/debian/changelog

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get pg_profile first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

# building deb
build:
	cd build && pg_buildext updatecontrol
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} ~/ext/pkg/ \;

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls check-src

