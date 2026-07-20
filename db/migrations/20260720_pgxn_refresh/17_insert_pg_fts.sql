-- Add or fully recalibrate pg_fts 0.2.0 metadata.

BEGIN;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pgext.extension WHERE id = 2220 AND name <> 'pg_fts'
    ) THEN
        RAISE EXCEPTION 'extension id 2220 is already used by another extension';
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
    2220, 'pg_fts', 'pg_fts', 'pg_fts', 'FTS', 'available',
    'https://codeberg.org/gregburd/pg_fts',
    'PostgreSQL AND MIT',
    ARRAY['fts', 'bm25', 'bm25f'],
    '0.2.0', 'PIGSTY', 'C',
    false, true, false, true, true, false,
    true, true, NULL, ARRAY['18', '17'],
    ARRAY[]::text[], ARRAY[]::text[],
    ARRAY['pg_search', 'pg_textsearch', 'vchord_bm25',
          'psql_bm25s', 'pg_bestmatch'],
    '0.2.0', 'PIGSTY', 'pg_fts_$v',
    ARRAY['18', '17'], ARRAY[]::text[],
    '0.2.0', 'PIGSTY', 'postgresql-$v-pg-fts',
    ARRAY[]::text[], ARRAY['18', '17'],
    'pg_fts-0.2.0.tar.gz',
    '{"deb": true, "rpm": true, "pgxn": true, "type": "standard", "lib": "$libdir/pg_fts"}'::jsonb,
    'Full-text search with BM25 and BM25F ranking',
    '提供 BM25、BM25F 排序与专用倒排索引的全文检索扩展',
    'Requires PostgreSQL 17 or newer; the control file marks the extension trusted and relocatable; RPM builds also provide an llvmjit subpackage.',
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
RETURNING id, name, version, trusted, relocatable, rpm_pkg, deb_pkg;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE id = 2220
           AND name = 'pg_fts'
           AND version = '0.2.0'
           AND pg_ver = ARRAY['18', '17']
           AND trusted = true
           AND relocatable = true
           AND has_lib = true
    ) THEN
        RAISE EXCEPTION 'pg_fts metadata verification failed';
    END IF;
END
$$;

COMMIT;
