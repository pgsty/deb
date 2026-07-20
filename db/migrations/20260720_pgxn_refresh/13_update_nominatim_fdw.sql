-- nominatim_fdw 2.0.0 metadata refresh from mixed PGDG/PIGSTY versions.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'nominatim_fdw') THEN
        RAISE EXCEPTION 'pgext.extension row nominatim_fdw does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '2.0.0',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '2.0.0',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'nominatim_fdw_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '2.0.0',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-nominatim-fdw',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'nominatim_fdw-2.0.0.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'PIGSTY RPM and DEB packages are aligned at 2.0.0 for PostgreSQL 14 through 18.',
       mtime    = CURRENT_DATE
 WHERE name = 'nominatim_fdw'
 RETURNING id, name, version, repo, rpm_ver, deb_ver, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'nominatim_fdw'
           AND version = '2.0.0'
           AND repo = 'PIGSTY'
           AND rpm_repo = 'PIGSTY'
           AND deb_repo = 'PIGSTY'
    ) THEN
        RAISE EXCEPTION 'nominatim_fdw metadata verification failed';
    END IF;
END
$$;

COMMIT;
