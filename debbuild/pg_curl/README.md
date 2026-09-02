# pg_curl composite source

The packaged snapshot is the deterministic composite of:

- `RekGRpth/pg_curl` commit `f7a70f37d469e783d8268cb91af445145cbe005d`
- its `pg_whitelist` gitlink commit
  `fbca6aef6962b20126714eaaa3f55c77f65bb5c3`

GitHub's automatic parent archive contains only the gitlink directory, so it
cannot build by itself. `repack.sh` downloads both fixed commit archives,
verifies their hashes, fills the gitlink, records `SOURCE-MANIFEST.pgsty`, and
uses GNU tar plus `gzip -n` with fixed ownership, order and mtime. Two runs
must produce:

```text
4ef70d518b5b52399aa2df17dd50821f83763bb1213c2cab1ffa498e7a9c968d  pg_curl-2.4.5+git20260815.f7a70f3.tar.gz
```

Before applying the shared DEB/RPM patch, both recipes copy the new upstream
`pg_curl--2.4.sql` to `pg_curl--2.4.1.sql`. The patch then restores every
previously published script byte-for-byte, changes the default version to
2.4.1, and adds the 2.4-to-2.4.1 catalog-only upgrade edge.
