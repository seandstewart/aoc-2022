-- Revert aoc-2022:day4 from pg

BEGIN;

DROP FUNCTION IF EXISTS aoc.save_assignments CASCADE;
DROP FUNCTION IF EXISTS aoc.calculate_overlapping_assignments_by_pair CASCADE;
DROP TYPE IF EXISTS aoc.assignment_report CASCADE;
DROP TABLE IF EXISTS aoc.section_assignment CASCADE;
DROP TABLE IF EXISTS aoc.assignment_list CASCADE;

COMMIT;
