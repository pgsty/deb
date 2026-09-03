# PGSTY Deb Package Builder

Extension build scripts for PostgreSQL 13-18 on Debian 12/13 and Ubuntu 22.04/24.04/26.04.

- [Pigsty PGSQL Repo](https://pgext.cloud/repo/pgsql)
- [DEB Change Log](https://pgext.cloud/release/deb)


## Use with pig

You can build extension DEBs with [pig](https://pgext.cloud/pig).

```bash
curl https://repo.pigsty.cc/pig | bash -s 0.9.1
pig build repo
pig build tool
pig build spec # <--- get this repo, setup building environment
pig build rust
pig build pgrx

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


## Signature

All Deb Packages are signed with GPG key `9592A7BC7A682E7333376E09E7935D8DB9BD8B20` (`B9BD8B20` [Public key](KEYS))


## License

Maintainer: Ruohang Feng / [@Vonng](https://vonng.com/en/) ([rh@vonng.com](mailto:rh@vonng.com))

License: [Apache-2.0](LICENSE)
