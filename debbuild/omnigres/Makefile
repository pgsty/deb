all: setup build move

TARBALL := omnigres-20251108.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PG_VERSIONS ?= 14 15 16 17 18
CMAKE ?= cmake
CMAKE_MIN_VERSION := 3.25.1
DPKG_BUILDPACKAGE_FLAGS ?=
SOURCE_PATCHES := patches/omnigres-toolchain-compat.patch

pre:
	apt install -y flex bison netcat-traditional python3-dev python3-venv

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

check-tools:
	@set -e; \
	command -v "$(CMAKE)" >/dev/null 2>&1 || (echo "missing CMake; $(CMAKE_MIN_VERSION) or newer is required"; exit 1); \
	CMAKE_VERSION=$$("$(CMAKE)" --version | awk 'NR == 1 { print $$3 }'); \
	dpkg --compare-versions "$$CMAKE_VERSION" ge "$(CMAKE_MIN_VERSION)" || \
	    (echo "CMake $(CMAKE_MIN_VERSION) or newer is required, found $$CMAKE_VERSION; pass CMAKE=/path/to/cmake"; exit 1)

# prepare directory
setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	@$(MAKE) apply-patches
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog; \
	if [ "$$OS_CODENAME" = "resolute" ]; then \
		find $(BUILD_DIR)/deps -name CMakeLists.txt -exec sed -i -E 's/cmake_minimum_required\(VERSION (2\.[0-9]+(\.[0-9]+)?|3\.[0-4](\.[0-9]+)?)\)/cmake_minimum_required(VERSION 3.5)/' {} +; \
	fi

apply-patches:
	@set -e; \
	for p in $(SOURCE_PATCHES); do \
		test -f "$$p" || (echo "missing source patch $$p"; exit 1); \
		echo "apply $$p"; \
		patch -d $(BUILD_DIR) -p1 < "$$p"; \
	done

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

building: check-tools
	cd $(BUILD_DIR) && \
	set -eu; \
	CC_BIN="$(CC)"; CXX_BIN="$(CXX)"; \
	CXX_VERSION=$$("$$CXX_BIN" -dumpfullversion 2>/dev/null || true); \
	if [ -z "$$CXX_VERSION" ] || dpkg --compare-versions "$$CXX_VERSION" lt 13.1; then \
	    CC_BIN=""; CXX_BIN=""; \
	    for CLANG_VERSION in 21 20 19; do \
	        if command -v clang-$$CLANG_VERSION >/dev/null 2>&1 && command -v clang++-$$CLANG_VERSION >/dev/null 2>&1; then \
	            CC_BIN=clang-$$CLANG_VERSION; CXX_BIN=clang++-$$CLANG_VERSION; break; \
	        fi; \
	    done; \
	    test -n "$$CC_BIN" || (echo "GCC 13.1+ or Clang 19+ is required"; exit 1); \
	fi; \
	echo "building with $$CC_BIN / $$CXX_BIN and $(CMAKE)"; \
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	CMAKE_U26_ARGS=""; \
	if [ "$$OS_CODENAME" = "resolute" ]; then \
	    CMAKE_U26_ARGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5"; \
	fi; \
	for PG_VERSION in $(PG_VERSIONS); do \
	    CC="$$CC_BIN" CXX="$$CXX_BIN" "$(CMAKE)" -S . -B pg$$PG_VERSION -DCMAKE_BUILD_TYPE=Release -DOPENSSL_CONFIGURED=1 -DPG_CONFIG=/usr/lib/postgresql/$$PG_VERSION/bin/pg_config $$CMAKE_U26_ARGS; \
	    "$(CMAKE)" --build pg$$PG_VERSION --parallel; \
	    "$(CMAKE)" --build pg$$PG_VERSION --parallel --target package_extensions; \
	done

packaging:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && PG_VERSIONS="$(PG_VERSIONS)" dpkg-buildpackage -b -us -uc $(DPKG_BUILDPACKAGE_FLAGS)

# debian12: sudo apt install -y python3.11-dev python3.11-venv
# ubuntu24: sudo apt install -y python3.12-dev python3.12-venv
# ubuntu22: sudo apt install -y python3.10-dev python3.10-venv


# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all pre check-src check-tools setup apply-patches build pre-resolute building packaging move clean
