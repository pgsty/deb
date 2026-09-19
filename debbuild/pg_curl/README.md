# pg_curl composite source

The packaged 2.4.6 release is the deterministic composite of:

- the official PGXN 2.4.6 archive, corresponding to
  `RekGRpth/pg_curl` commit `35481dc401864f7cfaf75be7e87d002780b1906f`
- its `pg_whitelist` gitlink commit
  `fbca6aef6962b20126714eaaa3f55c77f65bb5c3`

The official PGXN archive contains only the gitlink directory, so it
cannot build by itself. `repack.sh` downloads the fixed PGXN release and
pinned submodule archive,
verifies their hashes, fills the gitlink, records `SOURCE-MANIFEST.pgsty`, and
uses GNU tar plus `gzip -n` with fixed ownership, order and mtime. Two runs
must produce:

```text
61bd578ecfe0369af783bf422e26710e861f6996e264093ea4dda7578bfd2244  pg_curl-2.4.6.tar.gz
```

Before applying the shared DEB/RPM patch, both recipes copy the new upstream
`pg_curl--2.4.sql` to `pg_curl--2.4.1.sql`. The patch then restores every
previously published script byte-for-byte, changes the default version to
2.4.1, and adds the 2.4-to-2.4.1 catalog-only upgrade edge.
