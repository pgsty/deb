# pg_search 0.27.1

Build PostgreSQL 15–18 from the official `pg_search-0.27.1.tar.gz`.
The upstream Cargo.lock pins pgrx 0.20.1. Its SHA-256 is `da9858216005c7c04e6d129de209ea08c386f407f537ade6b735de37256f9937`.
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
