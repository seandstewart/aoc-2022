-- Revert aoc-2022:day6 from pg

BEGIN;

DROP FUNCTION IF EXISTS aoc.locate_packet_start_marker_for_stream CASCADE;
DROP FUNCTION IF EXISTS aoc.locate_message_start_marker_for_stream CASCADE;
DROP FUNCTION IF EXISTS aoc.locate_data_start_marker_for_stream CASCADE;
DROP FUNCTION IF EXISTS aoc.save_stream CASCADE;
DROP TYPE IF EXISTS aoc.stream_data CASCADE;
DROP TABLE IF EXISTS aoc.stream_entry CASCADE;
DROP TABLE IF EXISTS aoc.stream CASCADE;

COMMIT;
