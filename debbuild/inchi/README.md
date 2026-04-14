# InChI Backport for Noble

This recipe rebuilds the Debian `inchi` source package on Ubuntu 24 (`noble`)
so RDKit can later be built with InChI enabled again.

It produces:

- `1.07.3+dfsg-1PIGSTY~noble` on noble
- `libinchi1.07`
- `libinchi-dev`
- `libinchi-bin`

The recipe uses the Debian source package directly via `dpkg-source -x`.
The build tree then gets a Pigsty version suffix and, on `noble`, the packaging
injects `DEB_BUILD_MAINT_OPTIONS=optimize=-lto` into `debian/rules` because
GCC 13 on noble hits an LTO ICE in the upstream `inchi_main` build.

## Source Inputs

Fetch the Debian source trio first:

- `inchi_1.07.3+dfsg-1.dsc`
- `inchi_1.07.3+dfsg.orig.tar.xz`
- `inchi_1.07.3+dfsg-1.debian.tar.xz`

If `pig build get inchi` is unavailable, copy those files from the Debian
source package into `../SOURCES/` next to this recipe.

## Build

```bash
cd ~/debbuild
make inchi
```

The resulting `.deb` files are copied to `~/ext/pkg/`.
