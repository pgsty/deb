-- re2 0.4.1 metadata refresh.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 're2') THEN
        RAISE EXCEPTION 'pgext.extension row re2 does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '0.4.1',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16'],
       rpm_ver  = '0.4.1',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 're2_$v',
       rpm_pg   = ARRAY['18', '17', '16'],
       deb_ver  = '0.4.1',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-re2',
       deb_pg   = ARRAY['18', '17', '16'],
       source   = 're2-0.4.1.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'Stable PGXN and PIGSTY package release 0.4.1 for PostgreSQL 16 through 18.',
       mtime    = CURRENT_DATE
 WHERE name = 're2'
 RETURNING id, name, version, pg_ver, rpm_ver, deb_ver, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 're2'
           AND version = '0.4.1'
           AND pg_ver = ARRAY['18', '17', '16']
           AND rpm_ver = '0.4.1'
           AND deb_ver = '0.4.1'
    ) THEN
        RAISE EXCEPTION 're2 metadata verification failed';
    END IF;
END
$$;

COMMIT;
