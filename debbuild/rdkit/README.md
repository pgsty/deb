# RDKit cartridge gap packages

This recipe deliberately does not publish another RDKit runtime. It only fills
PostgreSQL-major gaps and links each cartridge against the public distribution
runtime and development package:

- Debian 12 / Ubuntu 22.04: build PostgreSQL 17 and 18 from the official PGDG
  `202303.3` source, using PGDG `librdkit1` and `librdkit-dev`.
- Ubuntu 26.04: build PostgreSQL 14-17 from Debian `202503.6` source, using
  Ubuntu `librdkit1t64` and `librdkit-dev`.
- Debian 13 / Ubuntu 24.04: do not build; PGDG supplies RDKit and cartridges
  for PostgreSQL 14-18.

The generated `postgresql-PGVERSION-rdkit` packages follow the repository's
normal `pg_buildext` convention: `debian/pgversions` selects the supported
majors, `PGVERSION` expands the binary package name, and `${shlibs:Depends}`
records the runtime ABI requirement found by `dpkg-shlibdeps`. No PostgreSQL
major is duplicated as a literal binary-package stanza.

Existing Pigsty full-runtime packages remain installable and are not forcibly
downgraded.

## Migration

Keep the existing Pigsty full-runtime packages available for installed hosts
and exact-version reinstalls, but do not create new duplicates on Trixie,
Noble, or Resolute PG18. Before publishing this transition, make the
new-install manifest or repository policy choose the complete PGDG/Ubuntu
package set on those combinations. Pigsty installs
`roles/node/files/rdkit-migration.pref`, which gives only the historical
Pigsty `202503.6-4PIGSTY` t64 builds priority 400. The retained packages
therefore stay available, while a fresh install prefers an upstream package
at priority 500. APT does not downgrade an installed Pigsty runtime because
the upstream priority remains below 1000. On Bookworm and Jammy the PGDG
version already sorts above the legacy Pigsty runtime, so publish the new
PG17-18 cartridge-only packages before relying on that normal upgrade path.

## Source files

Fetch the source package first:

```bash
pig build get rdkit
```

If it is unavailable, copy only the three files for the active suite from
`~/pgsty/repo/ext/src/` into `../SOURCES/`. The Makefile names the exact files
for Bookworm, Jammy, and Resolute and uses `dpkg-source -x` to retain the
official source patch stack.

## Build

```bash
cd ~/debbuild/rdkit
make
```

The resulting cartridge packages are copied to `~/ext/pkg/`. On Trixie and
Noble the target exits before building and explains that PGDG already covers
the full active matrix.
