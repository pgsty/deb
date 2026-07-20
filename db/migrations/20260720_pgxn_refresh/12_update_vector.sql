-- vector / pgvector 0.8.5: PGDG RPM with PIGSTY DEB packaging.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'vector') THEN
        RAISE EXCEPTION 'pgext.extension row vector does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '0.8.5',
       repo     = 'MIXED',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '0.8.5',
       rpm_repo = 'PGDG',
       rpm_pkg  = 'pgvector_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '0.8.5',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-pgvector',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'pgvector-0.8.5.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'PGDG RPM and PIGSTY DEB are aligned at pgvector 0.8.5.',
       mtime    = CURRENT_DATE
 WHERE name = 'vector'
 RETURNING id, name, version, repo, rpm_ver, rpm_repo, deb_ver, deb_repo;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'vector'
           AND version = '0.8.5'
           AND repo = 'MIXED'
           AND rpm_repo = 'PGDG'
           AND deb_repo = 'PIGSTY'
           AND source = 'pgvector-0.8.5.tar.gz'
    ) THEN
        RAISE EXCEPTION 'vector metadata verification failed';
    END IF;
END
$$;

COMMIT;
