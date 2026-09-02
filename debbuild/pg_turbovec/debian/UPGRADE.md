# pg_turbovec 1.28.3 or 1.29.x to 2.0.0

Version 2.0.0 changes the on-disk turbovec index format from wire v7 to
wire v8. Installing or successfully building the package does not migrate any
database. Plan a maintenance window and apply the following sequence to every
database containing the extension:

1. Record every index using the `turbovec` access method and stop application
   writes that can change the indexed tables.
2. Install the 2.0.0 package, then restart PostgreSQL so no backend retains the
   1.28.3/1.29.x shared library.
3. Reconnect and run `ALTER EXTENSION pg_turbovec UPDATE TO '2.0.0';`.
4. Run `REINDEX INDEX schema.index_name;` once for every turbovec index. Do not
   resume indexed queries until all indexes are rebuilt from their heap data.

Use this query before the package change to generate the required REINDEX list:

```sql
SELECT format('REINDEX INDEX %s;', i.indexrelid::regclass)
FROM pg_index AS i
JOIN pg_class AS c ON c.oid = i.indexrelid
JOIN pg_am AS am ON am.oid = c.relam
WHERE am.amname = 'turbovec'
ORDER BY i.indexrelid::regclass::text;
```

The release deliberately has no in-place wire converter. A 2.0.0 scan of a
pre-v8 index must fail with a REINDEX hint rather than read the old format.

## Release test gate

Before publication, validate both fresh install and a real currently published
package upgrade on U24A for PostgreSQL 14 through 18 (currently 1.29.0; the
shipped SQL graph is guarded continuously from 1.28.3). The upgrade test must
preserve a populated heap, prove the pre-REINDEX v7 scan fails with the expected
hint, and REINDEX every captured index. Compare the exact ordered distance
results before and after migration. Because v8 changes the quantizer and
on-disk candidate representation, approximate index candidate sets are not
required to be byte-for-byte identical to v7; instead, record their overlap and
gate top-1 correctness plus recall against the exact result set at a declared
`turbovec.search_k`.
Also verify `pg_extension.extversion = '2.0.0'`, dump/restore the upgraded
database, inspect the complete 1.29.0-to-2.0.0 SQL payload, and prove the final
shared object has no OpenBLAS `NEEDED` entry or unresolved `cblas_*` symbol.
