# polardb debbuild

This recipe rebuilds PolarDB for PostgreSQL from the `v17.10.1.0` source
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
commit `accf02e2` so the PolarDB version string does not fall back to
`build unknown`.

Pigsty packages this kernel as a versioned PostgreSQL-compatible kernel:

```text
Package: polardb-17
Prefix:  /usr/polar-17
```

The output `.deb` file follows the Debian repository naming style:

```text
polardb-17_17.10.1.0-accf02e2_<arch>.deb
```

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

Build and install `polarstore` before building `polardb` when the package
is not already available from the active APT repository:

```bash
pig build pkg polarstore
dpkg -i ~/ext/pkg/polarstore_*.deb
```

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

Some Pigsty U26 builders provide versioned LLVM commands such as `clang-21` and
`llvm-config-21`; the Makefile detects those before falling back to unversioned
`clang` and `llvm-config`.

Ubuntu 26 ships ICU 78, while the upstream `v17.10.1.0` Debian control file
only lists ICU through `libicu76`. The recipe patches the runtime dependency
alternative to include `libicu78`.

Required local tarball:

```text
~/pgsty/repo/ext/src/polardb-for-postgresql-17.10.1.0.tar.gz
```
