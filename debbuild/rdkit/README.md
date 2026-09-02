# RDKit suite and cartridge gap packages

This recipe has two suite-specific modes.  The legacy Bookworm/Jammy inputs
only fill PostgreSQL-major gaps and link against the public distribution
runtime, while Resolute builds one complete, ABI-coherent RDKit suite:

- Debian 12 / Ubuntu 22.04: build PostgreSQL 17 and 18 from the official PGDG
  `202303.3` source, using PGDG `librdkit1` and `librdkit-dev`.
- Ubuntu 26.04: build the complete `202603.6` suite (runtime, development,
  data, Python bindings, and PostgreSQL 14-17 cartridges) from the Pigsty
  Resolute source triad with system InChI 1.07.5.
- Debian 13 / Ubuntu 24.04: do not build; PGDG supplies RDKit and cartridges
  for PostgreSQL 14-18.

The generated cartridge packages follow the repository's normal
`pg_buildext` convention.  The Resolute build also emits `librdkit1t64`,
`librdkit-dev`, `rdkit-data`, and `python3-rdkit` from the same source and
compiler invocation, so the C++ and Python ABI cannot drift from the
cartridges.

Bookworm and Jammy remain pinned to the 202303.3 gap build. Their Boost 1.74
toolchain predates Boost.JSON (introduced in 1.75), while RDKit 2026.03.6
requires Boost 1.81 and uses Boost.JSON in MolInterchange. Updating those
suites would require a coordinated Boost backport or disabling a supported
RDKit feature, so the old triads are intentionally retained.

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

The resulting packages are copied to `~/ext/pkg/`. On Trixie and Noble the
target exits before building and explains that PGDG already covers the full
active matrix.
