-- Revert aoc-2022:day5 from pg

BEGIN;

DROP FUNCTION IF EXISTS aoc.run_container_move_set;
DROP FUNCTION IF EXISTS aoc.get_top_container_per_stack;
DROP FUNCTION IF EXISTS aoc.move_container;
DROP FUNCTION IF EXISTS aoc.save_container_moves;
DROP FUNCTION IF EXISTS aoc.save_container_locations;
DROP TYPE IF EXISTS aoc.new_container_location;
DROP TYPE IF EXISTS aoc.new_container_move;
DROP TYPE IF EXISTS aoc.stack_report;
DROP TABLE IF EXISTS aoc.container_move CASCADE;
DROP TABLE IF EXISTS aoc.container_move_set CASCADE;
DROP TABLE IF EXISTS aoc.container_location CASCADE;
DROP TABLE IF EXISTS aoc.container CASCADE;
DROP FUNCTION IF EXISTS trigger_set_timestamp;

COMMIT;
