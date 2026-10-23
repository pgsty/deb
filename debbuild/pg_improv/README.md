# pg_improv packaging

This recipe and the RPM spec use the upstream **0.10.0** archive with an identical
packaging patch for pgrx **0.19.3**. The patch updates the extension dependency
lockfile and removes the obsolete pgrx embed binary; the original archive is
unchanged.

- Upstream: <https://codeberg.org/gregburd/improv>
- Release mirror: <https://github.com/gburd/improv/releases/tag/v0.10.0>
- Source: <https://github.com/gburd/improv/archive/refs/tags/v0.10.0.tar.gz>
- Archive: `improv-0.10.0.tar.gz`, root `improv-0.10.0/`
- SHA-256: `4d27747a90a358750ddd05811687618c1de97e1c73743d97c92d98aed38ad626`
- License: Apache-2.0 OR MIT
- PostgreSQL feature range: 15–18
- Required toolchain: Rust 1.97 or newer, cargo-pgrx **0.19.3**, libclang

The extension is a standalone Cargo workspace in `crates/pg_improv/`, with
its own lockfile and sibling path dependencies. Building the root workspace
does not build the PostgreSQL extension. Both packaging implementations fetch
with `--locked`, build offline afterwards, and verify that the extension's
lockfile remains unchanged. Rust is provided by rustup in the builder; the
Debian recipe checks the dpkg-managed Build-Depends normally. Release DWARF
is retained for RPM debuginfo/debugsource and Debian's automatic dbgsym split.
Upstream does not emit PGXS bitcode for this Rust extension.

Run `pig build get pg_improv` first. Until the catalogue and source mirror
are updated, copy only `improv-0.10.0.tar.gz` into the builder's source
directory (`~/rpmbuild/SOURCES/` on RPM; `~/ext/src/` linked by
`~/debbuild/SOURCES` on DEB). Prepare the matching toolchain:

```sh
pig build pgrx -v 0.19.3 --pg 17
# RPM
cd ~/rpmbuild
./dep pg_improv 17
./build pg_improv 17
# DEB
cd ~/debbuild/pg_improv
make PG_VERSIONS=17
```

`make` defaults to PG15–18 on DEB; the RPM shortcut selects the same range.
The package installs the generated base SQL and all three migration scripts
shipped by upstream. No migration or product behavior is added by packaging.

The package does not change PostgreSQL configuration. Manual and trigger
models work without preload. Logical synchronization requires:

```ini
shared_preload_libraries = 'pg_improv'
wal_level = logical
improv.database = 'your_database'
```

The worker's replication slots can retain WAL; configure and monitor the WAL
retention limit for the workload. Model numeric values are `double precision`,
including inputs from `numeric` and `bigint`; this is not exact-decimal
accounting arithmetic. `what_if` evaluates changes without storing them.

For installed-package verification, run upstream `crates/pg_improv/tests/txn.sh`
and `tests/finance.sh` as a non-root PostgreSQL user, setting `PG_BIN` to the
installed PostgreSQL bin directory. They create disposable clusters and cover
transaction rollback, commit/logical modes, dump/restore, and real financial
models with what-if scenarios. The GUI/CLI and DuckDB extension are separate
products and are not installed by these packages.

## Trial validation, 2026-10-23

PostgreSQL 17.11 builds and installation passed on `pgsty/el9a:build`
(Rocky Linux 9.8, aarch64) and `pgsty/u24a:build` (Ubuntu 24.04.5 noble,
arm64), using Rust 1.99.0 and cargo-pgrx 0.19.3. RPM produced the main,
debuginfo and debugsource packages; DEB produced the main and dbgsym packages.
DWARF, source payload, all four upstream SQL files, dependency metadata and
private documentation paths were checked. The patched lockfile was unchanged.

Both installed packages passed upstream `txn.sh` and `finance.sh`, including
logical synchronization, transaction/savepoint rollback, commit/prepare modes,
dump/restore followed by resumed synchronization, and financial what-if models.
On EL9, the temporary finance cluster disables `logging_collector`: the RPM
default otherwise conflicts with the upstream script's `log` output file.
This is a test-harness setting, not a package or product modification.

An additional fixture confirmed that `bigint` and `numeric` values of
`2^53+1` become `2^53` inside the model while source columns remain exact;
`0.1 + 0.2` exhibits binary floating arithmetic. `what_if` ran in a READ ONLY
transaction without changing source, catalog or result tables. Manual recalc
updated one changed result and was idempotent thereafter.

PG15, PG16 and PG18 passed `cargo check` with the same patched pgrx 0.19.3
source. Their binary packages and runtime paths were not tested in this pilot.
Builds and tests do not establish production maturity or publication.
