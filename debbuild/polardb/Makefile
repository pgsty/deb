.NOTPARALLEL:

all: setup build verify move

POLAR_VERSION := 17.10.1.0
TARBALL := polardb-for-postgresql-$(POLAR_VERSION).tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build-postgres
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_MAJOR := 17
DEB_PACKAGE := polardb-$(PG_MAJOR)
INSTALL_PREFIX := /usr/polar-$(PG_MAJOR)
PG_PORT := 5432
POLAR_COMMIT := accf02e2
POLAR_BRANCH := POLARDB_17_STABLE
POLARSTORE_VERSION := 1.2.42
DEB_RELEASE ?= 1PGSTY
DETECTED_CODENAME := $(shell (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-}}))
DETECTED_ARCH := $(shell dpkg --print-architecture 2>/dev/null)
DISTRO_CODENAME ?= $(DETECTED_CODENAME)
DEB_ARCH ?= $(DETECTED_ARCH)
DEB_FILE = $(DEB_PACKAGE)_$(POLAR_VERSION)-$(DEB_RELEASE)~$(DISTRO_CODENAME)_$(DEB_ARCH).deb
CLANG ?= $(shell command -v clang-21 || command -v clang-20 || command -v clang-19 || command -v clang-18 || command -v clang-17 || command -v clang)
LLVM_CONFIG ?= $(shell command -v llvm-config-21 || command -v llvm-config-20 || command -v llvm-config-19 || command -v llvm-config-18 || command -v llvm-config-17 || command -v llvm-config)

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

check-release:
	@printf '%s\n' "$(DEB_RELEASE)" | grep -Eq '^[1-9][0-9]*PGSTY$$' || \
		(echo "invalid DEB_RELEASE=$(DEB_RELEASE), expected <positive integer>PGSTY"; exit 1)

check-platform:
	@printf '%s\n' "$(DISTRO_CODENAME)" | grep -Eq '^(bookworm|trixie|jammy|noble|resolute)$$' || \
		(echo "invalid DISTRO_CODENAME=$(DISTRO_CODENAME), expected bookworm, trixie, jammy, noble, or resolute"; exit 1)
	@printf '%s\n' "$(DEB_ARCH)" | grep -Eq '^(amd64|arm64)$$' || \
		(echo "invalid DEB_ARCH=$(DEB_ARCH), expected amd64 or arm64"; exit 1)
	@test "$(DISTRO_CODENAME)" = "$(DETECTED_CODENAME)" || \
		(echo "DISTRO_CODENAME=$(DISTRO_CODENAME) does not match builder $(DETECTED_CODENAME)"; exit 1)
	@test "$(DEB_ARCH)" = "$(DETECTED_ARCH)" || \
		(echo "DEB_ARCH=$(DEB_ARCH) does not match builder $(DETECTED_ARCH)"; exit 1)

print-package-name: check-release check-platform
	@printf '%s\n' "$(DEB_FILE)"

check-pfsd-sdk:
	@test -f /usr/local/polarstore/pfsd/include/pfsd_sdk.h -a -f /usr/local/polarstore/pfsd/lib/libpfsd.a || \
		(echo "missing PFSD SDK at /usr/local/polarstore/pfsd; install polarstore before building"; exit 1)
	@test "$$(dpkg-query -W -f='$${Version}' polarstore 2>/dev/null)" = "$(POLARSTORE_VERSION)-$(DEB_RELEASE)~$(DISTRO_CODENAME)" || \
		(echo "installed polarstore is not $(POLARSTORE_VERSION)-$(DEB_RELEASE)~$(DISTRO_CODENAME)"; exit 1)

check-build-deps:
	@dpkg-checkbuilddeps debian/control
	@test -n "$(CLANG)" || (echo "missing clang; install clang/llvm for this distro"; exit 1)
	@test -n "$(LLVM_CONFIG)" || (echo "missing llvm-config; install llvm-dev for this distro"; exit 1)
	@command -v bison >/dev/null || (echo "missing bison; install bison"; exit 1)
	@command -v flex >/dev/null || (echo "missing flex; install flex"; exit 1)
	@dpkg-query -W -f='$${Status}' uuid-dev 2>/dev/null | grep -q 'install ok installed' || \
		(echo "missing uuid headers; install uuid-dev"; exit 1)
	@dpkg-query -W -f='$${Status}' libunwind-dev 2>/dev/null | grep -q 'install ok installed' || \
		(echo "missing libunwind headers; install libunwind-dev"; exit 1)

