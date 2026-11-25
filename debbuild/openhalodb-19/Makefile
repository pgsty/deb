TARBALL := openhalodb-19.0.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PACKAGE := openhalodb-19

all: move

setup:
	@test -f "$(SOURCE_TARBALL)" || { echo "Missing $(SOURCE_TARBALL), run pig build get $(TARBALL)" >&2; exit 1; }
	rm -rf build
	mkdir build
	tar -C build --strip-components=1 -xf "$(SOURCE_TARBALL)"
	cp -a debian build/
	. /etc/os-release && test -n "$$VERSION_CODENAME" && \
		sed -i "1s/PGSTY)/PGSTY~$$VERSION_CODENAME)/" build/debian/changelog

build: setup
	cd build && dpkg-buildpackage -b -us -uc

move: build
	mkdir -p "$(PKG_OUTPUT_DIR)"
	set -e; version=$$(dpkg-parsechangelog -lbuild/debian/changelog -SVersion); \
		arch=$$(dpkg-architecture -qDEB_HOST_ARCH); \
		set -- "$(PACKAGE)_$${version}_$${arch}.deb"; \
		if test -z "$(filter noautodbgsym,$(DEB_BUILD_OPTIONS))"; then \
			stem="$(PACKAGE)-dbgsym_$${version}_$${arch}"; \
			debug="$$stem.ddeb"; test -f "$$debug" || debug="$$stem.deb"; \
			set -- "$$@" "$$debug"; \
		fi; \
		cp "$$@" "$(PKG_OUTPUT_DIR)/"

clean:
	rm -rf build $(PACKAGE)_*.deb $(PACKAGE)-dbgsym_*.deb $(PACKAGE)-dbgsym_*.ddeb $(PACKAGE)_*.buildinfo $(PACKAGE)_*.changes

.PHONY: all setup build move clean
