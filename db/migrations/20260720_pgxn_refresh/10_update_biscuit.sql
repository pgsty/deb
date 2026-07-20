-- Biscuit 2.4.3 stable package metadata refresh.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'biscuit') THEN
        RAISE EXCEPTION 'pgext.extension row biscuit does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '2.4.3',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16'],
       rpm_ver  = '2.4.3',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'biscuit_$v',
       rpm_pg   = ARRAY['18', '17', '16'],
       deb_ver  = '2.4.3',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-biscuit',
       deb_pg   = ARRAY['18', '17', '16'],
       source   = 'Biscuit-2.4.3.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'Latest stable PGXN distribution and package release is 2.4.3; 2.5.0 is testing; packaged control and SQL default version remain 2.4.1; package name is biscuit.',
       mtime    = CURRENT_DATE
 WHERE name = 'biscuit'
 RETURNING id, name, version, rpm_pkg, deb_pkg, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'biscuit'
           AND version = '2.4.3'
           AND rpm_ver = '2.4.3'
           AND deb_ver = '2.4.3'
           AND source = 'Biscuit-2.4.3.tar.gz'
    ) THEN
        RAISE EXCEPTION 'biscuit metadata verification failed';
    END IF;
END
$$;

COMMIT;
