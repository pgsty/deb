-- Add or fully recalibrate cron_utils 0.1.0 metadata.

BEGIN;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pgext.extension WHERE id = 1140 AND name <> 'cron_utils'
    ) THEN
        RAISE EXCEPTION 'extension id 1140 is already used by another extension';
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
    1140, 'cron_utils', 'cron_utils', 'cron_utils', 'TIME', 'available',
    'https://github.com/Myshkouski/pg-cron-utils',
    'MIT',
    ARRAY['cron', 'schedule'],
    '0.1.0', 'PIGSTY', 'SQL',
    false, true, false, false, true, false,
    false, true, NULL, ARRAY['18', '17', '16', '15', '14'],
    ARRAY[]::text[], ARRAY[]::text[],
    ARRAY['pg_cron', 'pg_when', 'pgcalendar', 'periods'],
    '0.1.0', 'PIGSTY', 'cron_utils_$v',
    ARRAY['18', '17', '16', '15', '14'], ARRAY[]::text[],
    '0.1.0', 'PIGSTY', 'postgresql-$v-cron-utils',
    ARRAY[]::text[], ARRAY['18', '17', '16', '15', '14'],
    'cron_utils-0.1.0.tar.gz',
    '{"deb": true, "rpm": true, "pgxn": true, "type": "puresql", "status": "unstable"}'::jsonb,
    'Parse cron expressions and compute previous or next trigger times',
    '解析 Cron 表达式并计算上一次或下一次触发时间',
    'The PGXN 0.1.0 distribution is marked unstable; the control file marks the extension relocatable.',
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
RETURNING id, name, version, relocatable, rpm_pkg, deb_pkg;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE id = 1140
           AND name = 'cron_utils'
           AND version = '0.1.0'
           AND pg_ver = ARRAY['18', '17', '16', '15', '14']
           AND has_lib = false
           AND trusted = false
           AND relocatable = true
    ) THEN
        RAISE EXCEPTION 'cron_utils metadata verification failed';
    END IF;
END
$$;

COMMIT;
