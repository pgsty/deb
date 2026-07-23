all: move

TARBALL := faker_22.0.0.orig.tar.gz
TARBALL_SHA256 := e0c92b3d474422344b95f90d4d24b9a2b101e16bd3a3a08a534b9b928126a935
SOURCE_TARBALL ?= $(or $(wildcard $(HOME)/ext/src/$(TARBALL)),$(wildcard ../SOURCES/$(TARBALL)))
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
SUPPORTED_CODENAMES := bookworm jammy

check-src:
	@test -n "$(SOURCE_TARBALL)" -a -f "$(SOURCE_TARBALL)" || (echo "missing $(TARBALL) under $(HOME)/ext/src or ../SOURCES, run pig build get first; if needed, copy it there"; exit 1)
	@printf '%s  %s\n' '$(TARBALL_SHA256)' '$(SOURCE_TARBALL)' | sha256sum --check --status || (echo "SHA-256 mismatch for $(SOURCE_TARBALL)"; exit 1)

clean-artifacts:
	rm -f *.deb *.buildinfo *.changes

setup: clean-artifacts check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' -o -name '__pycache__' \) -delete
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	case " $(SUPPORTED_CODENAMES) " in *" $$OS_CODENAME "*) ;; *) echo "unsupported suite: $$OS_CODENAME (expected: $(SUPPORTED_CODENAMES))"; exit 1;; esac; \
	sed -i "1s/1PIGSTY)/1PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build: setup
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move: build
	mkdir -p $(PKG_OUTPUT_DIR)
	@set -e; files=$$(find . -maxdepth 1 -type f -name 'python3-fake-factory_*.deb'); test -n "$$files"; cp $$files $(PKG_OUTPUT_DIR)/

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.deb

.PHONY: all check-src clean-artifacts setup build move clean
