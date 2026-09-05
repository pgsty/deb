all: setup build move

TARBALL := graphblas-10.5.0.tar.gz
SOURCE_TARBALL ?= $(or $(wildcard $(HOME)/ext/src/$(TARBALL)),$(wildcard ../SOURCES/$(TARBALL)))
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
CMAKE_MIN_VERSION := 3.23
PRIVATE_CMAKE_PREFIX ?= $(HOME)/.cache/pgsty/cmake-3.31.12
PRIVATE_CMAKE := $(PRIVATE_CMAKE_PREFIX)/bin/cmake
SYSTEM_CMAKE_OK := $(shell version="$$(dpkg-query -W -f='$${Version}' cmake 2>/dev/null)"; test -n "$$version" && dpkg --compare-versions "$$version" ge "$(CMAKE_MIN_VERSION)" && echo yes)

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing $(TARBALL) under $(HOME)/ext/src or ../SOURCES, run pig build get first; if needed, copy it there"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i.bak "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog && rm -f $(BUILD_DIR)/debian/changelog.bak

check-build-deps:
ifeq ($(SYSTEM_CMAKE_OK),yes)
	cd $(BUILD_DIR) && dpkg-checkbuilddeps
else
	@../kitware-cmake "$(PRIVATE_CMAKE_PREFIX)" >/dev/null
	@test -x "$(PRIVATE_CMAKE)"
	@test "$$("$(PRIVATE_CMAKE)" --version | awk 'NR == 1 { print $$3 }')" = "3.31.12"
	cd $(BUILD_DIR) && dpkg-checkbuilddeps -d 'debhelper-compat (= 13), pkg-config'
endif

build: check-build-deps
ifeq ($(SYSTEM_CMAKE_OK),yes)
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc
else
	cd $(BUILD_DIR) && CMAKE="$(PRIVATE_CMAKE)" dpkg-buildpackage -d -b -us -uc
endif

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src check-build-deps setup build move clean
