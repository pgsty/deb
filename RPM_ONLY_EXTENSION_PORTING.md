# RPM-only PostgreSQL extension Debian porting

Last updated: 2026-07-13 18:31 +0800

This is the durable progress and evidence log for porting the twelve requested
PGDG/PGRPM-only extension packages into this Debian packaging repository. Keep
research conclusions distinct from actual build and runtime verification.

## Status vocabulary

- **可做**: a DEB has been built and installed in the target environment, and
  `CREATE EXTENSION` plus a minimal smoke test succeeded.
- **有条件可做**: the packaging route is understood, but a legal dependency,
  external service, SDK, architecture, or test environment is missing.
- **需要进一步调研**: evidence is not yet sufficient and further research has
  a material cost.
- **做不了**: a hard blocker exists, or three materially different, evidenced
  attempts have been exhausted.
- **进行中**: work has started but has not yet reached one of the final classes.

Verification levels are recorded separately as: research only, compile, DEB
build, install, `CREATE EXTENSION`, smoke test, and external integration test.

## Protected workspace baseline

- Initial repository state: `main...origin/main [ahead 4]`, with no uncommitted
  files. The four commits pre-date this task and must not be rewritten.
- `AGENTS.md -> CLAUDE.md` and `CLAUDE.md -> AGENTS.md` form a pre-existing
  symlink loop (`Too many levels of symbolic links`), so no repository-specific
  agent instructions could be read. The loop has not been changed.
- No publish, upload, push, pull request, or commit is authorized.

## U24A environment evidence

The configured `u24a` SSH alias is currently absent. `ssh -o BatchMode=yes
-o ConnectTimeout=12 u24a ...` failed with `Could not resolve hostname u24a`.
The current `tf/terraform.tfstate` has no resources or outputs. The backup state
contains the old address `47.100.180.100`, but a direct SSH probe timed out.
Therefore the original U24A host is objectively inaccessible in this round and
no result may be attributed to it.

A local Docker backend is available and reports `server_os=linux` and
`server_arch=arm64`. A disposable native `ubuntu:24.04` arm64 container will be
used as an explicitly labelled substitute for packaging validation. Its own
`lsb_release`, `uname`, `dpkg`, apt-source, and installed-PostgreSQL output must
be captured before results are accepted. It is not the original SSH host.

The Terraform configuration says the intended historical `pg-u24a` resource
used the Ubuntu 24.04 ARM image and ARM instance type, but this is configuration
evidence only, not a substitute for runtime architecture detection.

## Primary evidence baseline

- PGRPM Git: <https://git.postgresql.org/git/pgrpms.git>, observed HEAD
  `93c7ba35587ce2e629ee1523634ed1d6b4e492c6` on 2026-07-11.
- Main PG18 EL9 SRPM index:
  <https://download.postgresql.org/pub/repos/yum/srpms/18/redhat/rhel-9-x86_64/>
- Non-free PG18 EL9 SRPM index:
  <https://download.postgresql.org/pub/repos/yum/srpms/non-free/18/redhat/rhel-9-x86_64/>
- PG16 EL9 SRPM index (for `jdbc_fdw`):
  <https://download.postgresql.org/pub/repos/yum/srpms/16/redhat/rhel-9-x86_64/>

The current official SRPMs were downloaded and their embedded specs, sources,
and patches were extracted. This is the packaging reference; the Debian recipes
must still be designed for Debian/Ubuntu rather than mechanically converted.

## Research matrix

