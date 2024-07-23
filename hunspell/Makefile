all: setup build move

TARBALL := hunspell-1.0.tar.gz

# prepare directory
setup:
	rm -rf build; mkdir -p build
	tar -C build --strip-components=1 -xf ../tarball/$(TARBALL)

build: build-cs-cz build-de-de build-en-us build-fr build-ne-np build-nl-nl build-nn-no build-pt-pt build-ru-ru build-ru-ru-aot

build-cs-cz:
	$(eval LANGUAGE=cs-cz)
	$(eval LANGUAGE_UNDERSCORE=$(subst -,_,$(LANGUAGE)))
	rm -rf build/hunspell_$(LANGUAGE_UNDERSCORE)/debian; cp -r debian build/hunspell_$(LANGUAGE_UNDERSCORE)/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "1s/hunspell/hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "1s/Source: hunspell/Source: hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/rules
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && pg_buildext updatecontrol
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && dpkg-buildpackage -b -us -uc

build-de-de:
	$(eval LANGUAGE=de-de)
	$(eval LANGUAGE_UNDERSCORE=$(subst -,_,$(LANGUAGE)))
	rm -rf build/hunspell_$(LANGUAGE_UNDERSCORE)/debian; cp -r debian build/hunspell_$(LANGUAGE_UNDERSCORE)/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "1s/hunspell/hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "1s/Source: hunspell/Source: hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/rules
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && pg_buildext updatecontrol
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && dpkg-buildpackage -b -us -uc

build-en-us:
	$(eval LANGUAGE=en-us)
	$(eval LANGUAGE_UNDERSCORE=$(subst -,_,$(LANGUAGE)))
	rm -rf build/hunspell_$(LANGUAGE_UNDERSCORE)/debian; cp -r debian build/hunspell_$(LANGUAGE_UNDERSCORE)/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "1s/hunspell/hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "1s/Source: hunspell/Source: hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/rules
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && pg_buildext updatecontrol
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && dpkg-buildpackage -b -us -uc

build-fr:
	$(eval LANGUAGE=fr)
	$(eval LANGUAGE_UNDERSCORE=$(subst -,_,$(LANGUAGE)))
	rm -rf build/hunspell_$(LANGUAGE_UNDERSCORE)/debian; cp -r debian build/hunspell_$(LANGUAGE_UNDERSCORE)/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "1s/hunspell/hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "1s/Source: hunspell/Source: hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/rules
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && pg_buildext updatecontrol
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && dpkg-buildpackage -b -us -uc

build-ne-np:
	$(eval LANGUAGE=ne-np)
	$(eval LANGUAGE_UNDERSCORE=$(subst -,_,$(LANGUAGE)))
	rm -rf build/hunspell_$(LANGUAGE_UNDERSCORE)/debian; cp -r debian build/hunspell_$(LANGUAGE_UNDERSCORE)/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "1s/hunspell/hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "1s/Source: hunspell/Source: hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/rules
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && pg_buildext updatecontrol
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && dpkg-buildpackage -b -us -uc

build-nl-nl:
	$(eval LANGUAGE=nl-nl)
	$(eval LANGUAGE_UNDERSCORE=$(subst -,_,$(LANGUAGE)))
	rm -rf build/hunspell_$(LANGUAGE_UNDERSCORE)/debian; cp -r debian build/hunspell_$(LANGUAGE_UNDERSCORE)/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "1s/hunspell/hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "1s/Source: hunspell/Source: hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/rules
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && pg_buildext updatecontrol
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && dpkg-buildpackage -b -us -uc

build-nn-no:
	$(eval LANGUAGE=nn-no)
	$(eval LANGUAGE_UNDERSCORE=$(subst -,_,$(LANGUAGE)))
	rm -rf build/hunspell_$(LANGUAGE_UNDERSCORE)/debian; cp -r debian build/hunspell_$(LANGUAGE_UNDERSCORE)/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "1s/hunspell/hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "1s/Source: hunspell/Source: hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/rules
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && pg_buildext updatecontrol
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && dpkg-buildpackage -b -us -uc

build-pt-pt:
	$(eval LANGUAGE=pt-pt)
	$(eval LANGUAGE_UNDERSCORE=$(subst -,_,$(LANGUAGE)))
	rm -rf build/hunspell_$(LANGUAGE_UNDERSCORE)/debian; cp -r debian build/hunspell_$(LANGUAGE_UNDERSCORE)/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "1s/hunspell/hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "1s/Source: hunspell/Source: hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/rules
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && pg_buildext updatecontrol
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && dpkg-buildpackage -b -us -uc

build-ru-ru:
	$(eval LANGUAGE=ru-ru)
	$(eval LANGUAGE_UNDERSCORE=$(subst -,_,$(LANGUAGE)))
	rm -rf build/hunspell_$(LANGUAGE_UNDERSCORE)/debian; cp -r debian build/hunspell_$(LANGUAGE_UNDERSCORE)/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "1s/hunspell/hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "1s/Source: hunspell/Source: hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/rules
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && pg_buildext updatecontrol
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && dpkg-buildpackage -b -us -uc

build-ru-ru-aot:
	$(eval LANGUAGE=ru-ru-aot)
	$(eval LANGUAGE_UNDERSCORE=$(subst -,_,$(LANGUAGE)))
	rm -rf build/hunspell_$(LANGUAGE_UNDERSCORE)/debian; cp -r debian build/hunspell_$(LANGUAGE_UNDERSCORE)/debian
	OS_CODENAME=$(shell lsb_release -sc); \
	sed -i "1s/PIGSTY)/PIGSTY~$${OS_CODENAME})/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "1s/hunspell/hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/changelog
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "1s/Source: hunspell/Source: hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/control.in
	sed -i "s/-hunspell/-hunspell-$(LANGUAGE)/" build/hunspell_$(LANGUAGE_UNDERSCORE)/debian/rules
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && pg_buildext updatecontrol
	cd build/hunspell_$(LANGUAGE_UNDERSCORE) && dpkg-buildpackage -b -us -uc

# collect deb
move:
	cp build/*.deb ~/

# remove building craps
clean:
	rm -rf *.buildinfo *.changes *.ddeb *.deb

.PHONY: all setup update build move clean ls

all: setup build move ls