# prepare directory
setup: check-src check-release check-platform
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	patch -d $(BUILD_DIR) -p1 < polardb-17.10.1.0.patch
	sed -i.bak -e "s|^code_commit=.*|code_commit=\$${POLAR_COMMIT:-$(POLAR_COMMIT)}|" $(BUILD_DIR)/package/debian/build-deb.sh
	sed -i.bak -e "s|^code_branch=.*|code_branch=\$${POLAR_BRANCH:-$(POLAR_BRANCH)}|" $(BUILD_DIR)/package/debian/build-deb.sh
	sed -i.bak -e "s|^polar_commit=.*|polar_commit=\$${POLAR_COMMIT:-$(POLAR_COMMIT)}|" $(BUILD_DIR)/package/debian/build-deb.sh
	sed -i.bak -e 's|^prefix=/u01/polardb_pg_17|prefix=$(INSTALL_PREFIX)|' $(BUILD_DIR)/package/debian/build-deb.sh
	sed -i.bak -e 's|^dpkg --build \./$${pkgname}|dpkg-deb --build --root-owner-group ./$${pkgname}|' $(BUILD_DIR)/package/debian/build-deb.sh
	rm -f $(BUILD_DIR)/package/debian/build-deb.sh.bak
	sed -i.bak -e 's|^POLAR_COMMIT=.*|POLAR_COMMIT="$(POLAR_COMMIT)"|' $(BUILD_DIR)/configure
	sed -i.bak -e 's|^POLAR_COMMIT=.*|POLAR_COMMIT="$(POLAR_COMMIT)"|' $(BUILD_DIR)/configure.ac
	rm -f $(BUILD_DIR)/configure.bak $(BUILD_DIR)/configure.ac.bak
	sed -i.bak -e 's|^port=$$(random_unused_port)|port=$(PG_PORT)|' $(BUILD_DIR)/build.sh
	rm -f $(BUILD_DIR)/build.sh.bak
	sed -i.bak -e 's|^Package: .*|Package: $(DEB_PACKAGE)|' $(BUILD_DIR)/package/debian/control
	sed -i.bak -e 's|^Depends: |Depends: adduser, tzdata, |' $(BUILD_DIR)/package/debian/control
	sed -i.bak -e 's,libicu76,libicu76 | libicu78,' $(BUILD_DIR)/package/debian/control
	rm -f $(BUILD_DIR)/package/debian/control.bak
	cp debian/copyright $(BUILD_DIR)/package/debian/copyright
	awk '{ print; if ($$0 == "mkdir -p $${pkgname}/DEBIAN") { \
		print "cat > $${pkgname}/DEBIAN/postinst <<'\''POSTINST'\''"; \
		print "#!/bin/sh"; \
		print "set -e"; \
		print ""; \
		print "if [ \"$$1\" = \"configure\" ]; then"; \
		print "    getent group postgres >/dev/null 2>&1 || \\"; \
		print "        addgroup --system --gid 543 postgres 2>/dev/null || addgroup --system postgres"; \
		print "    getent passwd postgres >/dev/null 2>&1 || \\"; \
		print "        adduser --system --uid 543 --home /var/lib/pgsql --shell /bin/bash \\"; \
		print "            --gecos \"PostgreSQL Server\" --ingroup postgres postgres 2>/dev/null || \\"; \
		print "        adduser --system --home /var/lib/pgsql --shell /bin/bash \\"; \
		print "            --gecos \"PostgreSQL Server\" --ingroup postgres postgres"; \
		print "fi"; \
		print ""; \
		print "exit 0"; \
		print "POSTINST"; \
		print "chmod 755 $${pkgname}/DEBIAN/postinst"; \
	}}' $(BUILD_DIR)/package/debian/build-deb.sh > $(BUILD_DIR)/package/debian/build-deb.sh.new
	mv $(BUILD_DIR)/package/debian/build-deb.sh.new $(BUILD_DIR)/package/debian/build-deb.sh
	chmod +x $(BUILD_DIR)/package/debian/build-deb.sh
	grep -q 'DEBIAN/postinst' $(BUILD_DIR)/package/debian/build-deb.sh || (echo "postinst/adduser injection FAILED"; exit 1)
	grep -q '^Depends: adduser, tzdata,' $(BUILD_DIR)/package/debian/control || (echo "control adduser/tzdata injection FAILED"; exit 1)
	grep -Fq 'pgsty_release=$${PGSTY_RELEASE:-' $(BUILD_DIR)/package/debian/build-deb.sh || (echo "PGSTY release injection FAILED"; exit 1)
	grep -q 'package_release=$${pgsty_release}~$${distcodename}' $(BUILD_DIR)/package/debian/build-deb.sh || (echo "PGSTY package release injection FAILED"; exit 1)
	awk '/^dpkg-deb --build --root-owner-group/ { print "mkdir -p $${pkgname}/usr/share/doc/$${debpkgname}"; print "cp ./copyright $${pkgname}/usr/share/doc/$${debpkgname}/copyright"; print "cp ../../../COPYRIGHT ../../../LICENSE $${pkgname}/usr/share/doc/$${debpkgname}/" } 1' \
		$(BUILD_DIR)/package/debian/build-deb.sh > $(BUILD_DIR)/package/debian/build-deb.sh.new
	mv $(BUILD_DIR)/package/debian/build-deb.sh.new $(BUILD_DIR)/package/debian/build-deb.sh
	chmod +x $(BUILD_DIR)/package/debian/build-deb.sh
	awk '1; /  \.\/configure \$$configure_flag$$/ { print "  (cd src/backend && MAKELEVEL=0 make submake-generated-headers)" }' $(BUILD_DIR)/build.sh > $(BUILD_DIR)/build.sh.new
	mv $(BUILD_DIR)/build.sh.new $(BUILD_DIR)/build.sh
	chmod +x $(BUILD_DIR)/build.sh

