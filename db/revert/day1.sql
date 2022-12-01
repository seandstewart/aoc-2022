-- Revert aoc-2022:day1 from pg

BEGIN;

DROP TABLE IF EXISTS aoc.elves CASCADE;
DROP TABLE IF EXISTS aoc.meals CASCADE;

COMMIT;
