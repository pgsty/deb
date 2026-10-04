# H3 4.5.0

Builds `postgresql-14-h3` through `postgresql-18-h3`, each containing both
`h3` and `h3_postgis`. The latter requires `h3`, `postgis`, and
`postgis_raster`; the package therefore depends on the corresponding PostGIS
binary and SQL-script packages.

The official [h3-pg v4.5.0 release](https://github.com/postgis/h3-pg/releases/tag/v4.5.0)
pins [H3 core v4.5.0](https://github.com/uber/h3/releases/tag/v4.5.0).
Both source archives are verified by SHA256 before unpacking. The core is
linked statically using CMake's `FETCHCONTENT_SOURCE_DIR_H3`, so the actual
compilation does not download another copy of H3. Only the `h3-pg` install
component is packaged; no public `libh3` library or headers are installed.

`pg_buildext` generates the per-major control records and runs CMake for each
major. The package-local configure helper selects the versioned LLVM tools
from each PostgreSQL development package's clang dependency, because Debian
does not provide the unversioned tool names searched by upstream CMake.
The package-local install helper uses the same PostgreSQL dependency
and LLVM compatibility substvars as `pg_buildext install`, while restricting
CMake installation to the extension component. `dpkg-buildflags` and
`RelWithDebInfo` retain DWARF before debhelper splits the automatic dbgsym
packages. Upstream regression targets are disabled at package build time;
acceptance must install the resulting packages and exercise both extensions.
