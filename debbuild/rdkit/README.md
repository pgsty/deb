# RDKit with distribution Boost

Debian 13 (Trixie), Ubuntu 24.04 (Noble), and Ubuntu 26.04 (Resolute) build
RDKit 2026.09.1 with their default system Boost: 1.83, 1.83, and 1.90,
respectively. Both amd64 and arm64 build PostgreSQL 14-18 cartridges, the
shared runtime, Python bindings, data, and development files together.
No Boost library, header bundle, loader configuration, or private Boost
runtime package is shipped. Normal automatic dependencies on distribution
Boost shared libraries are retained.

Resolute currently ships SFCGAL 2.2.0 linked to distribution Boost 1.88,
while RDKit and ProvSQL use distribution Boost 1.90. Validate this existing
system-library combination with load-order and persisted-data tests; do not
describe Resolute as loading only one Boost version or replace SFCGAL as part
of an RDKit rebuild.

InChI 1.07.5 and its `bcf_s.h` development header are required. The `inchi`
backport recipe supplies both; keep JSON and InChI functionality enabled.

Bookworm and Jammy keep their existing 202303.3 PG17-18 gap recipes and
PGDG runtime. Their default Boost 1.74 cannot build the current release's
Boost.JSON support. This update does not replace their Boost or RDKit.

## Sources

Run `pig build get rdkit` first. If unavailable, copy only missing files
from `~/pgsty/repo/ext/src/` to the builder's `~/debbuild/SOURCES/`:

- `rdkit-Release_2026_09_1.tar.gz`
- `better-enums-0.11.3-enum.h`
- `RingDecomposerLib-1.1.3_rdkit.tar.gz`

The modern recipe uses the same official archive and offline patches as
the RPM recipe. Legacy suites still use their existing PGDG source triads.

## Build and acceptance

Run `make` in `~/debbuild/rdkit`. Packages and automatic dbgsym packages
are copied to `~/ext/pkg/`. The shared runtime is compiled once; the same
CMake build is reconfigured for each supported PostgreSQL major.

Before publication, verify package dependencies and ELF linkage resolve
only to the system Boost, and exercise RDKit with PostGIS/SFCGAL and
ProvSQL in one server process. Include different extension load orders,
persisted `xqmol` queries in new sessions, and a ProvSQL preload restart.
Retain debug packages and verify JSON, InChI, Python and 3D conformers.

The prior repository migration preference only selects historical
`202503.6-4PIGSTY` packages; it must not be generalized to the new version.
Building and collecting these packages does not publish them.
