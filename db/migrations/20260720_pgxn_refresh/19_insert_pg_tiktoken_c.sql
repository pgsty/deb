-- Add or fully recalibrate pg_tiktoken_c 1.1 metadata.
-- The user-facing shorthand pg_tiktok_c is normalized to the actual extension
-- and package name pg_tiktoken_c used by the control file and both package sets.

BEGIN;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pgext.extension WHERE id = 1920 AND name <> 'pg_tiktoken_c'
    ) THEN
        RAISE EXCEPTION 'extension id 1920 is already used by another extension';
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
    1920, 'pg_tiktoken_c', 'pg_tiktoken_c', 'pg_tiktoken_c', 'RAG', 'available',
    'https://github.com/relytcloud/pg_tiktoken_c',
    'Apache-2.0',
    ARRAY['tokenizer', 'tiktoken', 'openai'],
    '1.1', 'PIGSTY', 'C',
    false, true, false, true, true, false,
    false, false, NULL, ARRAY['18', '17', '16', '15', '14'],
    ARRAY[]::text[], ARRAY[]::text[],
    ARRAY['pg_tiktoken', 'pg_summarize', 'vectorize',
          'pgml', 'pg4ml', 'pg_graphql'],
    '1.1', 'PIGSTY', 'pg_tiktoken_c_$v',
    ARRAY['18', '17', '16', '15', '14'], ARRAY[]::text[],
    '1.1', 'PIGSTY', 'postgresql-$v-pg-tiktoken-c',
    ARRAY[]::text[], ARRAY['18', '17', '16', '15', '14'],
    'pg_tiktoken_c-1.1.tar.gz',
    '{"deb": true, "rpm": true, "type": "standard", "lib": "$libdir/pg_tiktoken_c", "snapshot": "fa2957b6ece483322f4c4ce0c374b3b77e22b892"}'::jsonb,
    'Fast tiktoken BPE tokenizer for PostgreSQL implemented in C',
    '使用 C 实现的 PostgreSQL 高性能 tiktoken BPE 分词扩展',
    'Built from upstream main snapshot fa2957b; bundles five vocabularies and includes DESTDIR and correctness patches. Upstream README declares Apache-2.0, but the pinned snapshot omits the referenced LICENSE file.',
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
         WHERE id = 1920
           AND name = 'pg_tiktoken_c'
           AND version = '1.1'
           AND pg_ver = ARRAY['18', '17', '16', '15', '14']
           AND has_lib = true
           AND trusted = false
           AND relocatable = false
           AND rpm_pkg = 'pg_tiktoken_c_$v'
           AND deb_pkg = 'postgresql-$v-pg-tiktoken-c'
    ) THEN
        RAISE EXCEPTION 'pg_tiktoken_c metadata verification failed';
    END IF;
END
$$;

COMMIT;
