-- pg_kazsearch 2.3.0 metadata and pgrx toolchain refresh.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'pg_kazsearch') THEN
        RAISE EXCEPTION 'pgext.extension row pg_kazsearch does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '2.3.0',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16'],
       rpm_ver  = '2.3.0',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'pg_kazsearch_$v',
       rpm_pg   = ARRAY['18', '17', '16'],
       deb_ver  = '2.3.0',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-pg-kazsearch',
       deb_pg   = ARRAY['18', '17', '16'],
       source   = 'pg_kazsearch-2.3.0.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true, "pgrx": "0.19.1", "upstream_pgrx": "0.17.0"}'::jsonb,
       comment  = 'Upstream 2.3.0 uses pgrx 0.17.0; PIGSTY packaging builds with pgrx 0.19.1 for PostgreSQL 16 through 18.',
       mtime    = CURRENT_DATE
 WHERE name = 'pg_kazsearch'
 RETURNING id, name, version, pg_ver, rpm_ver, deb_ver, extra ->> 'pgrx' AS pgrx;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'pg_kazsearch'
           AND version = '2.3.0'
           AND pg_ver = ARRAY['18', '17', '16']
           AND extra ->> 'pgrx' = '0.19.1'
    ) THEN
        RAISE EXCEPTION 'pg_kazsearch metadata verification failed';
    END IF;
END
$$;

COMMIT;
