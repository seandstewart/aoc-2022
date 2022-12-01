-- Revert aoc-2022:aocschema from pg

BEGIN;

DROP SCHEMA IF EXISTS aoc CASCADE;

COMMIT;
