-- pgext.extension metadata refresh: 14 updates and 5 inserts.

-- provsql
UPDATE pgext.extension
   SET version  = '1.11.0',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '1.11.0',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'provsql_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '1.11.0',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-provsql',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'provsql-1.11.0.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       mtime    = CURRENT_DATE
 WHERE name = 'provsql';

-- plpgsql_check
UPDATE pgext.extension
   SET version  = '2.10.1',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '2.10.1',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'plpgsql_check_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '2.10.1',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-plpgsql-check',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'plpgsql_check-2.10.1.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'PIGSTY RPM and DEB packages are aligned at 2.10.1 for PostgreSQL 14 through 18.',
       mtime    = CURRENT_DATE
 WHERE name = 'plpgsql_check';

-- pg_search
UPDATE pgext.extension
   SET version  = '0.24.3',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15'],
       rpm_ver  = '0.24.3',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'pg_search_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15'],
       deb_ver  = '0.24.3',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-pg-search',
       deb_pg   = ARRAY['18', '17', '16', '15'],
       source   = 'pg_search-0.24.3.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true, "pgrx": "0.19.1"}'::jsonb,
       comment  = 'bm25 access method conflicts with pg_textsearch and vchord_bm25; PIGSTY packaging uses pgrx 0.19.1 and the pinned builder Rust toolchain instead of upstream rolling stable.',
       mtime    = CURRENT_DATE
 WHERE name = 'pg_search';

-- plproxy
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
 WHERE name = 'plproxy';

-- pgclone
UPDATE pgext.extension
   SET version  = '4.4.2',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '4.4.2',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'pgclone_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '4.4.2',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-pgclone',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'pgclone-4.4.2.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'preload for async/progress; RPM LLVM_BINPATH build fix retained in the 4.4.2 package.',
       mtime    = CURRENT_DATE
 WHERE name = 'pgclone';

-- pgbson
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
 WHERE name = 'pgbson';

-- pgmq
UPDATE pgext.extension
   SET version  = '1.12.0',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '1.12.0',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'pgmq_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '1.12.0',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-pgmq',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'pgmq-1.12.0.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       mtime    = CURRENT_DATE
 WHERE name = 'pgmq';

-- powa
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
 WHERE name = 'powa';

-- pgmnemo
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
 WHERE name = 'pgmnemo';

-- biscuit
UPDATE pgext.extension
   SET version  = '2.4.3',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16'],
       rpm_ver  = '2.4.3',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'biscuit_$v',
       rpm_pg   = ARRAY['18', '17', '16'],
       deb_ver  = '2.4.3',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-biscuit',
       deb_pg   = ARRAY['18', '17', '16'],
       source   = 'Biscuit-2.4.3.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'Latest stable PGXN distribution and package release is 2.4.3; 2.5.0 is testing; packaged control and SQL default version remain 2.4.1; package name is biscuit.',
       mtime    = CURRENT_DATE
 WHERE name = 'biscuit';

-- re2
UPDATE pgext.extension
   SET version  = '0.4.1',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16'],
       rpm_ver  = '0.4.1',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 're2_$v',
       rpm_pg   = ARRAY['18', '17', '16'],
       deb_ver  = '0.4.1',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-re2',
       deb_pg   = ARRAY['18', '17', '16'],
       source   = 're2-0.4.1.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'Stable PGXN and PIGSTY package release 0.4.1 for PostgreSQL 16 through 18.',
       mtime    = CURRENT_DATE
 WHERE name = 're2';

-- vector
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
 WHERE name = 'vector';

-- nominatim_fdw
UPDATE pgext.extension
   SET version  = '2.0.0',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16', '15', '14'],
       rpm_ver  = '2.0.0',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'nominatim_fdw_$v',
       rpm_pg   = ARRAY['18', '17', '16', '15', '14'],
       deb_ver  = '2.0.0',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-nominatim-fdw',
       deb_pg   = ARRAY['18', '17', '16', '15', '14'],
       source   = 'nominatim_fdw-2.0.0.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true}'::jsonb,
       comment  = 'PIGSTY RPM and DEB packages are aligned at 2.0.0 for PostgreSQL 14 through 18.',
       mtime    = CURRENT_DATE
 WHERE name = 'nominatim_fdw';

-- pg_kazsearch
UPDATE pgext.extension
   SET version  = '2.3.0',
       repo     = 'PIGSTY',
       pg_ver   = ARRAY['18', '17', '16'],
       rpm_ver  = '2.3.0',
       rpm_repo = 'PIGSTY',
       rpm_pkg  = 'pg_kazsearch_$v',
       rpm_pg   = ARRAY['18', '17', '16'],
       deb_ver  = '2.3.0',
       deb_repo = 'PIGSTY',
       deb_pkg  = 'postgresql-$v-pg-kazsearch',
       deb_pg   = ARRAY['18', '17', '16'],
       source   = 'pg_kazsearch-2.3.0.tar.gz',
       extra    = COALESCE(extra, '{}'::jsonb)
                  || '{"deb": true, "rpm": true, "pgrx": "0.19.1", "upstream_pgrx": "0.17.0"}'::jsonb,
       comment  = 'Upstream 2.3.0 uses pgrx 0.17.0; PIGSTY packaging builds with pgrx 0.19.1 for PostgreSQL 16 through 18.',
       mtime    = CURRENT_DATE
 WHERE name = 'pg_kazsearch';

-- fbsql
INSERT INTO pgext.extension (
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
);
-- pgsqlmock
INSERT INTO pgext.extension (
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
);

-- pg_fts
INSERT INTO pgext.extension (
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
);

-- cron_utils
INSERT INTO pgext.extension (
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
);

-- pg_tiktoken_c
INSERT INTO pgext.extension (
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
);
