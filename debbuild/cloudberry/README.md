# cloudberry debbuild

This recipe builds the Apache Cloudberry 2.2.0 main package.

## Usage

```bash
cd ~/debbuild/cloudberry
DEB_BUILD_OPTIONS=parallel=4 make
```

The recipe uses the requested parallel job limit and defaults to one job when
`DEB_BUILD_OPTIONS` does not specify `parallel`.

Required local tarball:

`~/ext/src/apache-cloudberry-2.2.0-incubating-src.tar.gz`
