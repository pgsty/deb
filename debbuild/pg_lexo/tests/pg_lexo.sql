CREATE EXTENSION pg_lexo;
CREATE TABLE items (id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, title text NOT NULL, position lexo NOT NULL UNIQUE DEFERRABLE);
INSERT INTO items(title, position) VALUES ('first', lexo_first());
INSERT INTO items(title, position) SELECT 'last', lexo_after(position) FROM items ORDER BY position DESC LIMIT 1;
INSERT INTO items(title, position) VALUES ('middle', lexo_between('H'::lexo, 'I'::lexo));
DO $$ BEGIN
  ASSERT (SELECT array_agg(title ORDER BY position) FROM items) = ARRAY['first','middle','last'], 'documented workflow';
  ASSERT lexo_next('items','position',NULL,NULL) > 'I'::lexo, 'nonempty next';
  ASSERT lexo_before('H'::lexo) < 'H'::lexo;
  ASSERT lexo_between(NULL,NULL) = lexo_first();
END $$;
CREATE TABLE lexo_cases (position lexo, group_id text);
DO $$ BEGIN
  ASSERT lexo_next('lexo_cases','position',NULL,NULL) = lexo_first(), 'empty table';
END $$;
INSERT INTO lexo_cases VALUES (NULL,'n'), (NULL,'n');
DO $$ BEGIN
  ASSERT lexo_next('lexo_cases','position',NULL,NULL) = lexo_first(), 'all NULL';
END $$;
INSERT INTO lexo_cases VALUES ('Z','one'),('a','two'),('B','one');
DO $$ BEGIN
  ASSERT lexo_next('lexo_cases','position',NULL,NULL) = lexo_after('a'), 'native order and NULLS LAST';
  ASSERT lexo_next('lexo_cases','position','group_id','one') = lexo_after('Z'), 'group filter';
  ASSERT lexo_next('lexo_cases','position','group_id','absent') = lexo_first(), 'empty group';
  ASSERT lexo_next('lexo_cases','position','group_id','n') = lexo_first(), 'NULL group positions';
END $$;
CREATE SCHEMA "Odd Schema";
CREATE TABLE "Odd Schema"."Odd Table" ("Sort Key" lexo, "Group Key" text);
INSERT INTO "Odd Schema"."Odd Table" VALUES ('H','O''Reilly'),('Z','else');
DO $$ BEGIN
  ASSERT lexo_next('Odd Schema.Odd Table','Sort Key','Group Key','O''Reilly') = lexo_after('H'), 'quoted identifiers and literal';
END $$;
CREATE TABLE lexo_reorder (id text, position lexo);
INSERT INTO lexo_reorder VALUES ('a','a'),('Z','Z'),('B','B');
DO $$ BEGIN
  ASSERT lexo_rebalance('lexo_reorder','position',NULL,NULL) = 3;
  ASSERT (SELECT array_agg(id ORDER BY position) FROM lexo_reorder) = ARRAY['B','Z','a'], 'rebalance preserves native order under ICU';
  ASSERT lexo_rebalance('lexo_reorder','position','id','missing') = 0;
  ASSERT lexo_rebalance('lexo_reorder','position','id','a') = 1;
  ASSERT (SELECT position FROM lexo_reorder WHERE id='a') = lexo_first();
END $$;
CREATE TABLE lexo_add (id int);
SELECT lexo_add_column('lexo_add','sort key');
INSERT INTO lexo_add VALUES (1, lexo_first());
DO $$ BEGIN
  ASSERT (SELECT "sort key" FROM lexo_add WHERE id=1) = lexo_first();
END $$;
DO $$ BEGIN ASSERT (SELECT datlocprovider='i' FROM pg_database WHERE datname=current_database()), 'ICU test database'; END $$;
SELECT datcollate, datlocprovider FROM pg_database WHERE datname=current_database();
SELECT 'pg_lexo regression PASS';
