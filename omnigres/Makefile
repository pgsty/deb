all: setup build

TARBALL := omnigres-20250507.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)
	pg_buildext updatecontrol
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog

build: building packaging
building:
	cd build && \
	for PG_VERSION in 13 14 15 16 17; do \
	    cmake -S . -B pg$$PG_VERSION -DCMAKE_BUILD_TYPE=Release -DOPENSSL_CONFIGURED=1 -DPG_CONFIG=/usr/lib/postgresql/$$PG_VERSION/bin/pg_config ; \
	    cmake --build pg$$PG_VERSION --parallel; \
	    cmake --build pg$$PG_VERSION --parallel --target package_extensions; \
	done

packaging:
	cd build && pg_buildext updatecontrol
	cd build && dpkg-buildpackage -b -us -uc

# debian12: sudo apt install -y python3.11-dev python3.11-venv
# ubuntu24: sudo apt install -y python3.12-dev python3.12-venv
# ubuntu22: sudo apt install -y python3.10-dev python3.10-venv


# collect deb
move:
	cp *.deb /tmp/deb

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls
