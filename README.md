# PGSTY Deb Package Builder

Extension build scripts for PostgreSQL 15–19 on Debian 12/13 and Ubuntu 22.04/24.04/26.04.

- [Pigsty PGSQL Repo](https://pgext.cloud/repo/pgsql)
- [DEB Change Log](https://pgext.cloud/release/deb)


## Current build scope

PG14 is retired from active orchestration. Each recipe selects its validated
subset of PostgreSQL 15–19; PG19 is not an unconditional compatibility claim.
The [Rust/pgrx 0.20.0 pilot](https://github.com/pgsty/rpm/blob/main/doc/rust-pgrx-0.20.0-pilot.md)
records upstream versions, Ubuntu 24.04/amd64 package checks, and extensions
awaiting upstream changes. Heavy components and custom PostgreSQL providers
have separate build records.

The [2026-11-21 audit](docs/nonrust-pg19-20261121.md) links the shared
upstream and PG19 support matrix. DEB validation uses Ubuntu 24.04/amd64 on m3,
with native debug packages retained. Build, payload, runtime and publication
states are recorded separately.

The [spec and patch review](docs/nonrust-spec-review-20261121.md) records
necessity, scope, validation limits and the per-extension commits.

## Use with pig

You can build extension DEBs with [pig](https://pgext.cloud/pig).

```bash
curl https://repo.pigsty.cc/pig | bash -s 0.9.1
pig build repo
pig build tool
pig build spec # <--- get this repo, setup building environment
pig build rust
export PATH="$HOME/.cargo/bin:$PATH"
rustup toolchain install 1.100.0
export RUSTUP_TOOLCHAIN=1.100.0
pig build pgrx -v 0.20.0

# then build packages
pig build pkg timescaledb
pig build pkg pg_search
```

## Debug packages

Native builds use debhelper's automatic `-dbgsym` packages by default, and
recipe collection keeps both `.deb` and `.ddeb` artifacts. Rust extensions
remain optimized release builds while setting Cargo's release debug level to
`2` and leaving stripping to `dh_strip`. Debian/Ubuntu has no separate RPM-like
`-debugsource` binary package; pure SQL/data/script `Architecture: all` packages
do not generate empty dbgsym packages. Native recipes that bypass debhelper must
split and validate an equivalent `-dbgsym` `.ddeb` explicitly; `polardb` uses
`split-dbgsym.sh` for that custom path. Recipes that invoke CMake, Meson,
Autoconf, or compilers outside the normal debhelper steps must export
`dpkg-buildflags` so the automatic split has real DWARF to package.

On Debian 12, Debian 13, Ubuntu 22.04 and Ubuntu 26.04, `dh_dwz` failed on
DWARF 5 sections during pgrx 0.20.0 builds. The first error named
`.debug_str_offsets` on amd64 and `.debug_addr` on arm64. Pass DWARF 4 flags
to both Rust and the Clang invocation used by pgrx. With the
source and build dependencies installed, this produces the main package and
its automatic `-dbgsym` package on amd64 and arm64.

```bash
RUSTFLAGS="${RUSTFLAGS:+$RUSTFLAGS }-C dwarf-version=4" \
BINDGEN_EXTRA_CLANG_ARGS="${BINDGEN_EXTRA_CLANG_ARGS:+$BINDGEN_EXTRA_CLANG_ARGS }-gdwarf-4" \
pgext mak pg_base58 --pg 15
```

## Signature

All Deb Packages are signed with GPG key `9592A7BC7A682E7333376E09E7935D8DB9BD8B20` (`B9BD8B20` [Public key](KEYS))


## License

Maintainer: Ruohang Feng / [@Vonng](https://vonng.com/en/) ([rh@vonng.com](mailto:rh@vonng.com))

License: [Apache-2.0](LICENSE)
