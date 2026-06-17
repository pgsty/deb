all: setup build move

TARBALL := apache-cloudberry-2.1.0-incubating-src.tar.gz
BUILD_DIR := build

setup:
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog; \
	if [ "$$OS_CODENAME" = "resolute" ]; then \
		sed -i 's/xmlErrorPtr error/const xmlError *error/g' $(BUILD_DIR)/src/backend/utils/adt/xml.c; \
	fi

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup build move clean
