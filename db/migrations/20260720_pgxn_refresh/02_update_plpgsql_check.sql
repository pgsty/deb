-- plpgsql_check 2.10.1 metadata refresh from PGDG to PIGSTY packages.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'plpgsql_check') THEN
        RAISE EXCEPTION 'pgext.extension row plpgsql_check does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '2.10.1',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '2.10.1',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'plpgsql_check_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '2.10.1',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-plpgsql-check',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'plpgsql_check-2.10.1.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'PIGSTY RPM and DEB packages are aligned at 2.10.1 for PostgreSQL 14 through 18.',
       mtime    = CURRENT_DATE
 WHERE name = 'plpgsql_check'
 RETURNING id, name, version, repo, rpm_ver, deb_ver, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'plpgsql_check'
           AND version = '2.10.1'
           AND repo = 'PIGSTY'
           AND rpm_repo = 'PIGSTY'
           AND deb_repo = 'PIGSTY'
    ) THEN
        RAISE EXCEPTION 'plpgsql_check metadata verification failed';
    END IF;
END
$$;

COMMIT;
