-- Revert aoc-2022:rock-paper-scissors from pg

BEGIN;

DROP FUNCTION IF EXISTS aoc.save_tournament CASCADE;
DROP FUNCTION IF EXISTS aoc.calculate_tournament_outcome CASCADE;
DROP TYPE IF EXISTS aoc.new_move CASCADE;
DROP TYPE IF EXISTS aoc.tournament_outcome;
DROP TABLE IF EXISTS aoc.shape_outcome;
DROP TABLE IF EXISTS aoc.shape_alias;
DROP TABLE IF EXISTS aoc.tournament CASCADE;
DROP TABLE IF EXISTS aoc.outcome CASCADE;
DROP TABLE IF EXISTS aoc.shape CASCADE;
DROP TABLE IF EXISTS aoc.game CASCADE;

COMMIT;
