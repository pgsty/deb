# macavity 0.1.0

Source: [https://api.pgxn.org/dist/macavity/0.1.0/macavity-0.1.0.zip](https://api.pgxn.org/dist/macavity/0.1.0/macavity-0.1.0.zip).
The PGXN ZIP is normalized to `macavity-0.1.0.tar.gz` with GNU tar,
sorted entries, epoch timestamps, numeric root ownership and `gzip -n9`.
The source content is unchanged. SHA256: `8619bc459dabaa680d17e57d1b32547273c7b5133c5f8de88fe74ffe6829d03d`.

PostgreSQL targets: 16, 17, 18.

macavity injects session-local errors, delays and backend crashes at named
PostgreSQL execution points. This destructive testing extension is intended
only for development and disposable test clusters.
