CARGO_PROFILE_RELEASE_DEBUG := 2
CARGO_PROFILE_RELEASE_STRIP := none
export CARGO_PROFILE_RELEASE_DEBUG CARGO_PROFILE_RELEASE_STRIP
export DPKG_EXPORT_BUILDFLAGS = 1
include /usr/share/dpkg/buildflags.mk

.NOTPARALLEL:
all: setup build move

TARBALL := pg_mooncake-0.3.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PGRX_VERSION := 0.19.3
PG_VERSIONS ?= 18
JOBS ?= 4
export CARGO_BUILD_JOBS = $(JOBS)
export CARGO_NET_GIT_FETCH_WITH_CLI = true
export DUCKDB_COMMIT = d54cbbe3df17e8e5ce68312f483b4155836112aa
PGRX_INIT_ARGS := $(foreach v,$(PG_VERSIONS),--pg$(v)=/usr/lib/postgresql/$(v)/bin/pg_config)
CMAKE_MIN_VERSION := 3.24
PRIVATE_CMAKE_PREFIX ?= $(HOME)/.cache/pgsty/cmake-3.31.12
SYSTEM_CMAKE_OK := $(shell version="$$(dpkg-query -W -f='$${Version}' cmake 2>/dev/null)"; test -n "$$version" && dpkg --compare-versions "$$version" ge "$(CMAKE_MIN_VERSION)" && echo yes)
ifeq ($(SYSTEM_CMAKE_OK),yes)
CMAKE := /usr/bin/cmake
DPKG_DEP_FLAGS :=
else
CMAKE := $(PRIVATE_CMAKE_PREFIX)/bin/cmake
DPKG_DEP_FLAGS := -d
endif

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first"; exit 1)
	@for v in $(PG_VERSIONS); do case "$$v" in 14|15|16|17|18) ;; *) echo "unsupported PostgreSQL $$v"; exit 1;; esac; done

setup: check-src
	rm -rf $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	cd $(BUILD_DIR) && ./fetch-deps.sh
	cd $(BUILD_DIR) && printf '54488fa56bffb86a9d9ee47794ba433c10114ea34ba8e995a3a38709943f9784  Cargo.lock\n' | sha256sum -c -
	cp -r debian $(BUILD_DIR)/debian
	printf '%s\n' $(PG_VERSIONS) > $(BUILD_DIR)/debian/pgversions
	OS_CODENAME=$$(lsb_release -sc); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

check-pgrx:
	@CURRENT=$$(cargo pgrx --version 2>/dev/null | awk '{print $$2}'); \
	if [ "$$CURRENT" != "$(PGRX_VERSION)" ]; then \
	    echo "found cargo-pgrx $${CURRENT:-<missing>}; expected $(PGRX_VERSION)" >&2; exit 1; \
	fi

check-build-deps:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
ifeq ($(SYSTEM_CMAKE_OK),yes)
	cd $(BUILD_DIR) && dpkg-checkbuilddeps
else
	@../kitware-cmake "$(PRIVATE_CMAKE_PREFIX)" >/dev/null
	@test "$$("$(CMAKE)" --version | awk 'NR == 1 { print $$3 }')" = "3.31.12"
	# Only CMake is supplied outside dpkg; check every other Build-Depends.
	cd $(BUILD_DIR) && dpkg-checkbuilddeps -d 'debhelper-compat (= 13), postgresql-all (>= 217~), build-essential, ninja-build, pkg-config, git, python3, libclang-dev, libicu-dev, libssl-dev, libcurl4-openssl-dev, liblz4-dev, protobuf-compiler'
endif

build: check-pgrx building packaging
building: check-build-deps
	cd $(BUILD_DIR) && cargo pgrx init $(PGRX_INIT_ARGS) --no-run
	cd $(BUILD_DIR) && sha256sum Cargo.lock moonlink/Cargo.lock duckdb_mooncake/moonlink_ffi/Cargo.lock > .cargo-locks.before
	cd $(BUILD_DIR) && cargo fetch --locked
	cd $(BUILD_DIR) && cargo fetch --locked --manifest-path duckdb_mooncake/moonlink_ffi/Cargo.toml
	set -e; cd $(BUILD_DIR); export PATH="$(dir $(CMAKE)):$$PATH"; export RUSTFLAGS="$${RUSTFLAGS:-} -C link-arg=-Wl,--no-gc-sections"; \
	for v in $(PG_VERSIONS); do \
	    $(MAKE) package PG_VERSION=pg$$v PG_CONFIG=/usr/lib/postgresql/$$v/bin/pg_config JOBS=$(JOBS); \
	done
	cd $(BUILD_DIR) && sha256sum -c .cargo-locks.before

packaging: check-build-deps
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage $(DPKG_DEP_FLAGS) -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR)
	cp *.deb $(PKG_OUTPUT_DIR)/
	find . -maxdepth 1 -type f -name '*.ddeb' -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup check-pgrx check-build-deps build building packaging move clean
