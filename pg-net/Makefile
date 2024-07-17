all: setup build move ls

# prepare directory
setup:
	rm -rf extension
	mkdir -p extension
	tar -C extension --strip-components=1 -xf ../tarball/pg_net-0.9.2.tar.gz
	pg_buildext updatecontrol
	rm -rf extension/debian
	cp -r ./debian extension/debian

# update control from control.in
update:
	pg_buildext updatecontrol
	@echo "========================="
	cat debian/control
	@echo "========================="

# building deb
build:
	cd extension && pg_buildext updatecontrol
	cd extension && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p /tmp/deb/
	mv *.deb /tmp/deb/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

# list deb packages
ls:
	ls /tmp/deb/postgresql*pg-net*.deb

.PHONY: all setup update build move clean ls