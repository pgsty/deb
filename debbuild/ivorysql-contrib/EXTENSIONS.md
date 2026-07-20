# IvorySQL 5 contrib extensions

This package is the Debian/Ubuntu counterpart of Pigsty's
`ivorysql-18-contrib` RPM. It is compiled against
`/usr/ivory-18/bin/pg_config` and fills the exact extension-name gap between
the Pigsty IvorySQL 5.4 kernel and the official IvorySQL 5.4 bundle.

## Package contract

- PostgreSQL ABI: PostgreSQL 18, as used by IvorySQL 5.x.
- Kernel dependency: `ivorysql-18 (>= 5.0), ivorysql-18 (<< 6.0)`.
- Extension controls: 29.
- Top-level PostgreSQL modules: 31, including `wal2json.so`.
- Install prefix: `/usr/ivory-18`; no files are installed in PGDG's
  `/usr/lib/postgresql/18` prefix.
- External libraries such as GEOS, PROJ, GDAL, SFCGAL, Groonga, SCWS,
  hiredis, and curl remain normal DEB dependencies.
- On Ubuntu 24.04, the Pigsty `apt/pgsql/noble` repository supplies the
  required `libgroonga0 >= 15.1.7` and `scws >= 1.2.3` runtime packages.

`plpgsql_check` is deliberately pinned to the official package's 2.8 ABI.
Upstream 2.9 has no 2.8-to-2.9 extension update script and rejects calls from
a database whose catalog still records 2.8, so packaging 2.9 would break a
database migrated from the official IvorySQL package.

## Source projects

| Project | Packaged extension version(s) |
|---|---|
| PostGIS | 3.5.4: `address_standardizer`, `address_standardizer_data_us`, `postgis`, `postgis_raster`, `postgis_sfcgal`, `postgis_tiger_geocoder`, `postgis_topology` |
| pgRouting | 3.8.0 |
| PGroonga | 4.0.4: `pgroonga`, `pgroonga_database` |
| AGE | 1.7.0 |
| ddlx | 0.31 |
| HTTP | 1.7 |
| pgAgent | 4.2 |
| pgAudit | 18.0 |
| pg_bigm | 1.2 |
| pg_cron | 1.6 |
| pg_curl | 2.4 |
| pg_hint_plan | 1.8.0 |
| pg_jieba | 1.1.1 |
| pg_partman | source 5.4.2 |
| pg_show_plans | 2.1 |
| pg_stat_monitor | 2.3 |
| pg_textsearch | 1.2.0 |
| plpgsql_check | 2.8 |
| redis_fdw | 2.0 |
| system_stats | 4.0 |
| vector | 0.8.4 |
| wal2json | 2.6, output plugin without a control file |
| zhparser | 2.3 |

The sorted control-name and module-name lists must exactly match the official
gap. Some extension versions are newer than the official 5.4 snapshot; this
does not change PostgreSQL's extension discovery mechanism. Compatibility with
an official-package data directory is checked separately through control-file
semantics and extension upgrade tests.
