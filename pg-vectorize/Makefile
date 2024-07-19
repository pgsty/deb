all: setup build

SRC_NAME := pg_vectorize
PKG_NAME := pg-vectorize

# prepare directory
setup:
	rm -rf ~/$(SRC_NAME)/extension/debian
	cp -r debian ~/$(SRC_NAME)/extension/debian
	cd ~/$(SRC_NAME)/extension/ && pg_buildext updatecontrol

# update control from control.in
update:
	cd ~/$(SRC_NAME)/extension/ && pg_buildext updatecontrol
	@echo "========================="
	cat ~/$(SRC_NAME)/extension/debian/control
	@echo "========================="

# building deb
build:
	cd ~/$(SRC_NAME)/extension/ && pg_buildext updatecontrol
	cd ~/$(SRC_NAME)/extension/ && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p /tmp/deb/
	mv *.deb /tmp/deb/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls