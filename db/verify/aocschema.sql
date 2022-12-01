-- Verify aoc-2022:aocschema on pg

BEGIN;

SELECT has_schema_privilege('aoc', 'usage');

ROLLBACK;
