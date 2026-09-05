# InChI Debian Rebuild

This recipe rebuilds the InChI 1.07.5 Debian source package with Pigsty
packaging revisions. The current production target is Ubuntu 26 (`resolute`),
on amd64 and arm64; the existing Noble compatibility workaround is retained.

It produces:

- Version `1.07.5+dfsg-2PGSTY~<codename>`
- `libinchi1.07`
- `libinchi-dev`
- `libinchi-bin`
- `libinchi1.07-dbgsym`
- `libinchi-bin-dbgsym`

The recipe uses the matching Debian source trio directly via `dpkg-source -x`.
The `+dfsg` orig is reproducibly repacked from the official
[`v1.07.5`](https://github.com/IUPAC-InChI/InChI/tree/v1.07.5) tag using
`debian/watch` and `debian/copyright`'s `Files-Excluded` list. That list
removes prebuilt directories plus the non-free CCDC test dataset; it is checked
after repacking. The source archives remain unchanged. A local packaging patch
adds the revision changelog and overrides both CLI linkers without `-s`.
The Debian source patch already passes `dpkg-buildflags` to compilation and
linking; `dh_strip` can therefore extract DWARF into both normal dbgsym packages.
The build tree gets a Pigsty version suffix and, on `noble`,
the packaging injects `DEB_BUILD_MAINT_OPTIONS=optimize=-lto` because GCC 13
can hit an LTO ICE in the upstream `inchi_main` build.

## Source Inputs

Fetch the Debian source trio first:

- `inchi_1.07.5+dfsg-1.dsc`
- `inchi_1.07.5+dfsg.orig.tar.xz`
- `inchi_1.07.5+dfsg-1.debian.tar.xz`

If `pig build get inchi` is unavailable, copy those files from the Debian
source package into `../SOURCES/` next to this recipe.

## Build

```bash
cd ~/debbuild
make inchi
```

The resulting `.deb` and `.ddeb` files are copied to `~/ext/pkg/`.
