# pg_living_assertions 0.5.10

Source: [official v0.5.10 tag archive](https://codeload.github.com/Manuelreyesbravo/pg_living_assertions/tar.gz/refs/tags/v0.5.10).
The official archive is used unchanged.
SHA256: `62ec0d1bdb569d6b339bf60783e04783b96d17481494808623ac0a8733eb30fd`.
License: Apache-2.0.

PostgreSQL targets: 14, 15, 16, 17, 18.

pg_living_assertions stores SQL checks, their results, verification times
and assertion replacement history. Checks run on demand in a read-only
subtransaction that is always rolled back. This is not a per-write SQL ASSERTION constraint.
