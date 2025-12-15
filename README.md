# PGSTY Deb Package Builder

Extensions Building Scripts for PostgreSQL 13 - 18 on Debian 12/13 Ubuntu 22/24.

- [Pigsty PGSQL Repo](https://pgext.cloud/repo/pgsql)
- [DEB Change Log](https://pgext.cloud/release/deb)


## Use with pig

You can build extension DEBs with [pig](https://pgext.cloud/pig).

```bash
curl https://repo.pigsty.cc/pig | bash -s 0.7.5
pig build repo
pig build tool
pig build spec # <--- get this repo, setup building environment
pig build rust
pig build pgrx

# then build packages
pig build pkg timescaledb
pig build pkg pg_search
```


## Signature

All Deb Packages are signed with GPG key `9592A7BC7A682E7333376E09E7935D8DB9BD8B20` (`B9BD8B20` [Public key](KEYS))


## License

Maintainer: Ruohang Feng / [@Vonng](https://vonng.com/en/) ([rh@vonng.com](mailto:rh@vonng.com))

License: [Apache-2.0](LICENSE)
