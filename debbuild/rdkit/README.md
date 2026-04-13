# RDKit on Debian 13

This recipe packages the Debian `rdkit 202503.6-4` source package for Pigsty.

It intentionally keeps the scope narrow:

- target platform: Debian 13 (`d13`, `d13a`)
- target PostgreSQL major: 18 by default, override with `PG_MAJOR=<major>`
- output packages:
  - `librdkit1t64`
  - `postgresql-<major>-rdkit`

## Source files

Place these files under `~/pgsty/repo/ext/sol/src/` or `~/pgsty/repo/ext/src/`:

- `rdkit_202503.6-4.dsc`
- `rdkit_202503.6.orig.tar.xz`
- `rdkit_202503.6-4.debian.tar.xz`

This recipe uses `dpkg-source -x` so Debian's upstream patches are preserved.

## One-time build dependencies on d13

```bash
apt-get update
apt-get install -y \
  architecture-is-64-bit architecture-is-little-endian \
  bison catch2 cmake debhelper-compat dpkg-dev flex \
  libboost-dev libboost-iostreams-dev libboost-program-options-dev \
  libboost-regex-dev libboost-thread-dev libcairo2-dev libeigen3-dev \
  libfreetype-dev libinchi-dev libsqlite3-dev \
  postgresql-18 postgresql-server-dev-18 rapidjson-dev zlib1g-dev
```

For other PostgreSQL majors, replace `18` in the two PostgreSQL package
names above and pass `PG_MAJOR=<major>` to `make`.

## Build

```bash
cd ~/debbuild/rdkit
make
```

For PostgreSQL 14, use:

```bash
cd ~/debbuild/rdkit
make PG_MAJOR=14
```

The resulting `.deb` files are copied to `~/ext/pkg/`.
