all: setup build move

ARCH := $(shell uname -m)
ifeq ($(ARCH),aarch64)
TARBALL := libduckdb-1.1.2-aarch64.tar.gz
else
TARBALL := libduckdb-1.1.2.tar.gz
endif


# wget https://github.com/duckdb/duckdb/releases/download/v1.1.2/libduckdb-linux-amd64.zip
# tar -zcvf libduckdb-1.1.2.tar.gz libduckdb.so

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build/ -xf ../tarball/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

# building deb
build:
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	cp *.deb ~/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls
