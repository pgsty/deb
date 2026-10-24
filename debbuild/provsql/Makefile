all: setup build move

TARBALL := provsql-1.13.0.tar.gz
SOURCE_TARBALL ?= ../SOURCES/$(TARBALL)
BUILD_DIR := build
PKG_OUTPUT_DIR ?= $(HOME)/ext/pkg

check-src:
	@test -f "$(SOURCE_TARBALL)" || (echo "missing $(SOURCE_TARBALL), run pig build get first; if needed, copy $(TARBALL) into ../SOURCES"; exit 1)

setup: check-src
	rm -rf $(BUILD_DIR); mkdir -p $(BUILD_DIR)
	tar -C $(BUILD_DIR) --strip-components=1 -xf "$(SOURCE_TARBALL)"
	find $(BUILD_DIR) \( -name '._*' -o -name '.DS_Store' \) -delete
	sed -i 's/^ARGS = with_llvm=no$$/ARGS = with_llvm=yes/' $(BUILD_DIR)/Makefile
	# PGXS bitcode flags do not inherit the native C++17 compiler flags.
	printf '\noverride BITCODE_CXXFLAGS += -std=c++17\nifneq ($$(filter 14 15,$$(PGVER_MAJOR)),)\noverride BITCODE_CXXFLAGS += -Wno-register\nendif\n' >> $(BUILD_DIR)/Makefile.internal
	rm -rf $(BUILD_DIR)/debian; cp -r debian $(BUILD_DIR)/debian
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PGSTY)/PGSTY~$${OS_CODENAME})/" $(BUILD_DIR)/debian/changelog

build:
	cd $(BUILD_DIR) && pg_buildext updatecontrol
	cd $(BUILD_DIR) && dpkg-buildpackage -b -us -uc

move:
	mkdir -p $(PKG_OUTPUT_DIR) && cp *.deb $(PKG_OUTPUT_DIR)/ && find . -maxdepth 1 -type f -name "*.ddeb" -exec cp {} $(PKG_OUTPUT_DIR)/ \;

clean:
	rm -rf $(BUILD_DIR) *.buildinfo *.changes *.ddeb *.deb

.PHONY: all check-src setup build move clean