# building deb with upstream Debian package workflow
build: check-pfsd-sdk check-build-deps
	cd $(BUILD_DIR)/package/debian && PGSTY_RELEASE="$(DEB_RELEASE)" DISTRO_CODENAME="$(DISTRO_CODENAME)" CLANG="$(CLANG)" LLVM_CONFIG="$(LLVM_CONFIG)" bash -e ./build-deb.sh

verify:
	@test -f "$(BUILD_DIR)/package/debian/$(DEB_FILE)" || (echo "missing expected package $(DEB_FILE)"; exit 1)
	@test "$$(dpkg-deb -f "$(BUILD_DIR)/package/debian/$(DEB_FILE)" Package)" = "$(DEB_PACKAGE)"
	@test "$$(dpkg-deb -f "$(BUILD_DIR)/package/debian/$(DEB_FILE)" Version)" = "$(POLAR_VERSION)-$(DEB_RELEASE)~$(DISTRO_CODENAME)"
	@test "$$(dpkg-deb -f "$(BUILD_DIR)/package/debian/$(DEB_FILE)" Architecture)" = "$(DEB_ARCH)"
	@test "$$(dpkg-deb -f "$(BUILD_DIR)/package/debian/$(DEB_FILE)" X-Pigsty-Source-Commit)" = "$(POLAR_COMMIT)"
	@dpkg-deb -c "$(BUILD_DIR)/package/debian/$(DEB_FILE)" | awk '$$NF == "./usr/polar-17/bin/postgres" { postgres=1 } $$NF ~ /^\.\/u01\// { legacy=1 } END { exit !(postgres && !legacy) }'
	@dpkg-deb -c "$(BUILD_DIR)/package/debian/$(DEB_FILE)" | grep -q './usr/share/doc/polardb-17/copyright'
	@dpkg-deb -c "$(BUILD_DIR)/package/debian/$(DEB_FILE)" | grep -q './usr/share/doc/polardb-17/COPYRIGHT'
	@dpkg-deb -c "$(BUILD_DIR)/package/debian/$(DEB_FILE)" | grep -q './usr/share/doc/polardb-17/LICENSE'

# collect deb
move: verify
	mkdir -p $(PKG_OUTPUT_DIR) && cp "$(BUILD_DIR)/package/debian/$(DEB_FILE)" $(PKG_OUTPUT_DIR)/

# remove building artifacts
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all check-src check-release check-platform print-package-name check-pfsd-sdk check-build-deps setup build verify move clean
