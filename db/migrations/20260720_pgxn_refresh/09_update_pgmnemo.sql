-- pgmnemo 0.13.0 metadata refresh and PostgreSQL support-range correction.

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'pgmnemo') THEN
        RAISE EXCEPTION 'pgext.extension row pgmnemo does not exist';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'vector') THEN
        RAISE EXCEPTION 'required pgext.extension row vector does not exist';
    END IF;
END
$$;

UPDATE pgext.extension
   SET version  = '0.13.0',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17'],
       requires = ARRAY['vector'],
       rpm_ver  = '0.13.0',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'pgmnemo_$v',
       rpm_pg   = ARRAY['18', '17'],
       rpm_deps = ARRAY['pgvector_$v'],
       deb_ver  = '0.13.0',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-pgmnemo',
       deb_deps = ARRAY['postgresql-$v-pgvector'],
       deb_pg   = ARRAY['18', '17'],
       source   = 'pgmnemo-0.13.0.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'SQL-only extension requiring pgvector 0.7.0 or newer; upstream 0.13.0 and PIGSTY packages support PostgreSQL 17 and 18.',
       mtime    = CURRENT_DATE
 WHERE name = 'pgmnemo'
 RETURNING id, name, version, pg_ver, rpm_deps, deb_deps;

UPDATE pgext.extension
   SET require_by = array_append(
           COALESCE(require_by, ARRAY[]::text[]),
           'pgmnemo'
       ),
       mtime = CURRENT_DATE
 WHERE name = 'vector'
   AND NOT (COALESCE(require_by, ARRAY[]::text[]) @> ARRAY['pgmnemo']);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'pgmnemo'
           AND version = '0.13.0'
           AND pg_ver = ARRAY['18', '17']
           AND rpm_deps = ARRAY['pgvector_$v']
           AND deb_deps = ARRAY['postgresql-$v-pgvector']
    ) OR NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'vector'
           AND COALESCE(require_by, ARRAY[]::text[]) @> ARRAY['pgmnemo']
    ) THEN
        RAISE EXCEPTION 'pgmnemo metadata verification failed';
    END IF;
END
$$;

COMMIT;
