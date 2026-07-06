all: setup build move

TARBALL := polardb-for-postgresql-17.10.1.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build-postgres
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_MAJOR := 17
DEB_PACKAGE := polardb-$(PG_MAJOR)
INSTALL_PREFIX := /usr/polar-$(PG_MAJOR)
PG_PORT := 5432
POLAR_COMMIT := accf02e2
POLAR_BRANCH := POLARDB_17_STABLE
CLANG ?= $(shell command -v clang-21 || command -v clang-20 || command -v clang-19 || command -v clang-18 || command -v clang-17 || command -v clang)
LLVM_CONFIG ?= $(shell command -v llvm-config-21 || command -v llvm-config-20 || command -v llvm-config-19 || command -v llvm-config-18 || command -v llvm-config-17 || command -v llvm-config)

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

check-pfsd-sdk:
	@test -f /usr/local/polarstore/pfsd/include/pfsd_sdk.h -a -f /usr/local/polarstore/pfsd/lib/libpfsd.a || \
		(echo "missing PFSD SDK at /usr/local/polarstore/pfsd; install polarstore before building"; exit 1)

check-build-deps:
	@test -n "$(CLANG)" || (echo "missing clang; install clang/llvm for this distro"; exit 1)
	@test -n "$(LLVM_CONFIG)" || (echo "missing llvm-config; install llvm-dev for this distro"; exit 1)
	@command -v bison >/dev/null || (echo "missing bison; install bison"; exit 1)
	@command -v flex >/dev/null || (echo "missing flex; install flex"; exit 1)
	@dpkg-query -W -f='$${Status}' uuid-dev 2>/dev/null | grep -q 'install ok installed' || \
		(echo "missing uuid headers; install uuid-dev"; exit 1)
	@dpkg-query -W -f='$${Status}' libunwind-dev 2>/dev/null | grep -q 'install ok installed' || \
		(echo "missing libunwind headers; install libunwind-dev"; exit 1)

# prepare directory
setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	sed -i.bak -e "s|^code_commit=.*|code_commit=\$${POLAR_COMMIT:-$(POLAR_COMMIT)}|" $(BUILD_DIR)/package/debian/build-deb.sh
	sed -i.bak -e "s|^code_branch=.*|code_branch=\$${POLAR_BRANCH:-$(POLAR_BRANCH)}|" $(BUILD_DIR)/package/debian/build-deb.sh
	sed -i.bak -e "s|^polar_commit=.*|polar_commit=\$${POLAR_COMMIT:-$(POLAR_COMMIT)}|" $(BUILD_DIR)/package/debian/build-deb.sh
	sed -i.bak -e 's|^prefix=/u01/polardb_pg_17|prefix=$(INSTALL_PREFIX)|' $(BUILD_DIR)/package/debian/build-deb.sh
	sed -i.bak -e 's|^pkgname=.*|pkgname=$${debpkgname}_$${polar_version}-$${polar_commit}_$${arch}|' $(BUILD_DIR)/package/debian/build-deb.sh
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
	patch -d $(BUILD_DIR) -p1 < package-prefix-rpath.patch
	awk '1; /  \.\/configure \$$configure_flag$$/ { print "  (cd src/backend && MAKELEVEL=0 make submake-generated-headers)" }' $(BUILD_DIR)/build.sh > $(BUILD_DIR)/build.sh.new
	mv $(BUILD_DIR)/build.sh.new $(BUILD_DIR)/build.sh
	chmod +x $(BUILD_DIR)/build.sh

# building deb with upstream Debian package workflow
build: check-pfsd-sdk check-build-deps
	cd $(BUILD_DIR)/package/debian && CLANG="$(CLANG)" LLVM_CONFIG="$(LLVM_CONFIG)" bash -e ./build-deb.sh

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp $(BUILD_DIR)/package/debian/*.deb $(PKG_OUTPUT_DIR)/

# remove building artifacts
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all check-src check-pfsd-sdk check-build-deps setup build move clean
