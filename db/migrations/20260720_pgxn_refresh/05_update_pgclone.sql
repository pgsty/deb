-- pgclone 4.4.2 metadata refresh.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'pgclone') THEN
        RAISE EXCEPTION 'pgext.extension row pgclone does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '4.4.2',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '4.4.2',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'pgclone_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '4.4.2',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-pgclone',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'pgclone-4.4.2.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'preload for async/progress; RPM LLVM_BINPATH build fix retained in the 4.4.2 package.',
       mtime    = CURRENT_DATE
 WHERE name = 'pgclone'
 RETURNING id, name, version, rpm_ver, deb_ver, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'pgclone'
           AND version = '4.4.2'
           AND rpm_ver = '4.4.2'
           AND deb_ver = '4.4.2'
    ) THEN
        RAISE EXCEPTION 'pgclone metadata verification failed';
    END IF;
END
$$;

COMMIT;
