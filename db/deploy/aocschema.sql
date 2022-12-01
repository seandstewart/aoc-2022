-- Deploy aoc-2022:aocschema to pg

BEGIN;

CREATE SCHEMA IF NOT EXISTS aoc;

COMMIT;
