# pg_living_assertions 0.5.1

Source: [official v0.5.1 tag archive](https://codeload.github.com/Manuelreyesbravo/pg_living_assertions/tar.gz/refs/tags/v0.5.1).
The official archive is used unchanged.
SHA256: `80b9049aa16a15e38d64bea75c093d233df64f8457dd4c3d53e000926bc8449c`.

PostgreSQL targets: 14, 15, 16, 17, 18.

pg_living_assertions stores SQL checks, their results, verification times
and assertion replacement history. Checks run on demand in a read-only
subtransaction that is always rolled back. This is not a per-write SQL ASSERTION constraint.
