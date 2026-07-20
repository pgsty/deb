-- Add or fully recalibrate fbsql 0.1.0 metadata.

BEGIN;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pgext.extension WHERE id = 1910 AND name <> 'fbsql'
    ) THEN
        RAISE EXCEPTION 'extension id 1910 is already used by another extension';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'plr') THEN
        RAISE EXCEPTION 'required pgext.extension row plr does not exist';
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
    1910, 'fbsql', 'fbsql', 'fbsql', 'RAG', 'available',
    'https://github.com/dsc-chiba-u/FbSQL',
    'MIT',
    ARRAY['statistics', 'glm', 'machine-learning', 'plr'],
    '0.1.0', 'PIGSTY', 'SQL',
    false, true, false, false, true, false,
    false, false, ARRAY['fbsql'], ARRAY['18', '17', '16'],
    ARRAY['plr'], ARRAY[]::text[],
    ARRAY['pg4ml', 'pgml', 'pg_math', 'weighted_statistics'],
    '0.1.0', 'PIGSTY', 'fbsql_$v',
    ARRAY['18', '17', '16'], ARRAY['plr_$v'],
    '0.1.0', 'PIGSTY', 'postgresql-$v-fbsql',
    ARRAY['postgresql-$v-plr'], ARRAY['18', '17', '16'],
    'fbsql-0.1.0.tar.gz',
    '{"deb": true, "rpm": true, "pgxn": true, "type": "puresql"}'::jsonb,
    'Closure-preserving formula-based statistical modeling in SQL',
    '在 SQL 中保持关系闭包的公式化统计建模扩展',
    'Requires PL/R 8.4.0 or newer; PIGSTY packages target PostgreSQL 16 through 18.',
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
           'fbsql'
       ),
       mtime = CURRENT_DATE
 WHERE name = 'plr'
   AND NOT (COALESCE(require_by, ARRAY[]::text[]) @> ARRAY['fbsql']);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE id = 1910
           AND name = 'fbsql'
           AND version = '0.1.0'
           AND pg_ver = ARRAY['18', '17', '16']
           AND requires = ARRAY['plr']
           AND rpm_deps = ARRAY['plr_$v']
           AND deb_deps = ARRAY['postgresql-$v-plr']
    ) OR NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'plr'
           AND COALESCE(require_by, ARRAY[]::text[]) @> ARRAY['fbsql']
    ) THEN
        RAISE EXCEPTION 'fbsql metadata verification failed';
    END IF;
END
$$;

COMMIT;
