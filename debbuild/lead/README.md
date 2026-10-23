# Lead packaging

Lead is PlanetScale's deliberately non-production TIN-compatible text search
implementation for development, tests, CI, and staging. Index scans return all
heap pages and PostgreSQL rechecks visible rows. Packaging QA does not make it
suitable for production workloads.

- Upstream: <https://github.com/planetscale/lead>
- Commit: `e3ed2f4ce1388167b0254a0c0c706a61d0a37d83` (2026-10-08).
- Source: `lead-1.0.6.tar.gz`, unchanged official commit archive.
- SHA-256: `a97600878484d20e578a19370442d4ecf0b2f9e41b97f8ebbd99c3b556edb405`.
- No upstream tags/releases existed when checked on 2026-10-23.
- Package version: `1.0.6-1PGSTY`; SQL version: `1.0.6`.
- PostgreSQL: 17 and 18; SQL extension/library: `tin`; binary package:
  `postgresql-<major>-lead`.
- License: AGPL-3.0-or-later. Requires Rust 1.96.0 and cargo-pgrx 0.19.1.

Run `pig build get lead` in the builder first. If it cannot obtain the source,
copy only the named tarball into `~/ext/src` and link `../SOURCES` there. Install
the pinned toolchain (`rustup toolchain install 1.96.0 --component rustfmt`) and
`cargo install cargo-pgrx --version 0.19.1 --locked`, then run
`make PG_VERSIONS="17 18"`. The recipe preserves the upstream Cargo.lock,
including its pinned unicode-segmentation Git dependency, and emits dbgsym
packages from an optimized build with full DWARF.

`CREATE EXTENSION tin` loads it on demand; no preload setting or external
service is needed. Test tin and stannum in different databases: both define
the global `==>` operator. This recipe does not add upstream SQL migrations.
Rust/pgrx does not generate PGXS bitcode or a separate llvmjit package.
