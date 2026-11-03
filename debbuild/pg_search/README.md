# pg_search 0.26.4

Build PostgreSQL 15, 16, 17 and 18 from the official `paradedb-0.26.4`
source tree in `pg_search-0.26.4.tar.gz`. The upstream Cargo.lock remains
unchanged; its SHA-256 is
`c4d06147df89000fcb2b2cfee8942f6b539ec2fdeec259592aa5f37f07a50c04`.
No compatibility patch is applied.

The builder supplies Rust 1.99.0 through Rustup and cargo-pgrx 0.19.3.
The recipe checks both versions explicitly rather than depending on the
unrelated distribution cargo package. Clang (including the versioned
clang-15, clang-19 and clang-21 packages), OpenBLAS, OpenSSL, ICU and other
dpkg-managed dependencies are checked before compilation and again during normal dpkg-buildpackage.
`CARGO_BUILD_JOBS` defaults to 1: optimized builds retain full DWARF
and thin LTO. Release debug is 2 and stripping is deferred to dh_strip.

The license collector matches the versioned canonical source helper
`pg_search_collect_third_party_licenses-0.26.4.py` (SHA-256
`aefedf5180807a201990ba42d9e9d585b9dd144ea4e558da941f884ff20c8a03`).
It validates the resolved Git source closure and packages dependency notices
under each binary package's private documentation directory. Historical
patch files are retained but are not applied to this release.

Install the matching pgvector package, add `pg_search` to
`shared_preload_libraries`, and restart PostgreSQL before creating the
extension. Packaging preserves upstream SQL files; it does not synthesize
missing upgrade scripts.

Production validation on 2026-11-03 covered bookworm, trixie, jammy, noble
and resolute on native amd64 and arm64 builders, PostgreSQL 15 through 18:
40 main packages and 40 matching automatic dbgsym packages. Every package
preserved all 137 upstream upgrade SQL files and the resolved dependency
license notices. ELF architecture, dynamic dependencies, DWARF and matching
build IDs were checked. All 40 database runs passed preload, extension
creation, BM25 indexing, insert/update/delete, rollback, VACUUM, REINDEX,
index/heap result comparison and restart persistence checks.

Artifacts were collected into the local `apt/<codename>/` directories.
This validation did not import or publish an APT repository or update the
metadata database; `pgext.extension.deb_ver` and `mtime` remain pending.
