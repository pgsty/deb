# polardb debbuild

This recipe rebuilds PolarDB for PostgreSQL from the `v17.11.1.0` source
tarball using the official Debian package workflow, with Pigsty-specific
package naming and filesystem layout.

Upstream CI builds Debian packages by mounting the source tree into a
`polardb/polardb_pg_devel:<base_image>` container and running:

```bash
cd package/debian
./build-deb.sh
```

The local recipe keeps that build flow intact. Because Pigsty recipes use
source tarballs instead of git checkouts, the Makefile injects the upstream tag
commit `ff510dfc` so the PolarDB version string does not fall back to
`build unknown`.

Pigsty packages this kernel as a versioned PostgreSQL-compatible kernel:

```text
Package: polardb-17
Prefix:  /usr/polar-17
```

The output `.deb` file follows the Pigsty Debian repository naming style. The
release defaults to `2PGSTY`, and the build script appends the detected distro
codename:

```text
polardb-17_17.11.1.0-2PGSTY~bookworm_<arch>.deb
polardb-17-dbgsym_17.11.1.0-2PGSTY~bookworm_<arch>.ddeb
```

The upstream workflow calls `dpkg-deb` directly and therefore does not run
debhelper's automatic symbol split. After the upstream package tree is built,
`split-dbgsym.sh` detaches DWARF into standard build-id paths, strips the main
ELFs, rebuilds the main package, and creates the matching `-dbgsym` `.ddeb`.
The recipe exports Debian build flags to the upstream build, preserving
optimization, hardening, and DWARF while keeping upstream `--debug=off`.

The RUNPATH contains both `$ORIGIN/../lib` and the fixed installed library
path `/usr/polar-17/lib`. The latter lets deeply nested PGXS executables,
including `pg_regress`, resolve bundled libpq without falling back to a system
PostgreSQL library. The temporary package staging directory is not embedded.

The source commit remains available as the `X-Pigsty-Source-Commit` binary
control field instead of occupying the Debian revision. `DEB_RELEASE` can be
overridden when intentionally incrementing the Pigsty package release, while
`DISTRO_CODENAME` is available as an explicit builder override.

The initial `17.10.1.0-accf02e2` package revision sorts newer than
`17.10.1.0-1PGSTY~<codename>` under Debian version ordering. Remove the legacy
repository entries before publishing the corrected package; the repository
must not expose both revisions at the same time.

The default build validates `DEB_RELEASE`, distro codename, and architecture
before setup. After packaging, `make verify` checks the exact filename and the
binary control fields for package name, version, architecture, and upstream
source commit. It also requires a non-empty build-id debug payload before
`make move` collects both artifacts.

The upstream release packages use `/u01/polardb_pg_17` and
`polardb-for-postgresql`. Pigsty intentionally does not preserve that layout.
Package payload files are archived as `root:root`; runtime data directories are
not created by this package.

The upstream helper script chooses a random port for demo-cluster startup and
passes it to `configure --with-pgport`. Pigsty patches that value to the
PostgreSQL default `5432` so client and server tools behave predictably when no
runtime port is specified. The default Unix-domain socket directory remains the
upstream PostgreSQL default `/tmp`; Pigsty may still override both settings at
runtime.

On Ubuntu 26, LLVM/Clang are versioned commands (`llvm-config-21`,
`clang-21`). The Makefile exports the detected versioned paths to upstream
`build.sh`, and runs `build-deb.sh` with `bash -e` so configure or compile
failures do not leave behind empty packages.

The source tarball is prepared like an upstream checkout after
`maintainer-clean`, so generated PostgreSQL headers such as
`src/include/utils/errcodes.h` are absent. The recipe injects the same
`src/backend submake-generated-headers` step used by the other kernel recipes
before `install-world-bin`.

Upstream builds with `--with-pfsd`. The PFSD SDK is provided by the Pigsty
`polarstore` dependency package under the upstream SDK path:

```text
/usr/local/polarstore/pfsd
```

Revision `2PGSTY` rebuilds the unchanged PolarDB source against zlog 1.2.20
and PolarStore SDK `1.2.42-3PGSTY`. The default SDK gate requires that exact
PolarStore revision for the builder's suite. Production orchestration must also
verify the package, header and static archive hashes for its architecture.

Build and install the current Pigsty zlog and PolarStore packages before
building PolarDB. The production matrix deliberately uses the newly built zlog
artifact on every target, including Trixie and Resolute:

