-- powa 5.2.0 upstream metadata refresh; packaged PGDG versions stay unchanged.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'powa') THEN
        RAISE EXCEPTION 'pgext.extension row powa does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '5.2.0',
       repo     = 'PGDG',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '5.1.0',
       rpm_repo = 'PGDG',
       rpm_pkg  = 'powa_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '5.1.2',
       deb_repo = 'PGDG',
       deb_pkg  = 'postgresql-$v-powa',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       extra    = COALESCE(extra, '{}'::jsonb) || '{"pgxn": true}'::jsonb,
       comment  = 'Latest stable upstream/PGXN release is 5.2.0; packaged versions remain PGDG RPM 5.1.0 and DEB 5.1.2; PGDG is missing EL10 PG17.',
       mtime    = CURRENT_DATE
 WHERE name = 'powa'
 RETURNING id, name, version, rpm_ver, rpm_repo, deb_ver, deb_repo;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'powa'
           AND version = '5.2.0'
           AND rpm_ver = '5.1.0'
           AND deb_ver = '5.1.2'
           AND rpm_repo = 'PGDG'
           AND deb_repo = 'PGDG'
    ) THEN
        RAISE EXCEPTION 'powa metadata verification failed';
    END IF;
END
$$;

COMMIT;
