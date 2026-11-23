# pg_graphql 1.6.3

Build PostgreSQL 15 through 19 from the official `pg_graphql-1.6.3.tar.gz`
archive (SHA-256
`0d35a8d14630d29914c1338ae6fb1e2eb9300d0409fec399e55c69860c7f7cf4`).
This release fixes quoting of primary-key column names in generated nodeId SQL.

The builders use Rust 1.100.0 and cargo-pgrx 0.20.1. Both recipes apply the
0.19.3 compatibility patch first, followed by the pgrx 0.20.1 patch.
PostgreSQL server headers used by bindgen require `libicu-dev`. The final
Cargo.lock has SHA-256
`ffc1d8ffac0daa0ae82097c439cdc735705aa201148593ee37bf7028c0c0f0ac`.
The recipe fetches with `--locked`, compiles offline and verifies the lock
after packaging.

Upstream 1.6.3 ships no extension upgrade SQL scripts. Packages contain the
pgrx-generated `pg_graphql--1.6.3.sql` base script and the upstream control
file and shared library. The old packaging-only 1.6.1-to-1.6.2 update script
is retired; packaging does not synthesize upgrade paths.

Release optimization and fat LTO are preserved. Debug information is
enabled at level 2, stripping is deferred to debhelper, and each native
package has a matching automatic dbgsym package. The README is installed
in the package's private documentation directory.

Production validation on 2026-11-03 covered bookworm, trixie, jammy, noble
and resolute on native amd64 and arm64 builders, PostgreSQL 14 through 18.
All 50 combinations passed installation and the 123 unmodified upstream
SQL regression tests, including the quoted-primary-key/nodeId security
regression and depth-limit tests (6,150 cases in total). All 50 main packages
and 50 matching dbgsym packages passed architecture, dependency, payload,
private-documentation, DWARF and build-ID checks and were collected into
the local `apt/<codename>/` directories.

This validation did not import or publish an APT repository or write to
the metadata database. The metadata version, DEB version, source filename
and modification date remain pending until database updates are authorized.
