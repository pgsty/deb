all: setup build move

TARBALL := babelfishpg-17.8-5.5.0.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	cp -a build/postgresql_modified_for_babelfish/. build/
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog; \
	if [ "$$OS_CODENAME" = "resolute" ]; then \
		sed -i 's/typedef bool (\*pltsql_is_partitioned_table_reloptions_allowed_hook_type)();/typedef bool (*pltsql_is_partitioned_table_reloptions_allowed_hook_type)(Datum reloptions);/g' \
			build/src/include/access/reloptions.h \
			build/postgresql_modified_for_babelfish/src/include/access/reloptions.h; \
	fi

# building deb
build:
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building artifacts
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls
