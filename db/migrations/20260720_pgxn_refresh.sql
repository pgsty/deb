-- Complete pgext.extension metadata refresh for the 2026-07 PGXN/package batch.
-- Includes 14 existing-extension updates and 5 insert/upserts.
-- Atomic and re-runnable: every extension is checked before COMMIT.

BEGIN;

--------------------------------------------------------------------------------
-- 01_update_provsql.sql
--------------------------------------------------------------------------------
-- provsql 1.11.0 metadata refresh.
-- This file is self-contained and safe to run independently.


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'provsql') THEN
        RAISE EXCEPTION 'pgext.extension row provsql does not exist';
    END IF;
END
$$;

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
 WHERE name = 'provsql'
 RETURNING id, name, version, rpm_ver, deb_ver, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'provsql'
           AND version = '1.11.0'
           AND rpm_ver = '1.11.0'
           AND deb_ver = '1.11.0'
           AND source = 'provsql-1.11.0.tar.gz'
    ) THEN
        RAISE EXCEPTION 'provsql metadata verification failed';
    END IF;
END
$$;


--------------------------------------------------------------------------------
-- 02_update_plpgsql_check.sql
--------------------------------------------------------------------------------
-- plpgsql_check 2.10.1 metadata refresh from PGDG to PIGSTY packages.


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'plpgsql_check') THEN
        RAISE EXCEPTION 'pgext.extension row plpgsql_check does not exist';
    END IF;
END
$$;

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
 WHERE name = 'plpgsql_check'
 RETURNING id, name, version, repo, rpm_ver, deb_ver, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'plpgsql_check'
           AND version = '2.10.1'
           AND repo = 'PIGSTY'
           AND rpm_repo = 'PIGSTY'
           AND deb_repo = 'PIGSTY'
    ) THEN
        RAISE EXCEPTION 'plpgsql_check metadata verification failed';
    END IF;
END
$$;


--------------------------------------------------------------------------------
-- 03_update_pg_search.sql
--------------------------------------------------------------------------------
-- pg_search 0.24.3 metadata and reproducible pgrx toolchain calibration.


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'pg_search') THEN
        RAISE EXCEPTION 'pgext.extension row pg_search does not exist';
    END IF;
END
$$;

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
 WHERE name = 'pg_search'
 RETURNING id, name, version, rpm_ver, deb_ver, extra ->> 'pgrx' AS pgrx;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'pg_search'
           AND version = '0.24.3'
           AND pg_ver = ARRAY['18', '17', '16', '15']
           AND extra ->> 'pgrx' = '0.19.1'
    ) THEN
        RAISE EXCEPTION 'pg_search metadata verification failed';
    END IF;
END
$$;


--------------------------------------------------------------------------------
-- 04_update_plproxy.sql
--------------------------------------------------------------------------------
-- plproxy 2.12.0: PIGSTY RPM with the existing PGDG DEB package retained.


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


--------------------------------------------------------------------------------
-- 05_update_pgclone.sql
--------------------------------------------------------------------------------
-- pgclone 4.4.2 metadata refresh.


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'pgclone') THEN
        RAISE EXCEPTION 'pgext.extension row pgclone does not exist';
    END IF;
END
$$;

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
 WHERE name = 'pgclone'
 RETURNING id, name, version, rpm_ver, deb_ver, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'pgclone'
           AND version = '4.4.2'
           AND rpm_ver = '4.4.2'
           AND deb_ver = '4.4.2'
    ) THEN
        RAISE EXCEPTION 'pgclone metadata verification failed';
    END IF;
END
$$;


--------------------------------------------------------------------------------
-- 06_update_pgbson.sql
--------------------------------------------------------------------------------
-- PGXN bson distribution / CREATE EXTENSION pgbson 2.0.4 metadata refresh.


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


--------------------------------------------------------------------------------
-- 07_update_pgmq.sql
--------------------------------------------------------------------------------
-- pgmq 1.12.0 metadata refresh.


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'pgmq') THEN
        RAISE EXCEPTION 'pgext.extension row pgmq does not exist';
    END IF;
END
$$;

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
 WHERE name = 'pgmq'
 RETURNING id, name, version, rpm_ver, deb_ver, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'pgmq'
           AND version = '1.12.0'
           AND rpm_ver = '1.12.0'
           AND deb_ver = '1.12.0'
    ) THEN
        RAISE EXCEPTION 'pgmq metadata verification failed';
    END IF;
END
$$;


--------------------------------------------------------------------------------
-- 08_update_powa.sql
--------------------------------------------------------------------------------
-- powa 5.2.0 upstream metadata refresh; packaged PGDG versions stay unchanged.


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


--------------------------------------------------------------------------------
-- 09_update_pgmnemo.sql
--------------------------------------------------------------------------------
-- pgmnemo 0.13.0 metadata refresh and PostgreSQL support-range correction.


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


--------------------------------------------------------------------------------
-- 10_update_biscuit.sql
--------------------------------------------------------------------------------
-- Biscuit 2.4.3 stable package metadata refresh.


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'biscuit') THEN
        RAISE EXCEPTION 'pgext.extension row biscuit does not exist';
    END IF;
END
$$;

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
 WHERE name = 'biscuit'
 RETURNING id, name, version, rpm_pkg, deb_pkg, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'biscuit'
           AND version = '2.4.3'
           AND rpm_ver = '2.4.3'
           AND deb_ver = '2.4.3'
           AND source = 'Biscuit-2.4.3.tar.gz'
    ) THEN
        RAISE EXCEPTION 'biscuit metadata verification failed';
    END IF;
