# HAProxy

This recipe builds HAProxy 3.4.2 from the official upstream tarball with one
portable Debian packaging overlay.

The overlay is based on Debian's `3.2.21-1~bpo12+1` packaging and refreshed for
HAProxy 3.4.2.

Supported builders:

- Debian 11 (`d11`, `d11a`)
- Debian 12 / 13 (`d12`, `d12a`, `d13`, `d13a`)
- Ubuntu 20.04 (`u20`, `u20a`)
- Ubuntu 22.04 / 24.04 / 26.04 (`u22`, `u22a`, `u24`, `u24a`, `u26`, `u26a`)

The package version is suffixed with the builder codename, for example
`3.4.2-1PIGSTY~bookworm` or `3.4.2-1PIGSTY~noble`.

The build enables OpenSSL, PCRE2 JIT, Lua, SLZ, QUIC compatibility and the
Prometheus exporter (`USE_PROMEX=1`). OpenTracing is intentionally omitted: it
is deprecated upstream and its development package is not available across the
full supported distribution matrix.

```bash
cd ~/debbuild
pig build get haproxy
make haproxy
```

If the public source mirror has not been updated yet, copy only
`haproxy-3.4.2.tar.gz` into `~/debbuild/SOURCES/` before building.
