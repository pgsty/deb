-- pg_search 0.24.3 metadata and reproducible pgrx toolchain calibration.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'pg_search') THEN
        RAISE EXCEPTION 'pgext.extension row pg_search does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '0.24.3',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15'],
       rpm_ver  = '0.24.3',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'pg_search_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15'],
       deb_ver  = '0.24.3',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-pg-search',
       deb_pg   = ARRAY['18', '17', '16', '15'],
       source   = 'pg_search-0.24.3.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true, "pgrx": "0.19.1"}'::jsonb,
       comment  = 'bm25 access method conflicts with pg_textsearch and vchord_bm25; PIGSTY packaging uses pgrx 0.19.1 and the pinned builder Rust toolchain instead of upstream rolling stable.',
       mtime    = CURRENT_DATE
 WHERE name = 'pg_search'
 RETURNING id, name, version, rpm_ver, deb_ver, extra ->> 'pgrx' AS pgrx;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'pg_search'
           AND version = '0.24.3'
           AND pg_ver = ARRAY['18', '17', '16', '15']
           AND extra ->> 'pgrx' = '0.19.1'
    ) THEN
        RAISE EXCEPTION 'pg_search metadata verification failed';
    END IF;
END
$$;

COMMIT;