END
$$;


--------------------------------------------------------------------------------
-- 11_update_re2.sql
--------------------------------------------------------------------------------
-- re2 0.4.1 metadata refresh.


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 're2') THEN
        RAISE EXCEPTION 'pgext.extension row re2 does not exist';
    END IF;
END
$$;

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
 WHERE name = 're2'
 RETURNING id, name, version, pg_ver, rpm_ver, deb_ver, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 're2'
           AND version = '0.4.1'
           AND pg_ver = ARRAY['18', '17', '16']
           AND rpm_ver = '0.4.1'
           AND deb_ver = '0.4.1'
    ) THEN
        RAISE EXCEPTION 're2 metadata verification failed';
    END IF;
END
$$;


--------------------------------------------------------------------------------
-- 12_update_vector.sql
--------------------------------------------------------------------------------
-- vector / pgvector 0.8.5: PGDG RPM with PIGSTY DEB packaging.


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'vector') THEN
        RAISE EXCEPTION 'pgext.extension row vector does not exist';
    END IF;
END
$$;

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
 WHERE name = 'vector'
 RETURNING id, name, version, repo, rpm_ver, rpm_repo, deb_ver, deb_repo;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'vector'
           AND version = '0.8.5'
           AND repo = 'MIXED'
           AND rpm_repo = 'PGDG'
           AND deb_repo = 'PIGSTY'
           AND source = 'pgvector-0.8.5.tar.gz'
    ) THEN
        RAISE EXCEPTION 'vector metadata verification failed';
    END IF;
END
$$;


--------------------------------------------------------------------------------
-- 13_update_nominatim_fdw.sql
--------------------------------------------------------------------------------
-- nominatim_fdw 2.0.0 metadata refresh from mixed PGDG/PIGSTY versions.


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'nominatim_fdw') THEN
        RAISE EXCEPTION 'pgext.extension row nominatim_fdw does not exist';
    END IF;
END
$$;

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
 WHERE name = 'nominatim_fdw'
 RETURNING id, name, version, repo, rpm_ver, deb_ver, source;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'nominatim_fdw'
           AND version = '2.0.0'
           AND repo = 'PIGSTY'
           AND rpm_repo = 'PIGSTY'
           AND deb_repo = 'PIGSTY'
    ) THEN
        RAISE EXCEPTION 'nominatim_fdw metadata verification failed';
    END IF;
END
$$;


--------------------------------------------------------------------------------
-- 14_update_pg_kazsearch.sql
--------------------------------------------------------------------------------
-- pg_kazsearch 2.3.0 metadata and pgrx toolchain refresh.


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pgext.extension WHERE name = 'pg_kazsearch') THEN
        RAISE EXCEPTION 'pgext.extension row pg_kazsearch does not exist';
    END IF;
END
$$;

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
 WHERE name = 'pg_kazsearch'
 RETURNING id, name, version, pg_ver, rpm_ver, deb_ver, extra ->> 'pgrx' AS pgrx;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pgext.extension
         WHERE name = 'pg_kazsearch'
           AND version = '2.3.0'
           AND pg_ver = ARRAY['18', '17', '16']
           AND extra ->> 'pgrx' = '0.19.1'
    ) THEN
        RAISE EXCEPTION 'pg_kazsearch metadata verification failed';
    END IF;
END
$$;


--------------------------------------------------------------------------------
-- 15_insert_fbsql.sql
--------------------------------------------------------------------------------
-- Add or fully recalibrate fbsql 0.1.0 metadata.


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


--------------------------------------------------------------------------------
-- 16_insert_pgsqlmock.sql
--------------------------------------------------------------------------------
-- Add or fully recalibrate pgsqlmock 1.0.1 metadata.


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


--------------------------------------------------------------------------------
-- 17_insert_pg_fts.sql
--------------------------------------------------------------------------------
-- Add or fully recalibrate pg_fts 0.2.0 metadata.


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


--------------------------------------------------------------------------------
-- 18_insert_cron_utils.sql
--------------------------------------------------------------------------------
-- Add or fully recalibrate cron_utils 0.1.0 metadata.


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


--------------------------------------------------------------------------------
-- 19_insert_pg_tiktoken_c.sql
--------------------------------------------------------------------------------
-- Add or fully recalibrate pg_tiktoken_c 1.1 metadata.
-- The user-facing shorthand pg_tiktok_c is normalized to the actual extension
-- and package name pg_tiktoken_c used by the control file and both package sets.


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


--------------------------------------------------------------------------------
-- Final calibrated metadata
--------------------------------------------------------------------------------
SELECT id, name, category, version, repo,
       pg_ver, requires,
       rpm_ver, rpm_repo, rpm_pkg, rpm_pg, rpm_deps,
       deb_ver, deb_repo, deb_pkg, deb_pg, deb_deps
  FROM pgext.extension
 WHERE name = ANY (ARRAY[
     'provsql', 'plpgsql_check', 'pg_search', 'plproxy',
     'pgclone', 'pgbson', 'pgmq', 'powa', 'pgmnemo',
     'biscuit', 're2', 'vector', 'nominatim_fdw', 'pg_kazsearch',
     'fbsql', 'pgsqlmock', 'pg_fts', 'cron_utils', 'pg_tiktoken_c'
 ])
 ORDER BY id;

COMMIT;
