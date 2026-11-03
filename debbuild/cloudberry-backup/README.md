# cloudberry-backup debbuild

This recipe builds the Apache Cloudberry Backup 2.2.0 package.

The source is the official Apache 2.2.0-incubating release, verified against
the SHA-512 checksum in the Apache download directory. The earlier local
2.2.0 main snapshot was not imported into either production repository.

## Usage

```bash
cd ~/debbuild/cloudberry-backup
make
```

Required local tarball:

`~/ext/src/apache-cloudberry-backup-2.2.0-incubating-src.tar.gz`

The recipe uses Go's automatic toolchain selector because upstream declares
`go 1.25.0` in `go.mod`. It packages gpbackup, gprestore,
gpbackup_helper, gpbackup_s3_plugin, gpbackman, and gpbackup_exporter.
