-- Verify aoc-2022:day1 on pg

BEGIN;

SELECT id, created_at from aoc.elves limit 1;
SELECT id, created_at, calories, elf_id from aoc.meals limit 1;

ROLLBACK;
