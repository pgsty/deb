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
release defaults to `1PGSTY`, and the build script appends the detected distro
codename:

```text
polardb-17_17.11.1.0-1PGSTY~bookworm_<arch>.deb
```

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
source commit before `make move` collects the artifact.

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
`1PGSTY~<codename>` provenance is a build-pipeline gate, not a dependency
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