| Extension | Upstream / current source | PGRPM reference | Build and dependencies | PG14-18 / architecture | External system | Difficulty / current class | Next action |
|---|---|---|---|---|---|---|---|
| `pg_dbms_metadata` | [HexaCluster](https://github.com/HexaCluster/pg_dbms_metadata), `v1.0.0`, [archive](https://github.com/hexacluster/pg_dbms_metadata/archive/refs/tags/v1.0.0.tar.gz), PostgreSQL License | `pg_dbms_metadata_18-1.0.0-2PGDG.rhel9.8.src.rpm`; `pg_dbms_metadata.spec`; no patch; noarch | PGXS, pure SQL; only PostgreSQL devel/server | DEBs built and tested on PG14-18; architecture-independent package built on arm64 | none | **可做**; DEB build, install, `CREATE EXTENSION`, and smoke tests passed for PG14-18 | Keep recipe; process next high-feasibility extension |
| `pg_dbms_lock` | [HexaCluster](https://github.com/HexaCluster/pg_dbms_lock), `v2.0`, [archive](https://github.com/HexaCluster/pg_dbms_lock/archive/refs/tags/v2.0.tar.gz), PostgreSQL License | `pg_dbms_lock_18-2.0-1PGDG.rhel9.8.src.rpm`; PGRPM has no patch; Debian adds a pg_background v2 API fix | PGXS, pure SQL; runtime `postgresql-$v-pg-background (>=2.0)` | DEBs built, installed, and smoke-tested on PG14-18/arm64 | none | **可做**; full PG14-18 smoke passed after evidenced API patch | Keep recipe and patch; monitor whether upstream adopts equivalent fix |
| `pgbouncer_fdw` | [CrunchyData](https://github.com/CrunchyData/pgbouncer_fdw), `v1.4.0`, [archive](https://github.com/CrunchyData/pgbouncer_fdw/archive/v1.4.0.tar.gz), PostgreSQL License | `pgbouncer_fdw_18-1.4.0-1PGDG.rhel9.8.src.rpm`; no patch | PGXS, SQL; runtime `dblink`/contrib and PgBouncer >= 1.17 | DEBs built, installed, and load-smoke-tested on PG14-18/arm64 | PgBouncer admin console for full integration | **可做** at the allowed FDW load-test level; live admin-console integration is explicitly untested | Keep recipe; run external integration only when a configured PgBouncer test service is available |
| `faker` | PGRPM uses [Dalibo GitLab](https://gitlab.com/dalibo/postgresql_faker), `0.5.3`, [archive](https://gitlab.com/dalibo/postgresql_faker/-/archive/0.5.3/postgresql_faker-0.5.3.tar.bz2), PostgreSQL License | `postgresql_faker_18-0.5.3-9PGDG.rhel9.8.src.rpm`; PGRPM has no patch; Debian quotes the `json` SQL function name for PG17+ | PGXS C shim plus PL/Python; runtime PL/Python3 and Noble `python3-fake-factory` 22.0.0 | DEBs built, installed, and smoke-tested on PG14-18/arm64 | none | **可做**; full PG14-18 smoke passed with the parser-compatibility patch | Keep recipe and patch; monitor for an upstream release that quotes the identifier |
| `pg_dbms_errlog` | [HexaCluster](https://github.com/HexaCluster/pg_dbms_errlog), upstream `v2.4` (2026-06-23), [archive](https://github.com/HexaCluster/pg_dbms_errlog/archive/refs/tags/v2.4.tar.gz), ISC | `pg_dbms_errlog_18-2.2-1PGDG.rhel9.8.src.rpm`; no patch; Debian intentionally selects newer upstream 2.4 for PG18/worker fixes | PGXS C; runtime `pg_statement_rollback`; must be in `shared_preload_libraries` | 2.4 DEBs built, installed, and DML-error-smoke-tested on PG14-18/arm64 | none | **可做**; full PG14-18 shared-memory/worker smoke passed | Keep 2.4 recipe; ensure deployment documentation sets preload and restarts PostgreSQL |
| `odbc_fdw` | PGRPM uses [devrimgunduz fork](https://github.com/devrimgunduz/odbc_fdw), package release `0.6.1` / SQL extension version `0.5.2`, [archive](https://github.com/devrimgunduz/odbc_fdw/archive/refs/tags/0.6.1.tar.gz); source has PostgreSQL-licensed files and an Expat `LICENSE` | `odbc_fdw_18-0.6.1-1PGDG.rhel9.8.src.rpm`; no patch | PGXS C; `unixODBC-devel` maps to Noble `unixodbc-dev` 2.3.12; runtime resolved to `libodbc2` | DEBs built, installed, and handler-load-smoke-tested on PG14-18/arm64 | ODBC driver and remote DSN for full integration | **可做** at the allowed FDW load-test level; live DSN integration is explicitly untested | Keep recipe; run upstream integration suite only with supported configured drivers/DSNs |
| `pg_dbms_job` | [HexaCluster](https://github.com/HexaCluster/pg_dbms_job), `v2.0` package / `2.0.0` SQL version, [archive](https://github.com/HexaCluster/pg_dbms_job/archive/refs/tags/v2.0.tar.gz), PostgreSQL License | `pg_dbms_job_18-2.0-1PGDG.rhel9.8.src.rpm`; RPM-only patch changes `postgresql/libpq-fe.h` to `libpq-fe.h`, which must **not** be applied on Debian | PGXS C/background worker; `libpq-dev`; must be in `shared_preload_libraries` | DEBs built, installed, and async-worker-smoke-tested on PG14-18/arm64 | none | **可做**; full PG14-18 worker execution smoke passed | Keep unpatched include path; document preload, database/user, and authentication requirements |
| `dbt2` | [osdldbt](https://github.com/osdldbt/dbt2), kit `v0.61.7` / SQL extension `0.45.0`, [archive](https://github.com/osdldbt/dbt2/archive/refs/tags/v0.61.7.tar.gz); source and GitHub both say Artistic-2.0, correcting PGRPM's GPLv2+ field | `dbt2-pg18-extensions-0.61.7-5PGDG.rhel9.8.src.rpm`; CMake patch applies to full kit, not the standalone stored-function subbuild; Debian adds a `PG_CONFIG` patch | Standalone PGXS C extension has no external build dependency; full benchmark kit uses CMake/g++/libpq/OpenSSL/curl/expat and RPM `dbt2-common` | Extension DEBs built, installed, and C-function-smoke-tested on PG14-18/arm64 | full DBT-2 schema/data/driver for benchmark integration | **可做** for the extension; complete benchmark toolchain is **有条件可做** and separate | Keep extension recipe; create a distinct `dbt2-common`/driver port only if full benchmark execution is required |
| `hdfs_fdw` | [EnterpriseDB](https://github.com/EnterpriseDB/hdfs_fdw), release `v2.3.3` / SQL extension `2.0.5`, [archive](https://github.com/EnterpriseDB/hdfs_fdw/archive/v2.3.3.tar.gz), PostgreSQL License | `hdfs_fdw_18-2.3.3-3PGDG.rhel9.8.src.rpm`; no patch; Debian adds a private-library `$ORIGIN` runpath | PGXS C, source-built `libhive`, Java compiler/JAR, libxml2, JRE; all contents are open source | DEBs built, installed, and JVM/JNI/handler-load-smoke-tested on PG14-18/arm64 | Hadoop/Hive JDBC driver and service for query integration | **可做** at the allowed FDW load-test level; live Hive query is explicitly untested | Keep recipe; provide deployment GUC examples and run remote query suite only with a supported Hive service/driver |
| `jdbc_fdw` | [pgspider](https://github.com/pgspider/jdbc_fdw), current `v0.5.0`, [archive](https://github.com/pgspider/jdbc_fdw/archive/refs/tags/v0.5.0.tar.gz), PostgreSQL License | `jdbc_fdw_16-0.4.0-1PGDG.rhel9.src.rpm`; patch hard-codes an amd64 OpenJDK 8 JVM path; Debian uses portable default-Java and PG18 API patches | PGXS C + Java/JNI; official Noble default JDK/JRE; a JDBC driver JAR is needed only for remote queries | DEBs built, installed, and load-smoke-tested on PG14-18/arm64, including a bounded PG18 port beyond upstream's stated PG13-17 range | JVM, JDBC driver, remote JDBC database | **可做** at the allowed FDW load-test level; live JDBC query is explicitly untested | Keep recipe and PG18 compatibility patch; run remote query suite only with a supported driver and database |
| `db2_fdw` | PGRPM uses [Living-Mainframe](https://github.com/Living-Mainframe/db2_fdw), `18.1.2`, [archive](https://github.com/Living-Mainframe/db2_fdw/archive/refs/tags/18.1.2.tar.gz), PostgreSQL License | non-free `db2_fdw_18-18.1.2-1PGDG.rhel9.7.src.rpm`; spec sets `DB2_HOME=/opt/ibm/db2/V11.5/` and excludes automatic `libdb2.so.1` dependency | PGXS C/C++; requires proprietary IBM Db2 client `sqlcli1.h` and `libdb2.so`; no Ubuntu/PGDG dependency package | PGRPM PG14-18 binaries and IBM Db2 11.5 Linux client images have x86_64/POWER/zSeries precedents but no ARM64 client; U24A preflight fails at missing `sqlcli1.h` | IBM Db2 client and server | **做不了（当前 U24A）**; supported arm64 SDK is unavailable and acquired-client redistribution is not established | Resume only with an IBM-supported arm64 client or an authorized supported-architecture builder plus an approved dependency-distribution policy |
| `informix_fdw` | [credativ](https://github.com/credativ/informix_fdw), `REL0_6_3`, [archive](https://github.com/credativ/informix_fdw/archive/REL0_6_3.tar.gz), PostgreSQL License | non-free `informix_fdw_18-0.6.3-1PGDG.rhel9.src.rpm`; per-PG patch only hard-codes `pg_config`; linker config for `/opt/IBM/Informix`; spec admits missing BuildRequires | PGXS C but build invokes proprietary `/opt/IBM/Informix/bin/esql` and links private CSDK libraries; no apt package | PGRPM PG14-18 binaries are x86_64; IBM's current CSDK matrix lists Linux Intel/POWER/zSeries but no ARM64 and only Ubuntu through 22.04 | IBM Informix Client SDK and server | **做不了（当前 U24A）**; `esql`/CSDK is absent, current arm64/Noble support is unavailable, and downloads require entitlement | Resume only with an IBM-supported arm64/Noble CSDK or an authorized supported x86 builder plus redistribution approval |

## PGRPM spec details and Debian dependency mapping

| Extension | RPM BuildRequires / Requires | Debian/Ubuntu 24.04 direction | RPM-installed extension files |
|---|---|---|---|
| `pg_dbms_metadata` | PostgreSQL devel/server | `postgresql-all`, `${postgresql:Depends}` | control, versioned SQL, docs |
| `pg_dbms_lock` | PostgreSQL devel/server, `pg_background_$v` | `postgresql-all`, versioned `pg-background` dependency | control, versioned SQL, docs |
| `pgbouncer_fdw` | PostgreSQL devel/server/contrib, PgBouncer >=1.17 | `postgresql-all`, contrib/dblink dependency, `pgbouncer` | control, SQL, docs |
| `faker` | PostgreSQL devel/server/PLPython, Python Faker | `postgresql-all`, `postgresql-plpython3-PGVERSION`, Noble package `python3-fake-factory` | `faker.so`, control, SQL, docs |
| `pg_dbms_errlog` | PostgreSQL devel/server, `pg_statement_rollback_$v` | `postgresql-all`, versioned `pg-statement-rollback` | shared library, control, SQL, docs |
| `odbc_fdw` | PostgreSQL devel/server, unixODBC-devel | `postgresql-all`, `unixodbc-dev`, runtime unixODBC | shared library, control, SQL, docs |
| `pg_dbms_job` | PostgreSQL devel/server, make | `postgresql-all`, `libpq-dev`; runtime resolves to `libpq5` | shared library, control, SQL, docs |
| `dbt2` | gcc-c++, cmake, libpq-devel, OpenSSL, curl, expat; `dbt2-common` | `g++`, `cmake`, `libpq-dev`, `libssl-dev`, `libcurl4-openssl-dev`, `libexpat1-dev`; common split unresolved | `dbt2.so`, control, SQL and five workload SQL files |
| `hdfs_fdw` | PostgreSQL devel, libxml2-devel, java-devel, javapackages-tools; Java runtime | `postgresql-all`, `libxml2-dev`, a supported JDK/JRE | `hdfs_fdw.so`, `libhive.so`, JAR, control, SQL |
| `jdbc_fdw` | PostgreSQL devel/server, OpenJDK devel | `postgresql-all`, `libpq-dev`, `default-jdk-headless`; runtime `default-jre-headless`; `$ORIGIN` RUNPATH reaches a package-managed relative link to the default JVM | shared library, control, SQL, Java classes/docs per upstream Makefile |
| `db2_fdw` | PostgreSQL devel, libstdc++, PAM; undeclared Db2 SDK path | no legal/installable Noble arm64 package maps `sqlcli1.h` and `libdb2.so`; manual IBM client is a resume prerequisite | `db2_fdw.so`, control, SQL, docs |
| `informix_fdw` | PostgreSQL devel/server; undeclared Informix CSDK | no legal/installable Noble arm64 package maps `esql` and private CSDK libraries; manual entitled SDK is a resume prerequisite | shared library, control, SQL, linker config |

## Sample port: pg_dbms_metadata

Source provenance:

- Upstream archive:
  <https://github.com/hexacluster/pg_dbms_metadata/archive/refs/tags/v1.0.0.tar.gz>
- The identical archive embedded in the current PGRPM SRPM has SHA-256
  `d2ffa8e0bd723fccbb0cc6746e1cb871ab38166ff7e3dfc14e5c3809dc477631`.
- PGRPM SRPM:
  <https://download.postgresql.org/pub/repos/yum/srpms/18/redhat/rhel-9-x86_64/pg_dbms_metadata_18-1.0.0-2PGDG.rhel9.8.src.rpm>

Created recipe files:

- `debbuild/pg_dbms_metadata/Makefile`
- `debbuild/pg_dbms_metadata/debian/control.in`
- `debbuild/pg_dbms_metadata/debian/rules`
- `debbuild/pg_dbms_metadata/debian/pgversions`
- `debbuild/pg_dbms_metadata/debian/changelog`
- `debbuild/pg_dbms_metadata/debian/copyright`
- `debbuild/pg_dbms_metadata/debian/source/format`

Verification environment: disposable native arm64 container
`pgext-u24a-019f510b`, image `ubuntu:24.04` digest
`sha256:4fbb8e6a8395de5a7550b33509421a2bafbc0aab6c06ba2cef9ebffbc7092d90`.
Runtime facts were Ubuntu 24.04.4 LTS, `uname -m=aarch64`, and
`dpkg --print-architecture=arm64`. The official `noble-pgdg` apt source supplied
PostgreSQL 14.23, 15.18, 16.14, 17.10, and 18.4. This is a substitute U24 arm64
environment, not the inaccessible original SSH U24A host.

Verification state:

| PG | Compile / install files | DEB build | Install | `CREATE EXTENSION` | Smoke test | External integration |
|---|---|---|---|---|---|---|
| 14 | passed (pure SQL PGXS install) | passed | passed | passed, 1.0.0 | passed, `get_ddl(TABLE)` matched expected CREATE TABLE | not applicable |
| 15 | passed (pure SQL PGXS install) | passed | passed | passed, 1.0.0 | passed, `get_ddl(TABLE)` matched expected CREATE TABLE | not applicable |
| 16 | passed (pure SQL PGXS install) | passed | passed | passed, 1.0.0 | passed, `get_ddl(TABLE)` matched expected CREATE TABLE | not applicable |
| 17 | passed (pure SQL PGXS install) | passed | passed | passed, 1.0.0 | passed, `get_ddl(TABLE)` matched expected CREATE TABLE | not applicable |
| 18 | passed (pure SQL PGXS install) | passed | passed | passed, 1.0.0 | passed; returned table and primary-key DDL | not applicable |

`dpkg-buildpackage -b -us -uc` produced:

| Package | Version / architecture | SHA-256 |
|---|---|---|
| `postgresql-14-pg-dbms-metadata` | `1.0.0-1PIGSTY~noble`, `all` | `cd51b740d79e1e6f86f43bc4c83c36f0879bdc5f7ec781198ecae475fde56559` |
| `postgresql-15-pg-dbms-metadata` | `1.0.0-1PIGSTY~noble`, `all` | `40617de20029dc2c3588c14959b3e7ed4823e6b8ad021fab98f4d08559ece76e` |
| `postgresql-16-pg-dbms-metadata` | `1.0.0-1PIGSTY~noble`, `all` | `e1dd22dfbbc8cb823968b0b1a1b1f02384904c11f4b31818324e4f6037572569` |
| `postgresql-17-pg-dbms-metadata` | `1.0.0-1PIGSTY~noble`, `all` | `6cce9df86e202b5837b6db3422fda810df34f8682c42b0c1e2962047152e45d8` |
| `postgresql-18-pg-dbms-metadata` | `1.0.0-1PIGSTY~noble`, `all` | `fad16237834c67f459e8e7b1f56c9fe34fa23607fc39c1961e6d37c4216a544f` |

Each package depends on its matching `postgresql-$v` and contains exactly the
versioned SQL and control file under `/usr/share/postgresql/$v/extension/`, in
addition to documentation. The buildinfo host architecture is arm64.

The first build also exposed that upstream PGXS installs `README.md` into a
shared `postgresql-doc-$v/extension` path. The recipe now removes that generic
copy and retains the package-specific `dh_installdocs` copy. All hashes above
refer to the corrected packages, which were reinstalled successfully.

## Completed port: pg_dbms_lock

Created the same seven standard recipe files under `debbuild/pg_dbms_lock/`,
plus:

- `debian/patches/series`
- `debian/patches/pg-background-v2-api.patch`

All PG14-18 DEBs built on Noble/arm64 with version
`2.0-1PIGSTY~noble`, architecture `all`. They depend on their matching
`postgresql-$v` and `postgresql-$v-pg-background (>= 2.0)`. The test used the
existing Pigsty Noble/arm64 `pg_background 2.0` packages.

| PG | Build / install / create | Numeric request+release | Named allocation via pg_background v2 |
|---|---|---|---|
| 14 | passed | passed in one session | passed; allocation row verified |
| 15 | passed | passed in one session | passed; allocation row verified |
| 16 | passed | passed in one session | passed; allocation row verified |
| 17 | passed | passed in one session | passed; allocation row verified |
| 18 | passed | passed in one session | passed; allocation row verified |

Final DEB SHA-256 values: PG14
`a677111756309eef58f3b652a250061820bd872774affc0ec4d1f766738fd706`,
PG15 `efb14a615ea09e3f0e880fde033e4e1551f72a965f2e057f2789cc1a0db524c0`,
PG16 `dfecdc087171b902395265dbe19ef0d3be909c4824db1144e679005f39edd472`,
PG17 `1e9626fc4214ca00cf00f4a6a4531aa6d37a2528f3419085240811c3c5fe99bd`,
and PG18 `ef8350d2ce1798ff00caf22a8e11b47d126a780309a94df2abdc77e2da49e7ca`.

## Completed port: pgbouncer_fdw

Created the seven standard recipe files under `debbuild/pgbouncer_fdw/`.
The package is architecture-independent SQL and depends on the matching
PostgreSQL server plus `pgbouncer (>= 1.17)`. PGDG supplied PgBouncer 1.25.2 in
the substitute environment; its service was not started because the container
blocks automatic service starts.

| PG | DEB build | Install | `CREATE EXTENSION dblink` | `CREATE EXTENSION pgbouncer_fdw` | Load smoke | External integration |
|---|---|---|---|---|---|---|
| 14 | passed | passed | passed, 1.2 | passed, 1.4.0 | passed; target, views, and functions present | not run |
| 15 | passed | passed | passed, 1.2 | passed, 1.4.0 | passed; target, views, and functions present | not run |
| 16 | passed | passed | passed, 1.2 | passed, 1.4.0 | passed; target, views, and functions present | not run |
| 17 | passed | passed | passed, 1.2 | passed, 1.4.0 | passed; target, views, and functions present | not run |
| 18 | passed | passed | passed, 1.2 | passed, 1.4.0 | passed; target, views, and functions present | not run |

The minimal test verified the default `pgbouncer` target row is active and the
extension's monitoring views/functions exist. It deliberately did not claim a
successful `dblink` connection to a live PgBouncer admin console. This meets the
task's explicitly permitted FDW load-test boundary, but not the separate
external-integration level.

Final DEB SHA-256 values: PG14
`9b802036016cb1afd7f2e0074bc2e93b1e8084118a57131641ba41a800ab83bb`,
PG15 `5ed336f903ea1efe08df4823a0c5f77e6a7c9135d301e9f45e7df9710facda37`,
PG16 `373fe57184abbaa5cb25f8e4118822d263b1f35c88bc92177c934abab0e77f90`,
PG17 `f27812e53f44f0fc3991ef9ebae86bb845fcada1cedb319f45ec15e16b3aa726`,
and PG18 `cc3659b570c3df1909fe6bf7b79769b1e5c23564321b98ba3043484539c2698e`.

## Completed port: faker

Source provenance:

- Upstream/PGRPM archive:
  <https://gitlab.com/dalibo/postgresql_faker/-/archive/0.5.3/postgresql_faker-0.5.3.tar.bz2>
- Extracted current PGRPM source SHA-256:
  `f066dd7218f035745b590b81d6ea46a090a60e8a3801f78a52786077ce28eaad`
- PGRPM SRPM:
  <https://download.postgresql.org/pub/repos/yum/srpms/18/redhat/rhel-9-x86_64/postgresql_faker_18-0.5.3-9PGDG.rhel9.8.src.rpm>

Created the seven standard recipe files under `debbuild/faker/`, plus
`debian/patches/series` and `debian/patches/quote-json-function-name.patch`.
The packages are `Architecture: any`, depend on the matching PostgreSQL and
PL/Python packages, and use Ubuntu Noble's redistributable Universe package
`python3-fake-factory` 22.0.0-1. No pip-installed or opaque binary dependency
was used.

| PG | Compile | DEB build | Install | `CREATE EXTENSION` | Faker 22 smoke test |
|---|---|---|---|---|---|
| 14 | passed | passed | passed | passed, 0.5.3 | passed: init, seed, nonempty name, email shape |
| 15 | passed | passed | passed | passed, 0.5.3 | passed: init, seed, nonempty name, email shape |
| 16 | passed | passed | passed | passed, 0.5.3 | passed: init, seed, nonempty name, email shape |
| 17 | passed | passed | passed | passed after patch, 0.5.3 | passed: init, seed, nonempty name, email shape |
| 18 | passed | passed | passed | passed after patch, 0.5.3 | passed: init, seed, nonempty name, email shape |

Final DEB SHA-256 values: PG14
`061d04bcbe5f28b62e537cdf78e0e36efa9aa374a38e09e63eb6f85baa4282b0`,
PG15 `d58b47f46767a0ba884f29e8a816577d9197dd4e210ba1f94866616779954c0a`,
PG16 `d1ecf3eaed7e6b107708aaaf98fb4bd9c867d0aa002fe48bfb7abbbfc2e01651`,
PG17 `1c0e7163bfe02f846514d0f32f8d08302f22c00c0f6a87216a4c16ad022314d3`,
and PG18 `4b36f358d85f766b58020e3e2b005bfb1b147d6467f03c1ffa85b170ed53f255`.

## Completed port: pg_dbms_errlog

Upstream 2.4 was selected deliberately over PGRPM's 2.2. The upstream 2.3
changelog says it fixes PostgreSQL 18 compilation, and 2.4 fixes a
non-interruptible worker loop and a dynamic-worker crash. The v2.4 release was
published 2026-06-23; the tagged source archive SHA-256 is
`d3e324f7bd4824317895d8121ff9bae7e5e9c287eb61afb8141e48b336c3a188`.

Created the seven standard recipe files under `debbuild/pg_dbms_errlog/`.
Each binary package depends on its matching existing Pigsty
`postgresql-$v-pg-statement-rollback (>= 1.5)` package. The tested dependency
was version `1.5-2PIGSTY~noble`, already present for PG14-18 on arm64 in the
repository pool.

| PG | Compile / DEB / install | Preload / create | DML error smoke |
|---|---|---|---|
| 14 | passed | passed, 2.4 | passed; two valid rows committed, one `23505` logged |
| 15 | passed | passed, 2.4 | passed; two valid rows committed, one `23505` logged |
| 16 | passed | passed, 2.4 | passed; two valid rows committed, one `23505` logged |
| 17 | passed | passed, 2.4 | passed; two valid rows committed, one `23505` logged |
| 18 | passed | passed, 2.4 | passed; two valid rows committed, one `23505` logged |

For each cluster, `shared_preload_libraries=pg_dbms_errlog` was set and the
cluster was restarted. The test loaded `pg_statement_rollback`, registered an
error table, enabled synchronous query-level logging, triggered a duplicate-key
error inside a savepoint, rolled back to it, inserted another valid row, and
verified both base-table continuity and the logged SQLSTATE. This is a real
background-worker/shared-memory functional test, not merely an extension load.

Final DEB SHA-256 values: PG14
`125ad14fab9129827ddeb7e342c2f5e3397d9a0ba0264680c4c68aa8b26a414f`,
PG15 `eceb848b28ebd391e7e723df6cd5fb57a43e2c9fe037fe34190c917c62d74e8f`,
PG16 `ee9d798bea463b4f46dc22a4435398fe0be1bdbc12cc4146d36b457a948604e2`,
PG17 `a01d0e23d58155abebd2ad04b9f0a4ec8e158d1472cc0820b953c6a69dd51778`,
and PG18 `aeb298354b42b2083c901bb1eb7963afbd0258014251f88c659154972e580b53`.

## Completed port: odbc_fdw

The current PGRPM source archive SHA-256 is
`a3ec711bbcc46b81573ac877de93dfc02de593ec6fd9b7216a752917a82d9af4`.
Release 0.6.1 was published 2026-07-07 and describes security fixes, while its
control and install SQL deliberately retain extension version 0.5.2. Package
and SQL extension versions are therefore recorded separately rather than
silently rewritten. The source headers use the PostgreSQL License and the top
level `LICENSE` uses Expat terms; both are redistributable and both are captured
in Debian copyright metadata.

Created the seven standard recipe files under `debbuild/odbc_fdw/`.
Noble's official `unixodbc-dev` 2.3.12-1ubuntu0.24.04.1 supplied headers and the
link library. `dh_shlibdeps` generated runtime dependencies on `libodbc2` and
`libc6` rather than relying on a hand-written library dependency.

| PG | Compile / DEB / install | `CREATE EXTENSION` | Handler load / server validation | Remote DSN query |
|---|---|---|---|---|
| 14 | passed | passed, 0.5.2 | passed | not run |
| 15 | passed | passed, 0.5.2 | passed | not run |
| 16 | passed | passed, 0.5.2 | passed | not run |
| 17 | passed | passed, 0.5.2 | passed | not run |
| 18 | passed | passed, 0.5.2 | passed | not run |

The load smoke created a foreign server with a deliberately nonconnecting
placeholder driver name, and verified `odbc_fdw_handler` and
`odbc_fdw_validator` in the catalog. Creating the server invokes validation and
loads the shared library, but does not establish a remote connection. A real
driver/DSN/data-source integration result is not claimed.

Final DEB SHA-256 values: PG14
`27ed37af302abae124f24471ff6e40819b4e548ba9298c64c2d82c3a8137f559`,
PG15 `2369468b5f244fd4fdb6bcfb1395dd00e514c17f517584c4d000ec83b742ee4b`,
PG16 `8de2dff80ed43686e4a404d8a33ae79b37a3020114d9db87f3b9df2f178b1d32`,
PG17 `879a99203d6e359cbc2d57ffc5e4ea2b04eaeff99d48b7be79154de830bb4b1c`,
and PG18 `514b0722d2dddfaa863cb89b4c97d4b392d898f4d4c772b1d734fe6da1498cfa`.

## Completed port: pg_dbms_job

The former MigOps repository redirects to the active HexaCluster project. Its
v2.0 release was published 2026-04-18; the PGRPM source archive SHA-256 is
`db9285d2fb16c2fd9e33dddf273217e0bab53653e6cf40df8e8b1880579995c3`.
The package/release version is 2.0 and the SQL extension version is 2.0.0.

Created the seven standard recipe files under `debbuild/pg_dbms_job/`. Debian's
`libpq-dev` provides `/usr/include/postgresql/libpq-fe.h`, so the upstream
`#include "postgresql/libpq-fe.h"` is correct. The PGRPM patch to
`#include "libpq-fe.h"` is RPM-layout-specific and is intentionally not part of
the Debian recipe. Generated runtime dependencies correctly include `libpq5`
and `libc6`.

| PG | Compile / DEB / install | Preload / create | Background worker | Async execution smoke |
|---|---|---|---|---|
| 14 | passed | passed, 2.0.0 | running after schema creation | passed; insert, empty queue, success history |
| 15 | passed | passed, 2.0.0 | running after schema creation | passed; insert, empty queue, success history |
| 16 | passed | passed, 2.0.0 | running after schema creation | passed; insert, empty queue, success history |
| 17 | passed | passed, 2.0.0 | running after schema creation | passed; insert, empty queue, success history |
| 18 | passed | passed, 2.0.0 | running after schema creation | passed; insert, empty queue, success history |

For the runtime test, `pg_dbms_job` was added beside `pg_dbms_errlog` in
`shared_preload_libraries` and each disposable cluster restarted. Before the
extension schema exists, the worker predictably retries every five seconds with
a missing-relation log entry. After `CREATE EXTENSION`, one stable worker ran per
cluster. An immediate job inserted into a smoke table; all five clusters then
showed one row, an empty async queue, and one `Query returning no data success`
history entry. Test objects were dropped and the temporary preload was removed.

Final DEB SHA-256 values: PG14
`91abc12b17cd3f3dcfeecdb7b90d075bbcc34250bbcfaf0776a90d0293116b15`,
PG15 `a5141c3e8523c13b2d5768091c2e1ada08d13454636f7659e385ce923e476dc2`,
PG16 `7a1e6d2a8a91bfd165e685fb77a9a177e49cbeb059afeef516997190d5d6d962`,
PG17 `c52d3f5717dda6abfb03c14f9b64ec234b614a52247248e6fedcc1e057e3c8bf`,
and PG18 `f2cc02f5d1be125eb2a60fac00a296ee5faed7f70bdb32d2d9063b9228062ecb`.

## Completed port: dbt2 PostgreSQL extension

The current PGRPM source archive SHA-256 is
`8f5740a26453cd0051e797a6abd1af086e7e2a4ef598003a5af912a6bc5636bc`.
Upstream v0.61.7 was published 2025-07-01. Both the archive's `LICENSE` and
GitHub's detected SPDX metadata say Artistic-2.0; the PGRPM spec's GPLv2+ field
does not match the source and was not copied into Debian metadata.

Created the seven standard recipe files under `debbuild/dbt2/`, plus
`debian/patches/series` and `debian/patches/honor-pg-config.patch`. The recipe
stages only `storedproc/pgsql/c`, the independently buildable PostgreSQL
extension. It does not claim to replace PGRPM's separate `dbt2-common` package
or ship the complete benchmark driver/data-generation environment. The kit
version is 0.61.7; the upstream extension control version remains 0.45.0.

| PG | Correct per-version compile | DEB / install / create | C function smoke |
|---|---|---|---|
| 14 | passed against PG14 headers | passed, 0.45.0 | `stock_level()` returned expected 1 |
| 15 | passed against PG15 headers | passed, 0.45.0 | `stock_level()` returned expected 1 |
| 16 | passed against PG16 headers | passed, 0.45.0 | `stock_level()` returned expected 1 |
| 17 | passed against PG17 headers | passed, 0.45.0 | `stock_level()` returned expected 1 |
| 18 | passed against PG18 headers | passed, 0.45.0 | `stock_level()` returned expected 1 |

The smoke test created minimal `district`, `order_line`, and `stock` tables,
loaded one qualifying item, and invoked the actual C `stock_level(1,1,10)`
function. This validates shared-library loading and SPI execution, but is not a
TPC-C/DBT-2 performance or correctness run.

Final DEB SHA-256 values: PG14
`b3365447459a3155573c3d8ea923ede21ecacd2877f56be073f23b45143b5ae2`,
PG15 `2ab078a91a48c63fb5ec4db34b38e74a036b0e05fa0957897f4b460b733a947c`,
PG16 `639cb62d280880dea37ba488c9ac3efeadec8551ad2edf304f69539d9350b9c9`,
PG17 `ab772d17e53bcfaf7b4767cbf6aeb3e4f6a49755d35462c48c3ccb1d5a2638e7`,
and PG18 `d829bc5e6924b8166059e219db25fbe3ca22b2fca2ca27bc1edff4d7f2e29498`.

## Completed port: hdfs_fdw

The PGRPM source archive SHA-256 is
`c693492ab46a510c27ec05d565b1b0577b2904b606ba922b148201e762dcc754`.
The archive contains source for the C++ `libhive` JNI bridge and Java JDBC
adapter under the same PostgreSQL-style permissive license; no opaque or
precompiled library was used.

Created the seven standard recipe files under `debbuild/hdfs_fdw/`, plus
`debian/patches/series` and
`debian/patches/private-libhive-origin-rpath.patch`. Noble's official OpenJDK 21
compiled `HiveJdbcClient-1.0.jar`; `libhive.so` was built from the archive.
The JAR is installed under a versioned `/usr/share/java` directory and
`libhive.so` beside each versioned `hdfs_fdw.so`. A `$ORIGIN` RUNPATH is required
because Debian's loader does not otherwise search PostgreSQL's private module
directory for `DT_NEEDED libhive.so`; `readelf` and `ldd` confirmed the installed
PG18 module resolves the co-located bridge.

| PG | Compile / DEB / install | JVM/JNI load | Extension / handler smoke | Remote Hive query |
|---|---|---|---|---|
| 14 | passed | OpenJDK 21 passed | 2.0.5 / code 20303, server created | not run |
| 15 | passed | OpenJDK 21 passed | 2.0.5 / code 20303, server created | not run |
| 16 | passed | OpenJDK 21 passed | 2.0.5 / code 20303, server created | not run |
| 17 | passed | OpenJDK 21 passed | 2.0.5 / code 20303, server created | not run |
| 18 | passed | OpenJDK 21 passed | 2.0.5 / code 20303, server created | not run |

The load test set `hdfs_fdw.jvmpath` to Noble's architecture-neutral
`/usr/lib/jvm/default-java/lib/server`, set the classpath to the packaged bridge
JAR, created the extension, invoked the C `hdfs_fdw_version()` function, and
created a foreign server. That exercises private-library resolution, `dlopen`
of arm64 `libjvm.so`, JVM creation, Java class loading, C module loading, and
FDW validation. It does not include a Hadoop/Hive JDBC driver or remote service,
so no query-integration success is claimed.

Final DEB SHA-256 values: PG14
`6aa0252fea4cf404b2eca1c643548d43740dfcd5940c11b5cbe1cca6f0b93bb8`,
PG15 `f7284d91313b9ffb08330343fa4da94ee4ed876cd74f442d177d67c691dd1197`,
PG16 `32adee397cdb732469dce42bad806c3ff92de9e29c742aba51e51d079f16f29e`,
PG17 `b85305952b76313b2d1f3c34f94291538999681981e46a5b6d3c59446f113270`,
and PG18 `dac15ec39ed77e2df42d1b885266394b6833fedc52d2960505a33562fc1ed820`.

## Completed port: jdbc_fdw

Upstream `v0.5.0` was selected instead of PGRPM's older `v0.4.0`. The tagged
source archive SHA-256 is
`28c665d047ab81468839f628300ca5ca3980ebe9a8a30e4ff197ffe6fbeced20`.
The upstream README states PostgreSQL 13-17 support; PG18 was therefore treated
as a bounded compatibility assessment rather than assumed support.

Created the seven standard recipe files under `debbuild/jdbc_fdw/`, plus:

- `debian/patches/series`
- `debian/patches/portable-default-java.patch`
- `debian/patches/postgresql-18-compat.patch`

The first patch replaces PGRPM's amd64/OpenJDK-8-specific JVM path with a
`$ORIGIN` RUNPATH. The package creates a relative `libjvm.so` link from the
private PostgreSQL module directory to Debian's architecture-neutral
`/usr/lib/jvm/default-java/lib/server` alternative. The PG18 patch includes the
newly split EXPLAIN headers and supplies the new `disabled_nodes` foreign-path
argument. It passes zero, matching an enabled path and preserving pre-PG18
behavior.

| PG | Compile / DEB / install | JVM linkage | Extension / validator smoke | Remote JDBC query |
|---|---|---|---|---|
| 14 | passed | `libjvm.so` resolved via `$ORIGIN` and relative default-Java link | 1.2 / code 500, server created | not run |
| 15 | passed | `libjvm.so` resolved via `$ORIGIN` and relative default-Java link | 1.2 / code 500, server created | not run |
| 16 | passed | `libjvm.so` resolved via `$ORIGIN` and relative default-Java link | 1.2 / code 500, server created | not run |
| 17 | passed | `libjvm.so` resolved via `$ORIGIN` and relative default-Java link | 1.2 / code 500, server created | not run |
| 18 | passed after compatibility patch | `libjvm.so` resolved via `$ORIGIN` and relative default-Java link | 1.2 / code 500, server created | not run |

Every package declares its matching PostgreSQL server, `default-jre-headless`,
`libpq5`, and the generated libc dependency. `readelf` showed
`NEEDED libjvm.so` plus the intended RUNPATH, and `ldd` resolved the installed
arm64 JVM library on every version. The SQL test created the extension, called
`jdbc_fdw_version()`, created and inspected a foreign server with valid JDBC
options, then removed both objects. The dummy driver path was deliberately not
queried: no supported JDBC driver JAR or remote database was configured, so no
external-integration success is claimed.

Final DEB SHA-256 values: PG14
`2ec7c0a5908c6fe270cbc9ae48ee34580f7a6354cc5dc0a2ba433465b07e9c40`,
PG15 `48019675c2dae1b29b89165153eb259b076ebc5383e24fd4dfa08ece3f55f40a`,
PG16 `70618e05bc6d82eb16ce39ffc275776d5ba8abe53dc0408f3cadf1230a977402`,
PG17 `957552964d7c8ed7602161aefaf817d8e7a2baa3b20b2ed8a230dec765548fe9`,
and PG18 `595ac05dc16eefd4cd0ae3c8ec7581c28027d0cb9e9c5c5dec60daa2196f6922`.

## Stopped evaluation: db2_fdw

The open extension source is PostgreSQL-licensed and its PGRPM archive SHA-256
is `44e750ef1ab6501680c0e261a74e7a4b23e98c63e1f1d33e5ab4d991c92abe8b`.
The closed dependency is not optional: the Makefile includes
`$DB2_HOME/include`, links `$DB2_HOME/lib64 -ldb2`, and the source includes
`sqlcli1.h`. Upstream also requires PostgreSQL and the Db2 client to have the
same architecture.

Three materially different prerequisite paths were checked:

1. Noble/PGDG apt: no Db2 client development package or `libdb2` package is
   available; similarly named `db2fce` is unrelated PostgreSQL SQL emulation.
2. PGRPM: the non-free x86_64 repository contains PG14-18 extension binaries,
   but the spec explicitly excludes `libdb2.so.1` dependency generation and
   does not supply the client. The official aarch64 non-free path is absent.
3. IBM: current client downloads are delivered through Fix Central, while GA
   clients belong to purchased products in Passport Advantage. IBM's published
   11.5 Linux client/fix-pack platforms list x86-64, POWER little-endian, and
   zSeries, not ARM64; an IBM idea requesting ARM64 client support remains the
   clearest current confirmation of that gap.

The bounded PG18 preflight command was:

```sh
DB2_HOME=/opt/ibm/db2/V11.5 \
PG_CONFIG=/usr/lib/postgresql/18/bin/pg_config make USE_PGXS=1 -j2
```

It stopped with `fatal error: sqlcli1.h: No such file or directory`. No source
patch can legally or technically replace that API, and no untrusted client
binary was sought. Classification is **做不了（当前 U24A）**, not a compile or
DEB success. Resume requires an IBM-supported arm64 client, or a separate
supported-architecture build/test environment with entitled SDK installation,
redistribution approval, an installable dependency policy, and a Db2 server.

Primary IBM evidence:

- <https://www.ibm.com/support/pages/download-fix-packs-version-ibm-data-server-client-packages>
- <https://www.ibm.com/support/pages/db2-version-115-mod-6-fix-pack-0-linux-unix-and-windows>
- <https://ibm-data-and-ai.ideas.ibm.com/ideas/DB24LUW-I-2080>

## Stopped evaluation: informix_fdw

The open wrapper is PostgreSQL-licensed and the PGRPM archive SHA-256 is
`3f0dc82baf1e885302d2db4f287c0d18f955f84b4743b730ce9ab108b52c53d7`.
Its README requires a complete IBM ESQL/C Client SDK. The Makefile runs `esql`
as a source preprocessor and links private libraries under `$INFORMIXDIR`; the
PGRPM spec itself leaves the BuildRequires unresolved, filters the private
library dependencies, and adds `/opt/IBM/Informix` to the dynamic-loader path.

Three prerequisite paths were checked:

1. Noble/PGDG apt has no Informix CSDK, ESQL/C compiler, or matching private
   library package.
2. PGRPM supplies only x86_64 PG14-18 wrapper binaries; its source package does
   not contain the SDK and its spec comments `some-informix-dependency maybe?`.
3. IBM's current CSDK support matrix identifies Linux Intel as x86/x86_64,
   separately lists POWER and zSeries, and has no ARM64 section. Ubuntu 22.04 is
   the newest Ubuntu row, not Noble 24.04. IBM says Informix downloads require
   approved entitlement, an IBM identity, and an active support subscription.
   The old Informix 12.10 ARM64 server note targets Ubuntu 14.04 and is not
   evidence for a current arm64 Client SDK.

The bounded PG18 preflight command was:

```sh
INFORMIXDIR=/opt/IBM/Informix \
PG_CONFIG=/usr/lib/postgresql/18/bin/pg_config make USE_PGXS=1 -j2
```

It stopped at the required preprocessing step with
`make: esql: No such file or directory`. Replacing or bypassing ESQL/C would
disable the core driver and is prohibited. Classification is
**做不了（当前 U24A）**. Resume requires an IBM-supported arm64/Noble CSDK, or
an entitled supported x86 build/test environment, explicit redistribution and
dependency-packaging approval, and an Informix server with test credentials.

Primary IBM evidence:

- <https://www.ibm.com/support/pages/informix-client-software-development-kit-client-sdk-and-informix-connect-system-requirements>
- <https://www.ibm.com/support/pages/download-informix-products>
- <https://www.ibm.com/docs/en/informix-servers/12.10.0?topic=mn-linux-arm64>

## Attempt log

### Environment access

1. `ssh ... u24a`: failed before connection because the alias cannot be
   resolved. Root cause: current SSH include has no U24A host entry.
2. Read current Terraform state: state exists but contains no outputs/resources;
   it cannot recover a current address.
3. Probe the backup-state address `47.100.180.100`: TCP/22 timed out. Stop
   repeating this route unless Terraform state or SSH configuration changes.

### PGRPM evidence acquisition

1. A full shallow clone was too slow because the server does not support blob
   filtering. It was stopped rather than allowed to block the task.
2. Direct official SRPM indexes and SRPM extraction succeeded and supplied all
   twelve current specs plus sources/patches. This is the evidence path to reuse.

### pg_dbms_metadata build

1. The first `dpkg-buildpackage` stopped at `dpkg-checkbuilddeps` because the
   container had `postgresql-server-dev-all` but not the recipe's declared
   `postgresql-all (>= 217~)` meta-package. No dependency check was bypassed.
2. Installed the declared PGDG `postgresql-all` package and reran the same build.
   It succeeded and produced all five DEBs in one build.
3. Installed and smoke-tested PG18, then PG14-17 in independent clusters. All
   five versions passed; no patch or workaround was required.

### pg_dbms_lock build and finite attempts

1. Initial DEBs built, but installing beside `pg_dbms_metadata` found both
   packages owned the same PGXS-generated `postgresql-doc-$v/extension/README.md`.
   Applied the repository's established removal rule to both recipes and rebuilt;
   corrected packages install together.
2. `CREATE EXTENSION`, numeric request, and numeric release worked, but named
   allocation failed because upstream called removed
   `pg_background_launch(text)`. Inspection of the installed `pg_background 2.0`
   SQL proved its exported handle API is `pg_background_launch_v2` and
   `pg_background_result_v2`.
3. Added a focused quilt patch changing both the fresh-install and 1.0-to-2.0
   upgrade SQL to those evidenced v2 names. Rebuilt and reran all tests; named
   allocation and same-session request/release passed on PG14-18. Stop condition
   was not reached because the second substantive solution succeeded.

### pgbouncer_fdw build and validation boundary

1. The unmodified 1.4.0 source built all five architecture-independent DEBs;
   package metadata and the generated versioned SQL/control paths were checked.
2. Installed PgBouncer 1.25.2 and all five extension packages, then created
   `dblink` and `pgbouncer_fdw` in the independent PG14-18 clusters. Every load
   test and catalog/object smoke check passed.
3. No configured PgBouncer admin console is available in this disposable
   environment. Stop at the task-authorized load-test boundary rather than
   fabricate an external integration result; resume that test when a real
   endpoint and credentials are supplied.

### faker build and finite attempts

1. Noble does not publish the RPM-style package name `python3-faker`; apt
   evidence identified the official Universe package `python3-fake-factory`
   22.0.0-1. Its first download hit a transient HTTP EOF for `python3-dateutil`;
   `apt-get --fix-missing` retrieved that same official dependency and the
   installation completed. This was transport recovery, not a source change.
2. Unpatched DEBs built and PG14-16 passed, but PG17-18 rejected
   `CREATE OR REPLACE FUNCTION json(...)` in the extension SQL. The error was a
   PostgreSQL parser change around the unquoted `json` identifier, not a Python
   Faker API failure.
3. Added a focused quilt patch changing the declaration to
   `CREATE OR REPLACE FUNCTION "json"(...)`. This preserves the lower-case SQL
   name and is harmless on older releases. Rebuilt, reinstalled, and reran the
   same initialization/generation smoke test; PG14-18 all passed.

### pg_dbms_errlog version choice and validation

1. Compared PGRPM 2.2 with the current upstream release metadata and changelog.
   Upstream 2.4 has necessary PG18 and worker correctness fixes, so packaging
   the older PGRPM snapshot would be the less supportable route.
2. The unmodified 2.4 source built all five DEBs. Installed them with the
   repository's existing, correctly versioned arm64 `pg_statement_rollback 1.5`
   packages and verified package files and dependencies.
3. Configured the documented preload requirement and restarted each disposable
   cluster. PG14-18 all passed a DML-continuity/error-table test with the actual
   worker path. No source patch or further attempt was needed.

### odbc_fdw build and validation boundary

1. Audited the new fork's 0.6.1 source and PGRPM spec. The release/package
   version is newer than the embedded SQL API version 0.5.2; the Debian recipe
   preserves upstream's values and documents the distinction. The permissive
   Expat/PostgreSQL file-level licensing is redistributable.
2. Installed official Noble `unixodbc-dev`, built all five packages, and
   confirmed generated runtime dependencies include `libodbc2`.
3. PG14-18 all passed install, extension creation, foreign-server validator,
   and handler catalog checks. No supported ODBC driver or test DSN is
   configured, so stop at the task-authorized FDW load boundary and resume only
   when such an endpoint is available.

### pg_dbms_job build and finite attempts

1. Applying the PGRPM include patch caused all five builds to fail at
   `libpq-fe.h: No such file or directory`. Evidence from `libpq-dev` showed
   Debian installs `/usr/include/postgresql/libpq-fe.h`, proving that upstream's
   original `postgresql/libpq-fe.h` path is the correct Debian form.
2. Removed the RPM-specific patch. All five core builds and installs completed,
   but packaging stopped because the draft `dh_installdocs` list named absent
   `AUTHORS` and `CONTRIBUTORS` files. This was a recipe metadata error after
   successful compilation, not an upstream compatibility failure.
3. Restricted installed docs to the archive's actual `README.md` and
   `ChangeLog`. The final build succeeded; install, preload, extension creation,
   stable worker startup, async job execution, queue removal, and history
   recording then passed on PG14-18. The three-attempt limit was respected.

### dbt2 extension build and scope boundary

1. License/source audit established Artistic-2.0 and that the PostgreSQL C
   stored functions build independently of the full CMake kit and
   `dbt2-common`. A standalone extension recipe was selected rather than adding
   a nonexistent Debian hard dependency.
2. The first multi-version build produced packages, but build logs proved every
   loop used PG18 headers because the upstream sub-Makefile hard-coded
   `pg_config`. Those packages were rejected without installation or testing.
3. Added a standard patch honoring pg_buildext's `PG_CONFIG`, rebuilt, and
   verified each compiler line used its matching PG14-18 headers. All packages
   then passed install/create and a real SPI `stock_level()` smoke test. Full
   benchmark integration remains conditional on a separately packaged driver,
   schema, data generator, and test run.

### hdfs_fdw build and validation boundary

1. Audited the 6.4 MB archive and confirmed the JNI bridge is source code under
   the upstream permissive license. The first OpenJDK install hit one transient
   Ubuntu mirror EOF; `apt-get --fix-missing` retrieved the same official
   `dbus-bin` dependency and completed without changing sources.
2. Built the source bridge, Java adapter, and all five PostgreSQL modules. Added
   a focused `$ORIGIN` runpath because installed-module `ldd` evidence would
   otherwise leave private `libhive.so` unresolved.
3. All versions passed install and a JVM/JNI/class/FDW-handler smoke. Stop at
   the task-authorized FDW boundary because no supported Hive JDBC driver,
   Hadoop/Hive service, schema, or credentials are available. Resume with those
   prerequisites for the upstream query suite.

### jdbc_fdw build, PG18 assessment, and validation boundary

1. Upstream 0.5.0 compiled through PG17, but the initial all-version build
   stopped on PG18: `ExplainState` was no longer defined by `explain.h`, and
   `create_foreignscan_path`/`create_foreign_upper_path` had gained a required
   `disabled_nodes` argument. This confirms PG14-17 and isolates PG18 rather
   than treating the absent PGRPM packages as an architecture failure.
2. Added a focused PostgreSQL 18 compatibility patch based on the installed
   PG18 headers. The next compile exposed the rest of the same header split:
   `ExplainPropertyText` now comes from `explain_format.h`. Completing that
   include made the same API-adaptation path succeed; no feature was disabled.
3. A fresh source build produced PG14-18 arm64 DEBs. All five installed, linked
   to Noble's default JVM, created the extension, returned version code 500,
   and accepted/recorded a validated foreign server. Stop at the authorized
   FDW load boundary because no JDBC driver JAR, remote service, schema, or
   credentials are present. Resume with those prerequisites for query testing.

### db2_fdw hard-block exit

1. Official Noble/PGDG apt search and filesystem/library probes found no Db2
   client headers, library, or installed SDK path.
2. PGRPM source/spec inspection proved the RPM relies on a separately installed
   `/opt/ibm/db2/V11.5` client and suppresses the otherwise unsatisfied
   `libdb2.so.1` dependency; its non-free binary channel is x86_64 only.
3. IBM's current distribution/platform evidence does not provide an ARM64 Db2
   client. The direct PG18 preflight confirmed `sqlcli1.h` is the first hard
   build dependency. Stop: another source-level attempt cannot create the
   missing proprietary architecture build. Resume conditions are documented in
   the stopped-evaluation section.

### informix_fdw hard-block exit

1. Official Noble/PGDG apt search and filesystem/library probes found no CSDK,
   `esql`, or private Informix libraries.
2. PGRPM spec inspection proved the SDK dependency is intentionally external,
   filtered from RPM dependency generation, and only x86_64 binaries exist.
3. IBM's current matrix has no ARM64 CSDK and no Ubuntu 24.04 support row; the
   authorized download route requires entitlement. The direct PG18 preflight
   failed at `esql` preprocessing. Stop rather than bypass a core function or
   fetch an untrusted binary; resume conditions are documented above.

## Final milestone report

All twelve requested extensions now have an evidenced terminal classification.
Ten have complete Debian recipes and five-version runtime evidence; two stopped
at hard proprietary architecture/dependency barriers. “Smoke” below means the
specific test described in each completed-port section, not an unperformed
external-system test.

| Extension | Final class | PG / architecture actually tested | Compile | DEB | Install | `CREATE EXTENSION` | Smoke | Full external integration |
|---|---|---|---|---|---|---|---|---|
| `pg_dbms_metadata` | **可做** | 14-18 / Noble arm64 substitute | n/a, SQL | passed | passed | passed | DDL function passed | n/a |
| `pg_dbms_lock` | **可做** | 14-18 / Noble arm64 substitute | n/a, SQL | passed | passed | passed | numeric/named locks passed | n/a |
| `pgbouncer_fdw` | **可做** | 14-18 / Noble arm64 substitute | n/a, SQL | passed | passed | passed | object/load test passed | **not run** |
| `faker` | **可做** | 14-18 / Noble arm64 substitute | passed | passed | passed | passed | init/name/email passed | n/a |
| `pg_dbms_errlog` | **可做** | 14-18 / Noble arm64 substitute | passed | passed | passed | passed | real duplicate-key logging passed | n/a |
| `odbc_fdw` | **可做** | 14-18 / Noble arm64 substitute | passed | passed | passed | passed | handler/server load passed | **not run** |
| `pg_dbms_job` | **可做** | 14-18 / Noble arm64 substitute | passed | passed | passed | passed | real async job passed | n/a |
| `dbt2` extension | **可做** | 14-18 / Noble arm64 substitute | passed | passed | passed | passed | real SPI function passed | full benchmark **not run** |
| `hdfs_fdw` | **可做** | 14-18 / Noble arm64 substitute | passed, C/Java/JNI | passed | passed | passed | JVM/class/server load passed | **not run** |
| `jdbc_fdw` | **可做** | 14-18 / Noble arm64 substitute | passed, C/Java/JNI | passed | passed | passed | version/server validation passed | **not run** |
| `db2_fdw` | **做不了（当前 U24A）** | PG18 preflight / Noble arm64 substitute | failed at proprietary header | no | no | no | no | no |
| `informix_fdw` | **做不了（当前 U24A）** | PG18 preflight / Noble arm64 substitute | failed at proprietary preprocessor | no | no | no | no | no |

Thus the evidence totals are: twelve research conclusions, ten source/PGXS
build paths (including two pure-SQL packages), fifty successful DEBs, fifty
successful installations, fifty successful `CREATE EXTENSION` operations, and
fifty extension-appropriate smoke tests. No complete external PgBouncer, ODBC,
Hive/Hadoop, JDBC, Db2, or Informix service integration test is claimed.
The substitute container retains all fifty DEBs under `/root/ext/pkg-fixed`; its
sorted `SHA256SUMS` manifest has SHA-256
`e882218f8fe09b291183bdab90eb8223705f06b41cc5e5fe452cafc4d990d458`.

### Created and modified files

Only task-owned untracked files were created; no pre-existing tracked file was
modified. This progress report is the sole root-level file. Standard recipe
trees were created under:

- `debbuild/pg_dbms_metadata/`
- `debbuild/pg_dbms_lock/`
- `debbuild/pgbouncer_fdw/`
- `debbuild/faker/`
- `debbuild/pg_dbms_errlog/`
- `debbuild/odbc_fdw/`
- `debbuild/pg_dbms_job/`
- `debbuild/dbt2/`
- `debbuild/hdfs_fdw/`
- `debbuild/jdbc_fdw/`

Each contains the repository-style `Makefile`, `debian/control.in`, `rules`,
`pgversions`, `changelog`, `copyright`, and `source/format`. Focused quilt
patches exist only where evidence required them: pg_background v2 API and
stable asynchronous tests for `pg_dbms_lock`, quoted `json` and reproducible
LTO paths for `faker`, cluster-scoped worker tests for `pg_dbms_job`,
version-selected `PG_CONFIG` and reproducible LLVM paths for `dbt2`, private
`libhive` RUNPATH for `hdfs_fdw`, and portable JVM plus PG18 planner/EXPLAIN
compatibility for `jdbc_fdw`. No recipe was created for the two
proprietary hard-blocked wrappers because it could not produce an installable,
truthful Noble arm64 package.

### Remaining risks and resume conditions

- The original SSH U24A host remains inaccessible. Every success above is real
  but belongs to the explicitly identified disposable Ubuntu 24.04.4 arm64
  substitute, not that host. Re-run the standard build/install/smoke commands
  when its SSH configuration or address becomes available.
- FDW load tests do not prove remote type mapping, authentication, pushdown,
  transaction, timeout, or failure-recovery behavior. Supply supported services,
  drivers, schemas, and credentials before promotion to external-integration
  status.
- `jdbc_fdw` PG18 relies on a small downstream API patch beyond upstream's
  documented PG13-17 range. Keep the patch until upstream adopts equivalent
  support, and run its remote query regression suite before production use.
- `pg_dbms_errlog` and `pg_dbms_job` require preload/restart configuration;
  package installation alone does not activate their workers.
- `faker` now requires `python3-fake-factory (>= 6.1.1)`, matching the upstream
  API baseline. Debian 12's official 0.9.3 package does not satisfy it, so a
  maintained dependency backport is required before publishing faker for
  Bookworm. The package will fail dependency resolution rather than silently
  expose an unverified provider surface.
- The repository-wide Debian 12/13, Ubuntu 22.04/24.04 and amd64 matrix remains
  to be executed. This round's full rebuild remains Noble arm64 only.
- `dbt2` here is the PostgreSQL stored-function extension. Packaging/running the
  full benchmark driver/data generator is a separate conditional project.
- Resume `db2_fdw` or `informix_fdw` only when the architecture/SDK,
  entitlement, redistribution/dependency packaging, and remote test-service
  conditions listed in their stopped-evaluation sections are all satisfied.

### Recommended next order

1. Revalidate the ten recipes on the original U24A once access returns.
2. Add real external tests in increasing infrastructure cost: PgBouncer admin
   console, ODBC test DSN, JDBC test database/driver, then Hive/Hadoop.
3. Package and run the full DBT-2 benchmark kit only if that broader artifact is
   desired.
4. Reopen Db2/Informix last, and only after IBM supplies a supported target SDK
   or an authorized supported-architecture build environment is provided.

## Round log

### 2026-07-11 round 1

Completed:

- Recorded clean initial worktree and protected four pre-existing local commits.
- Found and documented the pre-existing AGENTS/CLAUDE symlink loop.
- Attempted all available non-destructive U24A discovery routes; original host
  remains inaccessible.
- Downloaded and inspected current official SRPMs for all twelve extensions.
- Verified upstream current tags and repository activity through upstream APIs.
- Established the first complete feasibility matrix and initial ordering.
- Selected `pg_dbms_metadata`, created its Debian recipe, and completed build,
  install, `CREATE EXTENSION`, and SQL smoke testing on PG14-18.
- Packaged `pg_dbms_lock`, fixed a real pg_background 2.x API defect, and passed
  build/install/create/numeric-lock/named-lock tests on PG14-18.
- Packaged `pgbouncer_fdw` and passed DEB build, installation, extension load,
  and catalog/object smoke tests on PG14-18; external PgBouncer integration was
  not run and is recorded separately.
- Packaged `faker`, mapped Noble's differently named official Python dependency,
  fixed the PG17/18 `json` parser incompatibility, and passed build/install/
  create/generation smoke tests on PG14-18.
- Packaged upstream `pg_dbms_errlog` 2.4, used the repository's existing
  `pg_statement_rollback` dependency, and passed preload/create/real DML error
  logging tests on PG14-18.
- Packaged `odbc_fdw` 0.6.1 and passed build/install/create/handler validation
  on PG14-18; live ODBC driver/DSN integration remains explicitly untested.
- Packaged `pg_dbms_job` 2.0, rejected an RPM-only include patch based on actual
  Debian header evidence, and passed real async background-worker tests on
  PG14-18 within the three-attempt limit.
- Packaged the independently useful `dbt2` PostgreSQL C extension, corrected
  license metadata and multi-version ABI selection, and passed SPI function
  tests on PG14-18; no full benchmark result is claimed.
- Packaged `hdfs_fdw` fully from source and passed private-library, OpenJDK 21,
  JNI, class-loading, extension, and handler smoke tests on PG14-18; live Hive
  query integration remains conditional.
- Packaged upstream `jdbc_fdw` 0.5.0 with portable JVM linking, added a bounded
  PostgreSQL 18 API adaptation, and passed build/install/create/version/server
  validation on PG14-18 arm64; live JDBC queries remain conditional.
- Exhausted the three meaningful prerequisite paths for `db2_fdw` and
  `informix_fdw` (apt, PGRPM, and IBM official delivery/platform evidence),
  captured real missing-SDK PG18 build errors, and classified both as
  **做不了（当前 U24A）** with explicit resume conditions.
- Consolidated the final twelve-row verification table, retained fifty final
  DEBs in `/root/ext/pkg-fixed` inside the substitute container, verified the two
  key downstream patch series apply and unapply cleanly, and removed generated
  workspace build directories/artifacts.

Build/test results: milestone B and C passed in the explicitly labelled
disposable Ubuntu 24.04 arm64 substitute environment. Original SSH U24A remains
unverified because it is inaccessible.

Remaining limitations:

- Original SSH U24A host is unavailable.
- No external PgBouncer/ODBC/Hive/JDBC integration services were configured.
- Db2/Informix cannot be resumed on current U24A without the documented IBM
  architecture, entitlement, packaging-policy, and test-service prerequisites.

Next exact operation:

1. When original U24A access returns, rerun each recipe's standard build and
   the recorded smoke tests there, starting with `pg_dbms_metadata`.
2. If external endpoints are supplied first, add integration tests in the
   recommended order recorded above.

### 2026-07-11 production review remediation

The post-port production review found and fixed the following packaging defects:

- `pg_dbms_lock.control` now declares `requires = 'pg_background'`. A fresh
  database rejects non-CASCADE creation with the expected prerequisite error;
  `CREATE EXTENSION pg_dbms_lock CASCADE` creates both extensions and named
  allocation succeeds.
- `dbt2` and `pg_dbms_errlog` now include `${shlibs:Depends}`. The rebuilt PG18
  packages declare `libc6 (>= 2.38)` and `libc6 (>= 2.17)` respectively.
- faker requires `python3-fake-factory (>= 6.1.1)`; `pgbouncer_fdw` moved a
  local PgBouncer daemon from `Depends` to `Recommends` because remote targets
  are supported.
- Every recipe pins and verifies the exact upstream tarball SHA-256, removes
  stale package artifacts before setup, has ordered targets safe under
  parallel make, and copies only freshly produced DEB/DDEB files.
- All ten completed recipes are registered in the category sections of the
  repository-level `debbuild/Makefile`, so the conventional
  `make <extension>` entry points route to them.
- All seven compiled extensions now produce automatic dbgsym packages.
- Future-dated changelogs were corrected, and explicit prefix maps removed
  source paths from dbt2 LLVM bitcode and faker's PostgreSQL 14 LTO output.
- faker had an additional ABI defect: default `dh_auto_build` compiled once
  against PostgreSQL 18 before the version loop, so the PG14 package received
  that binary. An empty `override_dh_auto_build` now guarantees that every
  package is compiled only inside its matching `pg_buildext` iteration. The
  final five faker shared libraries have distinct per-version hashes and the
  PG14 compiler command uses PG14 headers.
- Each source package now has a `debian/tests` gate. Pure SQL and worker
  extensions run upstream regression/TAP suites; external FDWs run honest
  load/JVM/validator smoke tests without claiming a remote query.

Validation performed after remediation in the Noble arm64 substitute:

- Rebuilt and installed 50 main DEBs plus 35 dbgsym DDEBs.
- `pg_dbms_metadata`, faker, and `pg_dbms_errlog`: six upstream regression
  tests on each of PG14-18, all passed (30 assertions per extension).
- `pg_dbms_lock`: five TAP files / 24 assertions on each of PG14-18, all 120
  assertions passed after replacing an insufficient asynchronous wait.
- `pg_dbms_job`: seven TAP files / 69 assertions passed on every PG14-18
  version, 345 assertions in total. The test GUCs target the regression
  database/user, and worker counts are scoped through the current cluster's
  `pg_stat_activity`.
- `pgbouncer_fdw`, `odbc_fdw`, `hdfs_fdw`, `jdbc_fdw`, and `dbt2`: package-level
  smoke passed on every PG14-18 version. HDFS exercised JVM/JNI/class loading;
  JDBC PG18 exercised the downstream validator port. Remote service queries
  remain explicitly outside this result.
- JDBC now uses an `$ORIGIN` RUNPATH and a package-managed relative `libjvm.so`
  link instead of embedding the build host's absolute JVM directory. HDFS puts
  its client JAR under the versioned `/usr/share/java` hierarchy. Both Java
  sources are compiled with `--release 8`; inspection reports class-file major
  version 52. The JNI libraries pass the `BIND_NOW` hardening check.
- Two clean builds from different native Linux source paths produced 85/85
  byte-identical DEB/DDEB artifacts. The final main and debug manifest hashes
  are `7972c85b6de4cbf1af9450acfbab2514f119c1ecc124d5bb75123c7ca8b1bcd7`
  and `74077533984aa4252c09bf8a1a20ad14b9675bc12f8342ecd0e08fcc8da0b0ed`.
- No regular-file or symlink path collisions exist among the 85 artifacts, and
  the final all-package installation leaves `dpkg --audit` empty.
- Full Lintian inspection of the final 50 main DEBs and 35 dbgsym DDEBs reports
  zero errors and 25 warnings. The remaining warnings are 20
  `package-installs-java-bytecode` findings for the intentional HDFS/JDBC Java
  payloads and five `shared-library-lacks-prerequisites` findings for faker's
  PostgreSQL loadable modules; neither is hidden with a Lintian override.

This remediation raises the local Noble arm64 packaging result to a production
candidate for the extensions without external services. It does not close the
original U24A, cross-distribution/amd64, live FDW service, source-package
publication/signing, Db2, or Informix conditions documented above.

### 2026-07-13 pre-commit acceptance rerun

The ten completed recipes were copied from the current workspace to
`/root/acceptance-src-20260713` in the container's native Linux filesystem and
rebuilt from clean source into `/root/ext/acceptance-native-20260713`.

- All ten recipes built successfully and again produced 50 main DEBs plus 35
  dbgsym DDEBs. Every one of the 85 artifacts was byte-identical to the frozen
  `/root/ext/pkg-fixed` counterpart.
- The newly built packages installed successfully and left `dpkg --audit`
  empty. Patched source state was restored with `dpkg-source --before-build`
  before invoking each `debian/tests` entry, matching normal autopkgtest source
  extraction semantics.
- `pg_dbms_metadata`, faker, and `pg_dbms_errlog` again passed six upstream
  regression tests on each PG14-18 version. `pg_dbms_lock` passed 24 TAP
  assertions on each version, 120 total. `pg_dbms_job` passed 69 TAP assertions
  on each version, 345 total, including the previously outstanding full PG15-17
  rerun.
- `dbt2`, `pgbouncer_fdw`, `odbc_fdw`, `hdfs_fdw`, and `jdbc_fdw` passed their
  package-level smoke on each PG14-18 version. This still does not claim live
  external-service integration.
- Lintian again reported zero errors and the same 25 reviewed warnings. Package
  dependency checks, relative JVM links, `$ORIGIN` RUNPATHs, Java class-file
  major version 52, versioned HDFS JAR paths, real-file/symlink collision checks,
  and build-path leakage checks all passed.
- A discarded diagnostic build made directly on the macOS bind mount changed
  only tar-recorded symlink modes. Repeating the build on the required native
  Linux filesystem restored 85/85 reproducibility; bind-mounted macOS paths are
  therefore not accepted as a reference build environment.