```bash
apt-get install -y libaio-dev
pig build pkg zlog
zlog_deb=$(make -s --no-print-directory -C ../zlog print-package-name)
apt-get install -y "$HOME/ext/pkg/$zlog_deb"
pig build pkg polarstore
polarstore_deb=$(make -s --no-print-directory -C ../polarstore print-package-name)
apt-get install -y "$HOME/ext/pkg/$polarstore_deb"
```

Before continuing, verify that the installed zlog and PolarStore versions are
the exact artifacts produced for the current suite and architecture. The
package metadata uses ordinary upstream minimum versions; exact
`3PGSTY~<codename>` PolarStore SDK provenance is a build-pipeline gate, not a dependency
constraint.

The official full-feature build also needs the normal PostgreSQL kernel build
dependencies. On a plain Debian/Ubuntu builder, make sure these packages are
present before running the recipe:

```bash
apt-get install -y \
  bison flex uuid-dev libreadline-dev zlib1g-dev libssl-dev \
  libxml2-dev libxslt1-dev libicu-dev libpam0g-dev libkrb5-dev \
  libldap2-dev libperl-dev python3-dev tcl-dev liblz4-dev \
  libzstd-dev libunwind-dev gettext pkg-config clang llvm-dev
```

Some Pigsty builders provide only versioned LLVM packages and commands, such as
`clang-19`/`llvm-config-19` on U24 or `clang-21`/`llvm-config-21` on U26. The
Debian build dependencies accept those versioned packages, and the Makefile
detects the matching commands before falling back to unversioned names.

The upstream `v17.11.1.0` Debian control already covers ICU 66 through ICU 78,
so no suite-specific ICU dependency rewrite is required.

Required local tarball:

```text
~/pgsty/repo/ext/src/polardb-for-postgresql-17.11.1.0.tar.gz
```

## 2026-11-03 production rebuild

All ten Debian/Ubuntu coordinates (Bookworm, Trixie, Jammy, Noble and Resolute,
each on amd64 and arm64) passed native full-bundle builds and installation/runtime
QA for `17.11.1.0-2PGSTY`. The official source remains
`deeed25e271bb6507c6a190a6b72539718ec1f95893bc79132f8ebe2ee44ed17`.
The packaging patch, shared byte-for-byte with RPM, is
`fc65bf1fe6750631c5e4c0f5b1fff0e9a2b4575bcd76b9969b2549d1a65abe42`.

The build order was zlog 1.2.20 → PolarStore SDK 1.2.42-3PGSTY → PolarDB
17.11.1.0-2PGSTY. Each builder installed its exact platform packages from batch
03. Package, SDK header and `libpfsd.a` hashes were verified before and after
compilation. Linker traces name the absolute SDK archive, and the detached
PolarDB debug files contain the embedded PFSD symbols. Existing upstream
versions were retained for the dependency rebuilds; package revisions follow
the verified published APT history.

Builders were `pgsty/{d12,d13,u22,u24,u26}:build` on native amd64 m3, and the
corresponding `a` ARM64 images on m1/m5. Every package preserves all staged
files, 93 controls, 404 SQL files, 117 top-level modules and 1144 bitcode files
including 84 indexes. Each `.ddeb` contains 163 matching debug ELFs with DWARF.
All installed dynamic links resolve. Every executable or library using libpq,
including nested PGXS tools, resolves the bundled library after the RUNPATH fix.
The main package retains upstream-bundled system libraries; their distributor's
already stripped files are distinguished from the locally compiled kernel ELFs.

All ten runtime checks used the upstream localfs initialization path, four
required preloads, pg_trgm/hstore/pgcrypto/pg_hint_plan/roaringbitmap/pg_repack/
pg_partman/pg_jieba/pgtap, and PL/Python/Perl/Tcl. Version and commit, transaction
rollback, restart persistence and forced LLVM JIT with inlining/optimization
passed. This validates localfs packaging, not a distributed PFSD deployment.
`polar_resource_manager` and `polar_io_stat` ship no upstream installation SQL;
those files were not invented. The release build disables the upstream
fault-injector development feature.

Twenty main/debug artifacts were SHA-256 verified and collected in local
`apt/<codename>/`. Test databases and containers were stopped. Evidence lives
under `/Users/vonng/.cache/pgsty-build/20261103-extension-production-003724/deb/`:
`09b-evidence.json`, source/recipe manifests, `09b-polardb-matrix.json`,
`09b-polardb-artifacts.json`, and per-platform SDK, installed dependency, QA and
build-log records. No production stash/import/publication, database write or
Git commit was performed. The independent kernel has no `pgext.extension` row.
