# pg_search 0.27.0

Build PostgreSQL 15–18 from the official `pg_search-0.27.0.tar.gz`.
The shared `pg-search-0.27.0-pgrx-0.20.1.patch` updates the pgrx dependencies.
The resulting Cargo.lock has SHA-256
`364afaf942a5d14e29ade1d514622a0d0623ceb275fcd3d4877e3ab15dc9d2d0`.
PG19 requires upstream changes to page items, buffer access and WAL handling.

Lindera 6.2.0 dictionary archives are fetched with curl and checked against
pinned SHA-256 digests before the offline Cargo build. Set
`LINDERA_BUILD_DICTIONARY_CACHE_DIR` to an absolute directory to reuse these
assets; the default is `$HOME/.cache/pg_search/lindera`. Lindera stores format 2
dictionaries in its `6.2.0-fmt2` subdirectory and validates cached metadata.
`CARGO_TARGET_DIR` may point to a persistent builder directory to reuse compiled
dependencies across PostgreSQL majors; package installation uses that same path.

The builder supplies Rust 1.100.0 through Rustup and cargo-pgrx 0.20.1.
The recipe checks both versions explicitly rather than depending on the
unrelated distribution cargo package. Clang (including the versioned
clang-15, clang-19 and clang-21 packages), OpenBLAS, OpenSSL, ICU and other
dpkg-managed dependencies are checked before compilation and again during normal dpkg-buildpackage.
`CARGO_BUILD_JOBS` defaults to 1: optimized builds retain full DWARF
and thin LTO. Release debug is 2 and stripping is deferred to dh_strip.

Install the matching pgvector package, add `pg_search` to
`shared_preload_libraries`, and restart PostgreSQL before creating the
extension. Packaging preserves upstream SQL files; it does not synthesize
missing upgrade scripts.

The 0.26.6 source contains 139 upstream upgrade SQL files. On 2026-11-09, PostgreSQL
15 and 18 passed package and runtime validation in `pgsty/u24a:build`
(Ubuntu 24.04.5, arm64), with Rust 1.99.1 and cargo-pgrx 0.19.3. Both main
packages and dbgsym packages were checked for matching build IDs and DWARF;
all 139 upgrade SQL files matched the upstream source. Installation, preload,
`CREATE EXTENSION`, BM25 index creation and text search passed on both majors.
The final recipe packages the upstream license without a custom dependency
license collector. The full production platform matrix has not been run.
