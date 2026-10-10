# pg_grammar_guard 0.4.9

Source: [official v0.4.9 tag archive](https://codeload.github.com/Manuelreyesbravo/pg_grammar_guard/tar.gz/refs/tags/v0.4.9).
The official archive is used unchanged.
SHA256: `93e186a185aa1dec59ed84ad3421ce2019454511b280c7d131608e4b7693f392`.
License: Apache-2.0.

PostgreSQL targets: 14, 15, 16, 17, 18.

pg_grammar_guard builds GBNF grammars and JSON Schema from PostgreSQL
catalog identifiers and detects changes to approved grammar definitions.
It requires pg_living_assertions 0.5.9 or later to store and check approved baselines.
Constraining identifiers does not establish query semantic correctness.
