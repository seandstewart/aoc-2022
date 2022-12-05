-- Revert aoc-2022:day3 from pg

BEGIN;

DROP FUNCTION IF EXISTS aoc.calculate_overlap_magnitude;
DROP FUNCTION IF EXISTS aoc.save_inventory;
DROP FUNCTION IF EXISTS public.string_nchars;
DROP TABLE IF EXISTS aoc.compartment_item CASCADE;
DROP TABLE IF EXISTS aoc.compartment CASCADE;
DROP TABLE IF EXISTS aoc.rucksack CASCADE;
DROP TABLE IF EXISTS aoc.inventory CASCADE;
DROP TABLE IF EXISTS aoc.item CASCADE;

COMMIT;
