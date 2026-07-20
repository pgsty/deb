-- provsql 1.11.0 metadata refresh.
-- This file is self-contained and safe to run independently.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'provsql') THEN
        RAISE EXCEPTION 'pgext.extension row provsql does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '1.11.0',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '1.11.0',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'provsql_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '1.11.0',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-provsql',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'provsql-1.11.0.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       mtime    = CURRENT_DATE
 WHERE name = 'provsql'
 RETURNING id, name, version, rpm_ver, deb_ver, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'provsql'
           AND version = '1.11.0'
           AND rpm_ver = '1.11.0'
           AND deb_ver = '1.11.0'
           AND source = 'provsql-1.11.0.tar.gz'
    ) THEN
        RAISE EXCEPTION 'provsql metadata verification failed';
    END IF;
END
$$;

COMMIT;
