all: setup build

SRC_NAME := pg_jsonschema
PKG_NAME := pg-jsonschema

# prepare directory
setup:
	rm -rf ~/$(SRC_NAME)/debian
	cp -r debian ~/$(SRC_NAME)/
	cd ~/$(SRC_NAME) && pg_buildext updatecontrol

# update control from control.in
update:
	cd ~/$(SRC_NAME) && pg_buildext updatecontrol
	@echo "========================="
	cat ~/$(SRC_NAME)/debian/control
	@echo "========================="

# building deb
build:
	cd ~/$(SRC_NAME) && pg_buildext updatecontrol
	cd ~/$(SRC_NAME)/ && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p /tmp/deb/
	mv *.deb /tmp/deb/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls