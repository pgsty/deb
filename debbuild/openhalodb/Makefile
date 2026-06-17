all: setup build move

TARBALL := openhalodb-1.0.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../SOURCES/$(TARBALL)
	rm -rf build/debian; cp -r debian build/debian
	OS_CODENAME=$$( (lsb_release -sc 2>/dev/null) || (. /etc/os-release 2>/dev/null; echo $${VERSION_CODENAME:-$${UBUNTU_CODENAME:-unknown}}) ); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/debian/changelog; \
	if [ "$$OS_CODENAME" = "resolute" ]; then \
		sed -i 's/llvm::GlobalValue::getGUID(cfuncname)/llvm::GlobalValue::getGUIDAssumingExternalLinkage(cfuncname)/g' build/src/backend/jit/llvm/llvmjit_inline.cpp; \
		sed -i 's/\[\] { return std::make_unique<llvm::backport::SectionMemoryManager>(nullptr, true); }/[](const llvm::MemoryBuffer\&) { return std::make_unique<llvm::backport::SectionMemoryManager>(nullptr, true); }/g' build/src/backend/jit/llvm/llvmjit_wrap.cpp; \
	fi

# building deb
build:
	cd build && dpkg-buildpackage -b -us -uc

# collect deb
move:
	mkdir -p ~/ext/pkg && cp *.deb ~/ext/pkg/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls
