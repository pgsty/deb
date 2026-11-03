# pg_graphql 1.6.3

Build PostgreSQL 14 through 18 from the official `pg_graphql-1.6.3.tar.gz`
archive (SHA-256
`0d35a8d14630d29914c1338ae6fb1e2eb9300d0409fec399e55c69860c7f7cf4`).
This release fixes quoting of primary-key column names in generated nodeId SQL.

The shared RPM/DEB patch pins the seven pgrx crates to 0.19.3 and declares
Rust 1.96 as the minimum supported compiler. The builders use Rust 1.99.0
and cargo-pgrx 0.19.3; the recipe checks their versions explicitly.
Build dependencies include libicu-dev because PostgreSQL server headers
used by bindgen include ICU headers. The
patched Cargo.lock SHA-256 is
`75cd535ec2785e673fc2f2ff2cb40b452356ca541397ceba489287498f12e0d5`.
Other package versions remain unchanged; Cargo also resolves the existing
rustix and tempfile Windows dependency edges to windows-sys 0.61.2.
Builds fetch with `--locked`, compile offline, and verify the lock remains
unchanged. No PG19 feature or extension SQL is added by the patch.

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
