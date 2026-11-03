all: setup build move

TARBALL := apache-cloudberry-pxf-2.2.0-incubating-src.tar.gz
BUILD_DIR := build

setup:
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	cd $(BUILD_DIR) && QUILT_PATCHES=debian/patches quilt push -a
	cp -fp ../SOURCES/gradle-wrapper-8.14.4.jar $(BUILD_DIR)/server/gradle/wrapper/gradle-wrapper.jar
	cp -fp ../SOURCES/gradle-wrapper-8.14.4.jar.sha256 $(BUILD_DIR)/server/gradle/wrapper/gradle-8.14.4-wrapper.jar.sha256
	cp -fp ../SOURCES/gradle-8.14.4-bin.zip $(BUILD_DIR)/server/gradle/wrapper/gradle-8.14.4-bin.zip
	sed -i "s#^distributionUrl=.*#distributionUrl=file://$$(pwd)/$(BUILD_DIR)/server/gradle/wrapper/gradle-8.14.4-bin.zip#" $(BUILD_DIR)/server/gradle/wrapper/gradle-wrapper.properties
	sed -i "s#^distributionSha256Sum=.*#distributionSha256Sum=f1771298a70f6db5a29daf62378c4e18a17fc33c9ba6b14362e0cdf40610380d#" $(BUILD_DIR)/server/gradle/wrapper/gradle-wrapper.properties
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} ~/ext/pkg/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup build move clean
