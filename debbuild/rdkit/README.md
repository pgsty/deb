# RDKit on Debian 13 and Ubuntu 24

This recipe packages the Debian `rdkit 202503.6-4` source package for Pigsty.

It builds:

- target platform: Debian 13 (`d13`, `d13a`) and Ubuntu 24 (`u24`, `u24a`)
- target PostgreSQL majors: 14-18 when the corresponding PostgreSQL development
  packages are available on the builder
- output packages:
  - `librdkit1t64`
  - `postgresql-14-rdkit` ... `postgresql-18-rdkit`

The actual PostgreSQL package set comes from the installed
`postgresql-server-dev-*` packages. The recipe exports
`PG_SUPPORTED_VERSIONS=installed`, so `pg_buildext supported-versions`
follows what is actually present on the builder:

- stock Debian 13: normally only PostgreSQL 17 is available, so the build
  yields `postgresql-17-rdkit`
- Pigsty/PGDG-prepared builders: PostgreSQL 14-18 can be installed together,
  so the build can yield `postgresql-14-rdkit` through `postgresql-18-rdkit`

On Ubuntu 24 (`noble`), the recipe follows PGDG's packaging behavior and
disables InChI support automatically. Noble ships `libinchi 1.03`, which lacks
the `MakeINCHIFromMolfileText` API required by the Debian 13 InChI-enabled
build.

If you have already backported and installed newer `libinchi` packages on
Ubuntu 24, build with `ENABLE_INCHI=1` to keep InChI support enabled.

## Source files

Fetch the Debian source package first:

```bash
pig build get rdkit
```

If `pig build get` does not provide the files, copy them from the local
authoritative mirror `~/pgsty/repo/ext/src/` into `../SOURCES/` next to this
recipe:

- `rdkit_202503.6-4.dsc`
- `rdkit_202503.6.orig.tar.xz`
- `rdkit_202503.6-4.debian.tar.xz`

This recipe uses `dpkg-source -x` so Debian's upstream patches are preserved.

## One-time build dependencies

```bash
apt-get update
apt-get install -y \
  build-essential \
  architecture-is-64-bit architecture-is-little-endian \
  bison catch2 cmake debhelper-compat dpkg-dev flex \
  libboost-dev libboost-iostreams-dev libboost-program-options-dev \
  libboost-regex-dev libboost-thread-dev libcairo2-dev libeigen3-dev \
  libfreetype-dev libsqlite3-dev \
  postgresql-server-dev-all rapidjson-dev zlib1g-dev
```

Install `libinchi-dev` as well when building on Debian 13. The recipe removes
that build dependency automatically on Ubuntu 24, where RDKit is built without
InChI support.

To build PostgreSQL 14-18 together, the builder must also have
`postgresql-server-dev-14` through `postgresql-server-dev-18` installed.
Stock Debian 13 does not provide all of these packages; use a Pigsty/PGDG repo
prepared builder if you need the full 14-18 matrix.

## Build

```bash
cd ~/debbuild/rdkit
make
```

`make` always builds every PostgreSQL major detected by `pg_buildext
supported-versions`. The resulting `.deb` files are copied to `~/ext/pkg/`.

To build an InChI-enabled cartridge on Ubuntu 24 after installing a backported
`libinchi-dev`/`libinchi1.07`, run:

```bash
cd ~/debbuild/rdkit
make ENABLE_INCHI=1
```
