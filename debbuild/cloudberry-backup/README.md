# cloudberry-backup debbuild

This recipe builds the Apache Cloudberry Backup 2.2.0 package.

The upstream project has not published a 2.2.0 release tag. The source archive
is a deterministic snapshot of `apache/cloudberry-backup` main commit
`6d61e7e744243f256c971a90e0b33841cae36aea` (2026-08-13), where `VERSION`
is `2.2.0`. Its SHA-256 is
`19f2e8f2c6a25ff59b11b938e58211342d26c0679922c691b0672a53246bd7de`.

## Usage

```bash
cd ~/debbuild/cloudberry-backup
make
```

Required local tarball:

`~/ext/src/apache-cloudberry-backup-2.2.0-src.tar.gz`

The recipe uses Go's automatic toolchain selector because upstream declares
`go 1.25.0` in `go.mod`. It packages gpbackup, gprestore,
gpbackup_helper, gpbackup_s3_plugin, gpbackman, and gpbackup_exporter.
