# jev 0.2.0

Source: [https://api.pgxn.org/dist/jev/0.2.0/jev-0.2.0.zip](https://api.pgxn.org/dist/jev/0.2.0/jev-0.2.0.zip).
The PGXN ZIP is normalized to `jev-0.2.0.tar.gz` with GNU tar,
sorted entries, epoch timestamps, numeric root ownership and `gzip -n9`.
The source content is unchanged. SHA256: `814e7bb2999edc070758d853e776271216425e0f699cf7ca5efa9b2d637a03e5`.

PostgreSQL targets: 14, 15, 16, 17.

jev filters, ranks and classifies PostgreSQL rows through a remote
TypeSafe model API. It requires plpython3u and an API key; row contents
are sent to the configured external service. This package contains SQL
and embedded Python code only, with no native shared library.
