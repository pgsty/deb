# HAProxy

This recipe builds HAProxy 3.4.4 from the official upstream tarball with one
portable Debian packaging overlay.

The overlay tracks Debian's `3.4.2-1` packaging where it is portable across the
supported builders and is refreshed for HAProxy 3.4.4.

## Shared downstream assets

Since `3.4.3-2PIGSTY` this recipe and the Pigsty RPM spec consume the very same
versioned `haproxy-utils` archive. For this update that archive is
`haproxy-utils-3.4.4.tar.gz`. The `Makefile` unpacks it into `utils/`
in the build tree and `debian/rules` installs from there, so there is exactly
one source of truth for:

| File | Installed as |
|---|---|
| `utils/haproxy.cfg` | `/etc/haproxy/haproxy.cfg` |
| `utils/haproxy.default` | `/etc/default/haproxy` |
| `utils/haproxy.service` | `/usr/lib/systemd/system/haproxy.service` |
| `utils/haproxy.logrotate` | `/etc/logrotate.d/haproxy` |
| `utils/haproxy.rsyslog` | `/etc/rsyslog.d/49-haproxy.conf` |
| `utils/haproxy.tmpfiles` | `/usr/lib/tmpfiles.d/haproxy.conf` |
| `utils/halog.1` | `/usr/share/man/man1/halog.1.gz` |

No copies of these files are kept under `debian/`. As a result the source patch
has collapsed to a single Debian specific change
(`debian/patches/haproxy-3.4.4.patch`, which keeps compiler path-remapping
flags out of the reproducible `haproxy -vv` banner).

The shipped unit is a downstream file rather than something generated at build
time. Both recipes verify the upstream template it was derived from against a
fixed SHA-256, so an upstream revision fails the build instead of silently
diverging.

## Supported builders

- Debian 12 / 13 (`d12`, `d12a`, `d13`, `d13a`)
- Ubuntu 22.04 / 24.04 / 26.04 (`u22`, `u22a`, `u24`, `u24a`, `u26`, `u26a`)

The package version is suffixed with the builder codename, for example
`3.4.4-1PGSTY~bookworm` or `3.4.4-1PGSTY~noble`.

## Build features

The build enables OpenSSL, PCRE2 JIT, Lua, SLZ, QUIC and the Prometheus
exporter (`USE_PROMEX=1`). It uses OpenSSL's native QUIC API on 3.5.2 and newer
and the HAProxy compatibility layer on older targets. OpenTracing is
intentionally omitted: it is deprecated upstream and its development package
is not available across the full supported distribution matrix.

The package links against the system allocator. jemalloc is a supported
upstream option and measurably lowers CPU use on connection churn heavy
workloads, but it costs roughly 40 MB of resident memory per process and is
only available from EPEL on Enterprise Linux. It was dropped in
`3.4.3-2PIGSTY` so that both package families behave identically without
adding an EPEL runtime dependency to a component installed on every node.
Rebuild with `-ljemalloc` in `ADDLIB` if your workload is allocator bound.

## Runtime contract

The package creates `/etc/haproxy/conf.d`. The unit reads only
`/etc/default/haproxy`, uses `EXTRAOPTS`, and loads `/etc/haproxy/haproxy.cfg`
before complete configuration sections from `conf.d`. The compatibility SysV
init script follows the same configuration order. The default configuration
provides stdout logging, conservative TCP defaults, an explicit `maxconn 8192`,
and a runtime API socket at `/run/haproxy/admin.sock`. It ships no network
listener: deployments define their own listeners as complete sections in
`conf.d`.

Package upgrades reload rather than restart the running instance, matching the
RPM packages.

## Distribution specific choices

These stay in the overlay so one recipe can build across all supported Debian
and Ubuntu releases, and because they have no Enterprise Linux equivalent:

- `adduser` in the maintainer script instead of `dh-sequence-installsysusers`,
  guarded by `getent` so it behaves the same from Debian 11 onwards
- the compatibility SysV init script
- the `vim-haproxy` addon, following the Debian vim policy
- HTML documentation built with the packaged dconv adaptations
- `/etc/haproxy/errors`, kept alongside the shared `/usr/share/haproxy` so that
  existing Debian configurations keep resolving

`dh_installsystemd` still generates the matching maintainer scripts, while the
payload is normalized to the canonical `/usr/lib/systemd/system/haproxy.service`
path on every supported target.

## Building

```bash
cd ~/debbuild
pig build get -f haproxy-3.4.4.tar.gz haproxy-utils-3.4.4.tar.gz
make haproxy
```

Use `-f` only after the public source mirror has been synchronized and
verified. If the mirror has not been updated yet, copy only those two archives
into `~/debbuild/SOURCES/` before building. The recipe checks both against
their official SHA-256 digests before unpacking them.

## Regenerating the shared archive

The archive is generated from a staging directory named `haproxy-utils` with
GNU tar and gzip. File order, ownership, timestamps, archive format, and gzip
header are fixed. For 3.4.4 the exact command is:

```bash
COPYFILE_DISABLE=1 TZ=UTC gtar \
  --sort=name --owner=0 --group=0 --numeric-owner \
  --mtime='2026-08-31 00:00:00 UTC' --format=gnu \
  --no-xattrs --no-acls -cf - haproxy-utils | \
  gzip -n -9 > haproxy-utils-3.4.4.tar.gz
```

Running the command twice must produce SHA-256
`fc929e99ef9441b3b054051d59b1b8eb02e65f29bb7563bdba9afa3583149f1d`.
The 3.4.4 upstream systemd template is byte-identical to 3.4.3, so the shared
downstream files themselves are unchanged; only the deterministic archive
timestamp and versioned filename advance.
