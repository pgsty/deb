all: setup build

SRC_NAME := postgresml
PKG_NAME := pgml

# prepare directory
setup:
	rm -rf ~/postgresml/pgml-extension/debian
	cp -r debian ~/postgresml/pgml-extension/debian
	cd ~/postgresml/pgml-extension/ && pg_buildext updatecontrol

# update control from control.in
update:
	cd ~/postgresml/pgml-extension/ && pg_buildext updatecontrol
	@echo "========================="
	cat ~/postgresml/pgml-extension/debian/control
	@echo "========================="

# building deb
build:
	cd ~/postgresml/pgml-extension/ && pg_buildext updatecontrol
	cd ~/postgresml/pgml-extension/ && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p /tmp/deb/
	mv *.deb /tmp/deb/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls