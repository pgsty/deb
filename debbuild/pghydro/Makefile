all: setup build move

TARBALL := pghydro-6.6.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	@$(MAKE) normalize-control-files
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

normalize-control-files:
	printf "%s\n" \
		"# pghydro extension" \
		"comment = 'pghydro extension'" \
		"default_version = '6.6'" \
		"encoding = 'latin1'" \
		"requires = 'plpgsql,postgis'" \
		> $(BUILD_DIR)/pghydro.control
	printf "%s\n" \
		"# pghydro raster extension" \
		"comment = 'pghydro raster extension'" \
		"default_version = '6.6'" \
		"encoding = 'latin1'" \
		"requires = 'plpgsql,postgis,postgis_raster,pghydro'" \
		> $(BUILD_DIR)/pgh_raster.control
	printf "%s\n" \
		"# pgh_hgm extension" \
		"comment = 'pgh_hgm extension'" \
		"default_version = '2.2.6'" \
		"encoding = 'latin1'" \
		"requires = 'plpgsql,postgis,postgis_raster,pghydro,pgh_raster'" \
		> $(BUILD_DIR)/pgh_hgm.control
	printf "%s\n" \
		"# pghydro output extension" \
		"comment = 'pghydro output extension'" \
		"default_version = '6.6'" \
		"encoding = 'latin1'" \
		"requires = 'plpgsql,postgis,pghydro'" \
		> $(BUILD_DIR)/pgh_output.control
	printf "%s\n" \
		"# pghydro output extension en-au" \
		"comment = 'pghydro output extension en-au'" \
		"default_version = '6.6'" \
		"encoding = 'latin1'" \
		"requires = 'plpgsql,postgis,pghydro'" \
		> $(BUILD_DIR)/pgh_output_en_au.control
	printf "%s\n" \
		"# pghydro output extension pt-br" \
		"comment = 'pghydro output extension pt-br'" \
		"default_version = '6.6'" \
		"encoding = 'latin1'" \
		"requires = 'plpgsql,postgis,pghydro'" \
		> $(BUILD_DIR)/pgh_output_pt_br.control
	printf "%s\n" \
		"# pghydro consistency extension" \
		"comment = 'pghydro consistency extension'" \
		"default_version = '6.6'" \
		"encoding = 'latin1'" \
		"requires = 'plpgsql,postgis,pghydro'" \
		> $(BUILD_DIR)/pgh_consistency.control

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup normalize-control-files build move clean
