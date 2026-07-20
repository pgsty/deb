-- pgmq 1.12.0 metadata refresh.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'pgmq') THEN
        RAISE EXCEPTION 'pgext.extension row pgmq does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '1.12.0',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '1.12.0',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'pgmq_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '1.12.0',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-pgmq',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'pgmq-1.12.0.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       mtime    = CURRENT_DATE
 WHERE name = 'pgmq'
 RETURNING id, name, version, rpm_ver, deb_ver, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'pgmq'
           AND version = '1.12.0'
           AND rpm_ver = '1.12.0'
           AND deb_ver = '1.12.0'
    ) THEN
        RAISE EXCEPTION 'pgmq metadata verification failed';
    END IF;
END
$$;

COMMIT;
