all: setup build move

TARBALL := Biscuit-2.4.3.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg
PATCH_SERIES := debian/patches/series

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

# prepare directory
setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	sed -i '1i .DEFAULT_GOAL := all' $(BUILD_DIR)/Makefile
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	@$(MAKE) apply-patches
	OS_CODENAME=$$(lsb_release -sc 2>/dev/null || true); \
	if [ -z "$$OS_CODENAME" ] && [ -r /etc/os-release ]; then . /etc/os-release; OS_CODENAME=$${VERSION_CODENAME:-$${UBUNTU_CODENAME:-}}; fi; \
	OS_CODENAME=$${OS_CODENAME:-unknown}; \
	ARCH=$$(dpkg --print-architecture 2>/dev/null || true); \
	if [ "$$ARCH" = "amd64" ] && { [ "$$OS_CODENAME" = "jammy" ] || [ "$$OS_CODENAME" = "noble" ]; }; then \
		sed -i.bak '/^[[:space:]]*-fPIC$$/a override CFLAGS += -fno-lto' $(BUILD_DIR)/Makefile; \
		rm -f $(BUILD_DIR)/Makefile.bak; \
	fi; \
	sed -i.bak "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog; \
	rm -f $(BUILD_DIR)/debian/changelog.bak

apply-patches:
	@set -e; \
	while IFS= read -r p; do \
		case "$$p" in ""|\#*) continue ;; esac; \
		echo "apply $$p"; \
		(cd $(BUILD_DIR) && patch -p1 --forward -f < "debian/patches/$$p"); \
	done < "$(PATCH_SERIES)"

# building deb
build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/

# remove building craps
clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup apply-patches build move clean
