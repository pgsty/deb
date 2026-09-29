# macavity 0.2.0

Source: [official v0.2.0 tag archive](https://codeload.github.com/CrystallineCore/Macavity/tar.gz/refs/tags/v0.2.0).
The archive root is normalized with GNU tar, sorted entries, epoch timestamps,
numeric root ownership and `gzip -n9`; source contents are unchanged.
SHA256: `d1c9e13d7b445b1a923325d9d9bafca789153cf5e4ac164600a4ab12fcd3d82d`.

PostgreSQL targets: 16, 17, 18.

macavity injects session-local errors, delays and backend crashes at named
PostgreSQL execution points. This destructive testing extension is intended
only for development and disposable test clusters.
