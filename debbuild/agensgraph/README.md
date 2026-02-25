# agensgraph debbuild

This package follows the repository-standard flow:

1. Read local source tarball from `../SOURCES/`.
2. Extract to `build/`.
3. Copy `debian/` into `build/debian`.
4. Run `dpkg-buildpackage`.

## Usage

```bash
cd ~/debbuild/agensgraph
make
```

Required local tarball (default):

`~/ext/src/agensgraph-2.16.0.tar.gz`

Fetch from upstream release tag:

```bash
wget -O ~/ext/src/agensgraph-2.16.0.tar.gz \
  https://github.com/skaiworldwide-oss/agensgraph/archive/refs/tags/v2.16.0.tar.gz
```
