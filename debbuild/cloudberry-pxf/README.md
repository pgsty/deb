# cloudberry-pxf debbuild

This recipe builds the Apache Cloudberry PXF 2.2.0 package.

## Usage

```bash
cd ~/debbuild/cloudberry-pxf
make
```

Required local tarball:

`~/ext/src/apache-cloudberry-pxf-2.2.0-incubating-src.tar.gz`

The Gradle 8.14.4 distribution, wrapper JAR and wrapper checksum must also be
available in `~/ext/src/`; see the recipe Makefile for their exact filenames.

The installed program files are owned by root. Prepare a writable runtime
directory as the service user before starting PXF:

```bash
export PXF_BASE="$HOME/pxf"
export JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
/usr/cloudberry-pxf/bin/pxf prepare
/usr/cloudberry-pxf/bin/pxf start
```

Keep `PXF_BASE` set for subsequent status/stop commands. An administrator must
register the PXF control files under `/usr/cloudberry/share/postgresql/extension/`
before creating the database extensions, because that directory is also owned
by root.
