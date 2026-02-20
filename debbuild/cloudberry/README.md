# cloudberry debbuild

This package follows the repository-standard flow:

1. Read local source tarball from `../SOURCES/`.
2. Extract to `build/`.
3. Copy `debian/` into `build/debian`.
4. Run `dpkg-buildpackage`.

## Usage

```bash
cd ~/debbuild/cloudberry
make
```

Required local tarball (default):

`~/ext/src/apache-cloudberry-2.0.0-incubating-src.tar.gz`
