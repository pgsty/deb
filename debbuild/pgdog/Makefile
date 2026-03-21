all: setup build move

TARBALL := pgdog-0.1.32.tar.gz
BUILD_DIR := build

check-src:
	@test -f "../SOURCES/$(TARBALL)" || (echo "missing ../SOURCES/$(TARBALL), run: pig build get pgdog"; exit 1)

# prepare directory
setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf ../SOURCES/$(TARBALL)
	# Upstream only uses this file to force clang+mold on x86_64, which breaks Debian 12 builders.
	rm -f $(BUILD_DIR)/.cargo/config.toml
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

# building deb
build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building craps
clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup update build move clean ls
