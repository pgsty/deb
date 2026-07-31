# HAProxy

This recipe builds HAProxy 3.4.3 from the official upstream tarball with one
portable Debian packaging overlay.

The overlay tracks Debian's `3.4.2-1` packaging where it is portable across the
supported builders and is refreshed for HAProxy 3.4.3. It shares the runtime
contract documented in
`~/pgsty/rpm/HAPROXY.md` with the RPM package.

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
HAProxy's `admin/systemd/haproxy.service.in`. Both systemd and the compatibility
SysV init script load `/etc/haproxy/haproxy.cfg` first and then `conf.d`.
Distribution-specific user-management and dependency choices remain in this
overlay so one recipe can build across all supported Debian and Ubuntu releases.
In particular, the recipe keeps `adduser` instead of requiring the newer
`dh-sequence-installsysusers`. The generated unit is staged as
`debian/haproxy.service`, allowing each debhelper version to select its native
vendor-unit directory and generate the matching maintainer scripts.

```bash
cd ~/debbuild
pig build get -f haproxy-3.4.3.tar.gz
make haproxy
```

Use `-f` only after the public source mirror has been synchronized and
verified. If the mirror has not been updated yet, copy only
`haproxy-3.4.3.tar.gz` into `~/debbuild/SOURCES/` before building. The recipe
checks the archive against the official upstream SHA-256 before unpacking it.
