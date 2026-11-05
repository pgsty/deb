# pg_search 0.26.5

Build PostgreSQL 15, 16, 17 and 18 from the official `paradedb-0.26.5`
source tree in `pg_search-0.26.5.tar.gz`. The upstream Cargo.lock remains
unchanged; its SHA-256 is
`6560f9f566e8b573155a3fa77ed215080efde1e5feaff0e553cb60b5ac2a6704`.
No compatibility patch is applied.

Lindera 6.2.0 dictionary archives are fetched with curl and checked against
pinned SHA-256 digests before the offline Cargo build. Set
`LINDERA_BUILD_DICTIONARY_CACHE_DIR` to an absolute directory to reuse these
assets; the default is `$HOME/.cache/pg_search/lindera`. Lindera stores format 2
dictionaries in its `6.2.0-fmt2` subdirectory and validates cached metadata.
`CARGO_TARGET_DIR` may point to a persistent builder directory to reuse compiled
dependencies across PostgreSQL majors; package installation uses that same path.

The builder supplies Rust 1.99.0 through Rustup and cargo-pgrx 0.19.3.
The recipe checks both versions explicitly rather than depending on the
unrelated distribution cargo package. Clang (including the versioned
clang-15, clang-19 and clang-21 packages), OpenBLAS, OpenSSL, ICU and other
dpkg-managed dependencies are checked before compilation and again during normal dpkg-buildpackage.
`CARGO_BUILD_JOBS` defaults to 1: optimized builds retain full DWARF
and thin LTO. Release debug is 2 and stripping is deferred to dh_strip.

The license collector matches the versioned canonical source helper
`pg_search_collect_third_party_licenses-0.26.5.py` (SHA-256
`aefedf5180807a201990ba42d9e9d585b9dd144ea4e558da941f884ff20c8a03`).
It validates the resolved Git source closure and packages dependency notices
under each binary package's private documentation directory. Historical
patch files are retained but are not applied to this release.

Install the matching pgvector package, add `pg_search` to
`shared_preload_libraries`, and restart PostgreSQL before creating the
extension. Packaging preserves upstream SQL files; it does not synthesize
missing upgrade scripts.

The source contains 138 upstream upgrade SQL files. Validation of an older
release does not establish acceptance of this version; run a representative
package, payload and runtime check before production builds.
