# HAProxy

This recipe builds HAProxy 3.4.3 from the official upstream tarball with one
portable Debian packaging overlay.

The overlay tracks Debian's `3.4.2-1` packaging where it is portable across the
supported builders and is refreshed for HAProxy 3.4.3. Its runtime contract is
kept aligned with the RPM spec and the RPM `haproxy-utils.tar.gz` helper source.
All permanent upstream-source changes are carried in the single versioned patch
`debian/patches/haproxy-3.4.3.patch`; Debian-only files are maintained directly.

Supported builders:

- Debian 12 / 13 (`d12`, `d12a`, `d13`, `d13a`)
- Ubuntu 22.04 / 24.04 / 26.04 (`u22`, `u22a`, `u24`, `u24a`, `u26`, `u26a`)

The package version is suffixed with the builder codename, for example
`3.4.3-1PIGSTY~bookworm` or `3.4.3-1PIGSTY~noble`.

The build enables OpenSSL, PCRE2 JIT, Lua, SLZ, QUIC and the Prometheus
exporter (`USE_PROMEX=1`). It uses OpenSSL's native QUIC API on 3.5.2 and newer
and the HAProxy compatibility layer on older targets. OpenTracing is
intentionally omitted: it is deprecated upstream and its development package
is not available across the full supported distribution matrix.

The package creates `/etc/haproxy/conf.d` and generates its vendor unit from
HAProxy's `admin/systemd/haproxy.service.in`. The unit reads only
`/etc/default/haproxy`, uses `EXTRAOPTS`, and loads `/etc/haproxy/haproxy.cfg`
before complete configuration sections from `conf.d`. The compatibility SysV
init script follows the same configuration order. The default configuration is
byte-identical to the RPM helper asset: it provides stdout logging, conservative
TCP defaults, and loopback-only health, statistics, and Prometheus endpoints at
`127.0.0.1:9101`.

Distribution-specific user-management and dependency choices remain in this
overlay so one recipe can build across all supported Debian and Ubuntu releases.
In particular, the recipe keeps `adduser` instead of requiring the newer
`dh-sequence-installsysusers`. `dh_installsystemd` still generates the matching
maintainer scripts, while the payload is normalized to the canonical
`/usr/lib/systemd/system/haproxy.service` path on every supported target.

```bash
cd ~/debbuild
pig build get -f haproxy-3.4.3.tar.gz
make haproxy
```

Use `-f` only after the public source mirror has been synchronized and
verified. If the mirror has not been updated yet, copy only
`haproxy-3.4.3.tar.gz` into `~/debbuild/SOURCES/` before building. The recipe
checks the archive against the official upstream SHA-256 before unpacking it.
