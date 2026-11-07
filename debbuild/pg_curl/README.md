# pg_curl composite source

The packaged 2.5.0 release combines the official PGXN archive with its
pg_whitelist submodule, which is absent from the PGXN archive:

- pg_curl commit: `6abdb3dbe81c0e320eebeeb0120cff993d593b31`
- pg_whitelist commit: `9001c0cb09483e0828c2578f8e842cf00268a44e`

`repack.sh` verifies the fixed input hashes, fills the submodule directory,
records `SOURCE-MANIFEST.pgsty`, and uses GNU tar plus `gzip -n` with fixed
ownership, order and mtime. Run GitHub downloads through the local proxy:

```sh
HTTPS_PROXY=http://127.0.0.1:8888 ./repack.sh /path/to/archive-output
```

Both RPM and DEB repack scripts produce:

```text
9069819503d80eef660575f06e22e2a627e519481c79b4d22307a4d4e6a87fd4  pg_curl-2.5.0.tar.gz
```

The package installs upstream SQL version 2.5, including the upstream
2.4-to-2.5 upgrade script. The obsolete downstream 2.4.1 workaround is no
longer applied; packaging adds no SQL migration scripts.
