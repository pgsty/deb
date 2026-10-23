# pg_kv packaging

This recipe packages the upstream 0.1.0 release for PostgreSQL 15–18 with
cargo-pgrx 0.19.3. It uses the same unmodified source archive as the RPM spec.

- Upstream: <https://github.com/Murat7Ay/pg_kv/releases/tag/v0.1.0>
- Tag commit: `bf45bbfd6f29782701a4e6c9bf9c672a0c02bc8f`
- Source: <https://github.com/Murat7Ay/pg_kv/archive/refs/tags/v0.1.0.tar.gz>
- Archive: `pg_kv-0.1.0.tar.gz`
- SHA-256: `4df3d31e7a6290951a55629d92df70001c4d66751e5f6814b5b318f99314e47e`
- License: PostgreSQL

Run `pig build get pg_kv` first. Until catalogue/source publication is performed,
copy only this archive into the builder's `~/ext/src`, linked by
`~/debbuild/SOURCES`. Run `make` for all supported PostgreSQL versions, or
`make PG_VERSIONS=17` for a representative build.

The builder provides Rust through rustup and Clang through versioned packages.
The recipe checks cargo-pgrx, validates the dpkg-managed packaging prerequisites,
and uses `dpkg-buildpackage -d` because the unversioned cargo/clang package
aliases are absent. Cargo dependencies are fetched with `--locked`, packaging
runs offline, and Cargo.lock is checked afterwards. Rust release DWARF is
preserved for automatic `-dbgsym` packages. This pgrx extension does not install
PGXS bitcode or an extension LLVM subpackage.

`pg_kv` must be added to `shared_preload_libraries` before creating the
extension. Installing the package does not edit PostgreSQL configuration.
The upstream calls this an early release, not production ready. The cache is
shared by every database in one cluster, survives transaction rollback, and
is cleared on server restart. Grant access to schema `kv` deliberately.

Capacity eviction can discard a rate-limit bucket; the next request creates a
full bucket and obtains a fresh allowance. Key prefixes are not an access
control boundary. The package does not change these upstream semantics.

On 2026-10-23, PostgreSQL 15–18 builds and package payloads were verified
in `pgsty/el9a:build` (Rocky Linux 9.8, aarch64) and `pgsty/u24a:build`
(Ubuntu 24.04.5 noble, arm64). PostgreSQL 17.11 package installation and
runtime checks on both platforms passed the upstream `smoke.sql`,
`rate_limit.sql`, and `zset.sql`, plus checks for preload refusal, shared
cross-database keys, restart clearing, and rate-limit reset after capacity
eviction. RPM debuginfo/debugsource and DEB dbgsym were produced. These are
trial-build results, not a production release or a full concurrency audit.
