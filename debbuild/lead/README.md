# Lead packaging

Lead is PlanetScale's deliberately non-production TIN-compatible text search
implementation for development, tests, CI, and staging. Index scans return all
heap pages and PostgreSQL rechecks visible rows. Packaging QA does not make it
suitable for production workloads.

- Upstream: <https://github.com/planetscale/lead>
- The recipe uses upstream commit `e3ed2f4ce1388167b0254a0c0c706a61d0a37d83`
  from 2026-10-08, verified on 2026-11-23.
- Source: `lead-1.0.6.tar.gz`, unchanged official commit archive.
- SHA-256: `a97600878484d20e578a19370442d4ecf0b2f9e41b97f8ebbd99c3b556edb405`.
- The package revision is `1.0.6-2PGSTY` and the SQL version is `1.0.6`.
- PostgreSQL 17–19 use SQL extension `tin` from `postgresql-<major>-lead`.
- The license is AGPL-3.0-or-later. Build with Rust 1.100.0 and cargo-pgrx 0.20.1.

Run `pig build get lead` in the builder first. If it cannot obtain the source,
copy only the named tarball into `~/ext/src` and link `../SOURCES` there. Install
the toolchain with `rustup toolchain install 1.100.0 --component rustfmt`
and `cargo +1.100.0 install cargo-pgrx --version 0.20.1 --locked`, then run
`make`. The recipe fetches the patched Cargo.lock with `--locked`, verifies
its checksum after building and emits dbgsym packages. On PG19 the planner
patch binds search arrays through `build_simple_rel_hook`.

`CREATE EXTENSION tin` loads it on demand; no preload setting or external
service is needed. Test tin and stannum in different databases: both define
the global `==>` operator. This recipe does not add upstream SQL migrations.
Rust/pgrx does not generate PGXS bitcode or a separate llvmjit package.
