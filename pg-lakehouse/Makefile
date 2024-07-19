all: setup build

SRC_NAME := pg_lakehouse
PKG_NAME := pg-lakehouse

# prepare directory
setup:
	rm -rf ~/paradedb/$(SRC_NAME)/debian
	cp -r debian ~/paradedb/$(SRC_NAME)/debian
	cd ~/paradedb/$(SRC_NAME) && pg_buildext updatecontrol

# update control from control.in
update:
	cd ~/paradedb/$(SRC_NAME) && pg_buildext updatecontrol
	@echo "========================="
	cat ~/paradedb/$(SRC_NAME)/debian/control
	@echo "========================="

# building deb
build:
	cd ~/paradedb/$(SRC_NAME) && pg_buildext updatecontrol
	cd ~/paradedb/$(SRC_NAME)/ && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p /tmp/deb/
	mv *.deb /tmp/deb/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls