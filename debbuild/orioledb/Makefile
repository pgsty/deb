all: setup build move

PG_MAJOR ?= 18
TARBALL := orioledb-beta16.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

ORIOLEDB_VERSION := 1.8
ORIOLEDB_BETA := beta16
ORIOLEDB_DEB_VERSION := 1.8-0.beta16

ifeq ($(PG_MAJOR),16)
ORIOLEPG_VERSION := 16.47
ORIOLEPG_NEXT_VERSION := 16.48
ORIOLEDB_PATCHSET_VERSION := 47
PATCHSET_LABEL := 16_47
PG_UPSTREAM_VERSION := 16.13
CHANGELOG_DATE := Fri, 19 Jun 2026 00:00:00 +0000
else ifeq ($(PG_MAJOR),17)
ORIOLEPG_VERSION := 17.20
ORIOLEPG_NEXT_VERSION := 17.21
ORIOLEDB_PATCHSET_VERSION := 20
PATCHSET_LABEL := 17_20
PG_UPSTREAM_VERSION := 17.9
CHANGELOG_DATE := Fri, 19 Jun 2026 00:00:00 +0000
else ifeq ($(PG_MAJOR),18)
ORIOLEPG_VERSION := 18.1
ORIOLEPG_NEXT_VERSION := 18.2
ORIOLEDB_PATCHSET_VERSION := 1
PATCHSET_LABEL := 18_1
PG_UPSTREAM_VERSION := 18.4
CHANGELOG_DATE := Thu, 18 Jun 2026 18:00:00 +0000
else
$(error unsupported PG_MAJOR=$(PG_MAJOR), expected 16, 17, or 18)
endif

SOURCE_PACKAGE := oriolepg-$(PG_MAJOR)-orioledb
ORIOLEPG_PACKAGE := oriolepg-$(PG_MAJOR)

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

# prepare directory
setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' "$(PG_MAJOR)" > $(BUILD_DIR)/debian/pgversions
	sed -e 's|@SOURCE_PACKAGE@|$(SOURCE_PACKAGE)|g' \
		-e 's|@ORIOLEPG_PACKAGE@|$(ORIOLEPG_PACKAGE)|g' \
		-e 's|@ORIOLEPG_VERSION@|$(ORIOLEPG_VERSION)|g' \
		-e 's|@ORIOLEPG_NEXT_VERSION@|$(ORIOLEPG_NEXT_VERSION)|g' \
		-e 's|@PATCHSET_LABEL@|$(PATCHSET_LABEL)|g' \
		-e 's|@PG_UPSTREAM_VERSION@|$(PG_UPSTREAM_VERSION)|g' \
		$(BUILD_DIR)/debian/control.in > $(BUILD_DIR)/debian/control.in.tmp
	mv $(BUILD_DIR)/debian/control.in.tmp $(BUILD_DIR)/debian/control.in
	{ \
		printf '%s\n' '$(SOURCE_PACKAGE) ($(ORIOLEDB_DEB_VERSION)PIGSTY) unstable; urgency=medium'; \
		printf '%s\n' ''; \
		printf '%s\n' '  * OrioleDB $(ORIOLEDB_VERSION) $(ORIOLEDB_BETA) on patched PostgreSQL $(ORIOLEPG_VERSION)'; \
		printf '%s\n' ''; \
		printf '%s\n' ' -- Ruohang Feng <rh@vonng.com>  $(CHANGELOG_DATE)'; \
		printf '%s\n' ''; \
	} > $(BUILD_DIR)/debian/changelog
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

# building deb
build:
	cd $(BUILD_DIR) && PG_MAJOR=$(PG_MAJOR) ORIOLEDB_PATCHSET_VERSION=$(ORIOLEDB_PATCHSET_VERSION) pg_buildext updatecontrol
	cd $(BUILD_DIR) && PG_MAJOR=$(PG_MAJOR) ORIOLEDB_PATCHSET_VERSION=$(ORIOLEDB_PATCHSET_VERSION) dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

# remove building craps
clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

build16:
	$(MAKE) clean
	$(MAKE) PG_MAJOR=16 all

build17:
	$(MAKE) clean
	$(MAKE) PG_MAJOR=17 all

build18:
	$(MAKE) clean
	$(MAKE) PG_MAJOR=18 all

.PHONY: all check-src setup update build move clean build16 build17 build18 ls
