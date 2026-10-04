# PostGIS and GIS dependencies

The core source archives are byte-identical to the PGSTY EL9/EL10 RPM builds:

| Recipe | Version | Main Debian package |
| --- | --- | --- |
| geos | 3.14.1 | libgeos-c1t64, libgeos3.14.1 |
| proj | 9.8.1 | libproj25 |
| sfcgal | 2.2.0 | libsfcgal2 |
| libgeotiff | 1.7.4 | libgeotiff5 |
| librttopo | 1.1.0 | librttopo1 |
| spatialite | 5.1.0 | libspatialite8t64 |
| gdal | 3.13.3 | libgdal39 |
| postgis | 3.6.4 | postgresql-<major>-postgis-3 |

Debian 12 and Ubuntu 22.04 retain their native `libgeos-c1v5` and
`libspatialite8` package names. On these two distributions, build `cgal`
5.6.1 before SFCGAL; newer distributions supply suitable CGAL headers.

Ubuntu noble has no Arrow/GTA development packages in the configured OS/PGDG
repositories. `libarrow` 9.0.0 and `libgta` 1.2.1 provide those GDAL backends.
Arrow uses its upstream-pinned xsimd 8.1.0 headers from a separately archived,
checksum-verified tarball; noble's xsimd 12 is not compatible with Arrow 9.
Other dependencies come from the distribution and PGDG PostgreSQL packages
and tooling, including the Perl DBD::Pg module used by tests.
Source URLs, checksums and Debian packaging baselines are recorded in
[`../../bin/postgis-sources.json`](../../bin/postgis-sources.json).

The GDAL Javadoc patch is shared verbatim with RPM. The cleanup patch has
the same changes, with only its file-header prefixes converted from RPM's
`-p0` form to the `a/` and `b/` form required by Debian source format 3.0
(quilt). RPM-only installation-prefix fixes are not used for native Debian
multiarch paths.

The SpatiaLite test patches account for the pinned newer dependencies without
changing library code: PROJ error text, GEOS results for invalid zero-length
lines, and equivalent binary64 coordinate text from SQLite. Maximum-inscribed-
circle tests check the radius and geometric containment instead of fixing a
non-unique center. All test programs remain enabled. Their SQLite fixtures are
restored even when a test fails, so a resumed build uses the original inputs.

On ARM64, librttopo disables floating-point contraction with
`-ffp-contract=off`. The unmodified SpatiaLite `check_toponoface2d` test exposed
an edge-split failure in both the Ubuntu and EL9 builds; the same compiler
setting is applied to the RPM spec. Optimization, LTO and debug symbols remain
enabled.

SpatiaLite is built without FreeXL, matching the RPM recipe. Its optional
`load_XL` C symbol is therefore absent; software using that standalone Excel
import API needs a SpatiaLite build with FreeXL enabled. GDAL's own FreeXL
backend remains enabled. This pilot validates the PostGIS dependency stack,
not compatibility with every application that uses Ubuntu's GIS libraries.

Build and install dependencies before their consumers:

1. CGAL where required, then GEOS, PROJ, SFCGAL, Arrow and GTA.
2. GeoTIFF and librttopo, then SpatiaLite.
3. GDAL, including Python and Java bindings.
4. PostGIS, including raster, SFCGAL, topology, Tiger geocoder, address
   standardizer, client tools (including topology import/export), GUI, PDF
   documentation and LLVM bitcode.

First run `pig build get <tarball>` inside the builder. If it fails, copy only
the missing archive from the shared `~/pgsty/repo/ext/src` directory into
`~/ext/src`, reached by `~/debbuild/SOURCES`. Do not sync the entire source
archive directory.

Each recipe supports `make setup`, `make build` and `make move` in that order.
Plain `make` runs the stages sequentially. For the representative build use:

```sh
cd ~/debbuild/postgis
make PG_VERSIONS=18 BUILD_JOBS=3
```

When building as root under `/root` in a disposable container, the PostgreSQL
test server runs as `postgres` and needs traversal access to the build tree.
The pilot grants only the missing directory execute bit with `chmod o+x /root`
inside that container. A normal non-root build does not need this adjustment.

The pilot images also exclude documentation and manual pages during package
installation. In the disposable validation containers, a final dpkg
`path-include=/usr/share/*` rule restores the complete payload. Reinstall the
locally built packages before comparing installed files with their archives.

The default PostGIS PG range is 14–18. Native libraries use Debian multiarch
paths and native package names; RPM-specific `/usr/geos314` prefixes are not
copied into DEB packages. `dh_strip` produces the automatic dbgsym packages.

Install each locally built library and its development package before the
next stage. Hold those packages in a disposable pilot container so APT does
not replace them with a higher revision from PGDG while resolving later build
dependencies. Package-version checks and ELF dependency inspection must verify
the final selected libraries.

The shared `bin/postgis-test.sql` checks all seven extensions and representative
GEOS, PROJ, SFCGAL, raster and topology operations in a disposable database.
Builder logs, test results and package audits are collected under `apt/noble/`
for the pilot. A single pilot does not certify the full platform matrix or
publish any packages.

The full build completed on 2026-10-04 across Debian 12/13 and Ubuntu
22.04/24.04/26.04, on amd64 and arm64, using their corresponding
`pgsty/{d12,d13,u22,u24,u26}{,a}:build` images. PostgreSQL 14–18 passed on
all ten platforms, producing 714 DEBs including 240 debug packages.
PostGIS passed 35,700 installation/self-upgrade SQL regression executions
and 20,700 CUnit tests. Installed payloads, native dependencies, GDAL
Python/Java bindings, debug packages and LLVM bitcode were verified.
Artifacts and SHA-256 receipts are retained under
`apt/<codename>/postgis-full-20261004/<architecture>/`; no APT publication
was performed.
