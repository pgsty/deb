all: setup build

# prepare directory
setup:
	rm -rf ~/libarrow-s3/debian; cp -r debian ~/libarrow-s3/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" ~/libarrow-s3/debian/changelog

# building deb
build:
	cd ~/libarrow-s3 && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p /tmp/deb && cp *.deb /tmp/deb/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls
