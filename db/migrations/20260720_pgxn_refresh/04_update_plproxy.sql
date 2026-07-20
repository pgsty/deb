-- plproxy 2.12.0: PIGSTY RPM with the existing PGDG DEB package retained.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'plproxy') THEN
        RAISE EXCEPTION 'pgext.extension row plproxy does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '2.12.0',
       repo     = 'MIXED',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '2.12.0',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'plproxy_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '2.11.0',
       deb_repo = 'PGDG',
       deb_pkg  = 'postgresql-$v-plproxy',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'plproxy-2.12.0.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb) || '{"rpm": true}'::jsonb,
       comment  = 'PIGSTY RPM is 2.12.0; PGDG DEB remains at 2.11.0.',
       mtime    = CURRENT_DATE
 WHERE name = 'plproxy'
 RETURNING id, name, version, repo, rpm_ver, rpm_repo, deb_ver, deb_repo;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'plproxy'
           AND version = '2.12.0'
           AND repo = 'MIXED'
           AND rpm_ver = '2.12.0'
           AND rpm_repo = 'PIGSTY'
           AND deb_ver = '2.11.0'
           AND deb_repo = 'PGDG'
    ) THEN
        RAISE EXCEPTION 'plproxy metadata verification failed';
    END IF;
END
$$;

COMMIT;
