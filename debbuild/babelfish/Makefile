all: chain

TARBALL := babelfishpg-17.8-5.5.0.tar.gz
PKGDIR := $(HOME)/ext/pkg
CORE_DEB = $(shell ls -1t $(PKGDIR)/babelfishpg-17_*.deb 2>/dev/null | head -n 1)
ANTLR_DEB = $(shell ls -1t $(PKGDIR)/libantlr4-runtime413_*.deb 2>/dev/null | head -n 1)
ANTLR_DEV_DEB = $(shell ls -1t $(PKGDIR)/libantlr4-runtime413-dev_*.deb 2>/dev/null | head -n 1)

chain: build-pg build-antlr install-prereq setup build move

build-pg:
	$(MAKE) -C ../babelfishpg_17

build-antlr:
	$(MAKE) -C ../antlr4_runtime413

install-prereq:
	@if [ -z "$(CORE_DEB)" ] || [ -z "$(ANTLR_DEB)" ] || [ -z "$(ANTLR_DEV_DEB)" ]; then \
		echo "missing prerequisite debs under $(PKGDIR)"; \
		ls -l $(PKGDIR) || true; \
		exit 1; \
	fi
	@SUDO=$$( [ "$$(id -u)" -eq 0 ] && echo "" || echo "sudo" ); \
	APT="$$SUDO apt-get -o DPkg::Lock::Timeout=600"; \
	SYS_ANTLR_PKGS="$$(dpkg-query -W -f='$${Package}\n' 'antlr4' 'libantlr4-runtime*' 2>/dev/null | tr '\n' ' ')"; \
	if [ -n "$$SYS_ANTLR_PKGS" ]; then \
		$$APT -y purge $$SYS_ANTLR_PKGS || true; \
		$$APT -y autoremove || true; \
	fi; \
	$$APT -y install "$(ANTLR_DEB)" "$(ANTLR_DEV_DEB)"; \
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	if [ "$$OS_CODENAME" = "resolute" ]; then \
		$$APT -y install --reinstall "$(CORE_DEB)"; \
	else \
		$$APT -y install "$(CORE_DEB)"; \
	fi; \
	if [ "$$OS_CODENAME" = "resolute" ] && ! command -v java >/dev/null 2>&1; then \
		$$APT -y install openjdk-21-jre-headless || $$APT -y install default-jre-headless; \
	fi

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	cp -a build/babelfish_extensions/. build/
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog; \
	if [ "$$OS_CODENAME" = "resolute" ]; then \
		sed -i 's/char[[:space:]]*\*pos;/const char *pos;/' build/contrib/babelfishpg_tds/src/backend/tds/tdsrpc.c; \
	fi

# building deb
build:
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building artifacts
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all chain build-pg build-antlr install-prereq setup update build move clean ls
