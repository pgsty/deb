-- PGXN bson distribution / CREATE EXTENSION pgbson 2.0.4 metadata refresh.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'pgbson') THEN
        RAISE EXCEPTION 'pgext.extension row pgbson does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '2.0.4',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '2.0.4',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'postgresbson_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       rpm_deps = ARRAY['libbson'],
       deb_ver  = '2.0.4',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-pgbson',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'postgresbson-2.0.4.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'PGXN distribution name is bson; CREATE EXTENSION name is pgbson; package release 2.0.4 still installs extension SQL version 2.0; RPM package root is postgresbson and requires libbson.',
       mtime    = CURRENT_DATE
 WHERE name = 'pgbson'
 RETURNING id, name, version, rpm_pkg, deb_pkg, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'pgbson'
           AND version = '2.0.4'
           AND rpm_pkg = 'postgresbson_$v'
           AND deb_pkg = 'postgresql-$v-pgbson'
           AND source = 'postgresbson-2.0.4.tar.gz'
    ) THEN
        RAISE EXCEPTION 'pgbson metadata verification failed';
    END IF;
END
$$;

COMMIT;
