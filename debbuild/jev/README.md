# jev 0.2.1

Source: [https://api.pgxn.org/dist/jev/0.2.1/jev-0.2.1.zip](https://api.pgxn.org/dist/jev/0.2.1/jev-0.2.1.zip).
The PGXN ZIP is normalized to `jev-0.2.1.tar.gz` with GNU tar,
sorted entries, epoch timestamps, numeric root ownership and timestamp-free gzip compression.
The source content is unchanged. SHA256: `5b7b20b605a43e32e4e26fd2a210c9906309fec8f388d372a52ecec65984bd75`.

PostgreSQL targets: 14, 15, 16, 17.

jev filters, ranks and classifies PostgreSQL rows through a remote
Jev-compatible model API. It requires plpython3u; the TypeSafe provider
also requires an API key. Row contents are sent to the configured service. This package contains SQL
and embedded Python code only, with no native shared library.
