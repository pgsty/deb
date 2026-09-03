.NOTPARALLEL:

all: build move

TARBALL := age-PG18-v1.8.0-rc0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
PG17_TARBALL := age-1.7.0.tar.gz
PG17_SOURCE_TARBALL ?= ../SOURCES/$(PG17_TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

#==============================================================#
#                         DEB Builder                          #
#==============================================================#
build: build18 build17

check-src: check-src18 check-src17

check-src18:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

check-src17:
	@test -f "$(PG17_SOURCE_TARBALL)" || (echo "missing $(PG17_SOURCE_TARBALL), run pig build get first; if needed, copy $(PG17_TARBALL) into ../SOURCES"; exit 1)

# AGE 1.8.0 is an upstream PG18-specific release archive.
build18: check-src18
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 --no-same-owner --no-same-permissions -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog
	echo '18' > $(BUILD_DIR)/debian/pgversions
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && PATH=/usr/lib/postgresql/18/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

build17: check-src17
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 --no-same-owner --no-same-permissions -xf "$(PG17_SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	cd $(BUILD_DIR) && git checkout PG17
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	sed -n '/^age (1\.7\.0-2PIGSTY)/,$$p' debian/changelog > $(BUILD_DIR)/debian/changelog
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/1\.7\.0-2PIGSTY)/1.7.0-1PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog
	echo '17' > $(BUILD_DIR)/debian/pgversions
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && PATH=/usr/lib/postgresql/17/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin dpkg-buildpackage -b -us -uc

# PG14/15/16 remain on the older AGE 1.6 branch and are not built here.
# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb $(BUILD_DIR)

.PHONY: all build check-src check-src18 check-src17 build18 build17 move clean
