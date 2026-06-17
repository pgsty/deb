all: setup build

TARBALL := omnigres-20251108.tar.gz

pre:
	apt install -y wget build-essential git clang lld flex libreadline-dev zlib1g-dev libssl-dev tmux lldb gdb make perl python3-dev python3-venv python3-pip netcat-traditional bison

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	pg_buildext updatecontrol
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog; \
	if [ "$$OS_CODENAME" = "resolute" ]; then \
		find build/deps -name CMakeLists.txt -exec sed -i -E 's/cmake_minimum_required\(VERSION (2\.[0-9]+(\.[0-9]+)?|3\.[0-4](\.[0-9]+)?)\)/cmake_minimum_required(VERSION 3.5)/' {} +; \
	fi

build: pre-resolute building packaging
pre-resolute:
	@OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	if [ "$$OS_CODENAME" = "resolute" ]; then \
		if ! command -v nc >/dev/null 2>&1; then \
			apt-get update; \
			apt-get install -y netcat-traditional; \
		fi; \
		if ! command -v nc >/dev/null 2>&1 && command -v nc.traditional >/dev/null 2>&1; then \
			ln -sf "$$(command -v nc.traditional)" /usr/bin/nc; \
		fi; \
	fi

building:
	cd build && \
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	CMAKE_U26_ARGS=""; \
	if [ "$$OS_CODENAME" = "resolute" ]; then \
	    CMAKE_U26_ARGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5"; \
	fi; \
	for PG_VERSION in 14 15 16 17 18; do \
	    cmake -S . -B pg$$PG_VERSION -DCMAKE_BUILD_TYPE=Release -DOPENSSL_CONFIGURED=1 -DPG_CONFIG=/usr/lib/postgresql/$$PG_VERSION/bin/pg_config $$CMAKE_U26_ARGS ; \
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
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build pre-resolute move clean ls
