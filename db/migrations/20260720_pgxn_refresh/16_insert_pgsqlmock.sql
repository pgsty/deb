-- Add or fully recalibrate pgsqlmock 1.0.1 metadata.

BEGIN;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pgext.extension WHERE id = 3130 AND name <> 'pgsqlmock'
    ) THEN
        RAISE EXCEPTION 'extension id 3130 is already used by another extension';
    END IF;
    IF EXISTS (
        SELECT missing.name
          FROM unnest(ARRAY['plpgsql', 'pgtap']) AS missing(name)
         WHERE NOT EXISTS (
             SELECT 1 FROM pgext.extension e WHERE e.name = missing.name
         )
    ) THEN
        RAISE EXCEPTION 'required extension metadata plpgsql or pgtap is missing';
    END IF;
END
$$;

INSERT INTO pgext.extension AS current (
    id, name, pkg, lead_ext, category, state,
    url, license, tags, version, repo, lang,
    contrib, lead, has_bin, has_lib, need_ddl, need_load,
    trusted, relocatable, schemas, pg_ver,
    requires, require_by, see_also,
    rpm_ver, rpm_repo, rpm_pkg, rpm_pg, rpm_deps,
    deb_ver, deb_repo, deb_pkg, deb_deps, deb_pg,
    source, extra, en_desc, zh_desc, comment, mtime
) VALUES (
    3130, 'pgsqlmock', 'pgsqlmock', 'pgsqlmock', 'LANG', 'available',
    'https://github.com/v-maliutin/pgSQLMock',
    'PostgreSQL',
    ARRAY['test', 'mock', 'pgtap'],
    '1.0.1', 'PIGSTY', 'SQL',
    false, true, false, false, true, false,
    false, true, NULL, ARRAY['18', '17', '16', '15', '14'],
    ARRAY['plpgsql', 'pgtap'], ARRAY[]::text[],
    ARRAY['pgtap', 'pg_mockable', 'faker', 'unit'],
    '1.0.1', 'PIGSTY', 'pgsqlmock_$v',
    ARRAY['18', '17', '16', '15', '14'], ARRAY['pgtap_$v'],
    '1.0.1', 'PIGSTY', 'postgresql-$v-pgsqlmock',
    ARRAY['postgresql-$v-pgtap'], ARRAY['18', '17', '16', '15', '14'],
    'pgsqlmock-1.0.1.tar.gz',
    '{"deb": true, "rpm": true, "pgxn": true, "type": "puresql"}'::jsonb,
    'Mocking and faking helpers for PostgreSQL unit tests',
    '为 PostgreSQL 单元测试提供函数 Mock、表和视图伪造能力',
    'Packaging corrects the upstream control dependency name from pgTap to pgtap and requires pgTAP 1.3.4 or newer.',
    CURRENT_DATE
)
ON CONFLICT (name) DO UPDATE SET
    id          = EXCLUDED.id,
    pkg         = EXCLUDED.pkg,
    lead_ext    = EXCLUDED.lead_ext,
    category    = EXCLUDED.category,
    state       = EXCLUDED.state,
    url         = EXCLUDED.url,
    license     = EXCLUDED.license,
    tags        = EXCLUDED.tags,
    version     = EXCLUDED.version,
    repo        = EXCLUDED.repo,
    lang        = EXCLUDED.lang,
    contrib     = EXCLUDED.contrib,
    lead        = EXCLUDED.lead,
    has_bin     = EXCLUDED.has_bin,
    has_lib     = EXCLUDED.has_lib,
    need_ddl    = EXCLUDED.need_ddl,
    need_load   = EXCLUDED.need_load,
    trusted     = EXCLUDED.trusted,
    relocatable = EXCLUDED.relocatable,
    schemas     = EXCLUDED.schemas,
    pg_ver      = EXCLUDED.pg_ver,
    requires    = EXCLUDED.requires,
    require_by  = COALESCE(current.require_by, EXCLUDED.require_by),
    see_also    = EXCLUDED.see_also,
    rpm_ver     = EXCLUDED.rpm_ver,
    rpm_repo    = EXCLUDED.rpm_repo,
    rpm_pkg     = EXCLUDED.rpm_pkg,
    rpm_pg      = EXCLUDED.rpm_pg,
    rpm_deps    = EXCLUDED.rpm_deps,
    deb_ver     = EXCLUDED.deb_ver,
    deb_repo    = EXCLUDED.deb_repo,
    deb_pkg     = EXCLUDED.deb_pkg,
    deb_deps    = EXCLUDED.deb_deps,
    deb_pg      = EXCLUDED.deb_pg,
    source      = EXCLUDED.source,
    extra       = COALESCE(current.extra, '{}'::jsonb) || EXCLUDED.extra,
    en_desc     = EXCLUDED.en_desc,
    zh_desc     = EXCLUDED.zh_desc,
    comment     = EXCLUDED.comment,
    mtime       = EXCLUDED.mtime
RETURNING id, name, version, rpm_pkg, deb_pkg;

UPDATE pgext.extension
   SET require_by = array_append(
           COALESCE(require_by, ARRAY[]::text[]),
           'pgsqlmock'
       ),
       mtime = CURRENT_DATE
 WHERE name = ANY (ARRAY['plpgsql', 'pgtap'])
   AND NOT (COALESCE(require_by, ARRAY[]::text[]) @> ARRAY['pgsqlmock']);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE id = 3130
           AND name = 'pgsqlmock'
           AND version = '1.0.1'
           AND requires = ARRAY['plpgsql', 'pgtap']
           AND rpm_deps = ARRAY['pgtap_$v']
           AND deb_deps = ARRAY['postgresql-$v-pgtap']
           AND has_lib = false
           AND relocatable = true
    ) OR 2 <> (
        SELECT count(*) FROM pgext.extension
         WHERE name = ANY (ARRAY['plpgsql', 'pgtap'])
           AND COALESCE(require_by, ARRAY[]::text[]) @> ARRAY['pgsqlmock']
    ) THEN
        RAISE EXCEPTION 'pgsqlmock metadata verification failed';
    END IF;
END
$$;

COMMIT;
