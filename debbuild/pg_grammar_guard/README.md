# pg_grammar_guard 0.4.1

Source: [https://api.pgxn.org/dist/pg_grammar_guard/0.4.1/pg_grammar_guard-0.4.1.zip](https://api.pgxn.org/dist/pg_grammar_guard/0.4.1/pg_grammar_guard-0.4.1.zip).
The PGXN ZIP is normalized to `pg_grammar_guard-0.4.1.tar.gz` with GNU tar,
sorted entries, epoch timestamps, numeric root ownership and `gzip -n9`.
The source content is unchanged. SHA256: `1e22c94f08fb237998d0873c8133c9f3da7ea12f1f5450b7776141858c14687f`.

PostgreSQL targets: 14, 15, 16, 17, 18.

pg_grammar_guard builds GBNF grammars and JSON Schema from PostgreSQL
catalog identifiers and detects changes to approved grammar definitions.
It uses pg_living_assertions to store and check approved baselines.
Constraining identifiers does not establish query semantic correctness.
