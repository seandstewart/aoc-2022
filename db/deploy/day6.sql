-- Deploy aoc-2022:day6 to pg
-- requires: aocschema

BEGIN;

-- region: schema

CREATE TABLE IF NOT EXISTS aoc.stream (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at timestamptz NOT NULL DEFAULT current_timestamp
);

CREATE TABLE IF NOT EXISTS aoc.stream_entry (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    stream_id BIGINT REFERENCES aoc.stream(id),
    index BIGINT NOT NULL,
    entry CHAR(1) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT current_timestamp
);

CREATE UNIQUE INDEX uidx_stream_entry_index_character
    ON aoc.stream_entry (stream_id, index, entry);

-- endregion
-- region: logic

CREATE OR REPLACE FUNCTION aoc.save_stream("data" TEXT) RETURNS BIGINT AS $$
    WITH
        new_stream AS (INSERT INTO aoc.stream DEFAULT VALUES RETURNING *),
        new_entries AS (
            INSERT INTO aoc.stream_entry(stream_id, index, entry)
            SELECT
            s.id as stream_id,
            parsed.index,
            parsed.entry
            FROM (
                SELECT
                generate_series(1, length(data)) as index,
                regexp_split_to_table(data, E'') as entry
            ) parsed, LATERAL ( SELECT id FROM new_stream LIMIT 1 ) s
            RETURNING *
        )
    SELECT new_entries.stream_id FROM new_entries LIMIT 1
$$ LANGUAGE sql;

DROP TYPE IF EXISTS aoc.stream_data;
CREATE TYPE aoc.stream_data AS (
    stream_id BIGINT,
    marker_index BIGINT,
    data TEXT
);

CREATE OR REPLACE FUNCTION aoc.locate_data_start_marker_for_stream(
    "stream_id" BIGINT, "min_index" BIGINT
) RETURNS aoc.stream_data AS $$
    SELECT
        se.stream_id,
        se.index as marker_index,
        p.data
    FROM aoc.stream_entry se, LATERAL (
        SELECT
            se2.stream_id,
            string_agg(se2.entry::text, ''::text ORDER BY se2.index) as data
        FROM aoc.stream_entry se2
        WHERE se2.stream_id = se.stream_id
        AND se2.index BETWEEN SYMMETRIC se.index - $2 AND se.index
        GROUP BY 1
        HAVING array_agg(DISTINCT se2.entry ORDER BY se2.entry) = array_agg(se2.entry ORDER BY se2.entry)
    ) p
    WHERE se.stream_id = $1
    AND se.index > $2
    ORDER BY se.index
    LIMIT 1
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION aoc.locate_packet_start_marker_for_stream(
    "stream_id" BIGINT
) RETURNS aoc.stream_data AS $$
    SELECT * FROM aoc.locate_data_start_marker_for_stream(
        stream_id => stream_id, min_index => 3
    )
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION aoc.locate_message_start_marker_for_stream(
    "stream_id" BIGINT
) RETURNS aoc.stream_data AS $$
    SELECT * FROM aoc.locate_data_start_marker_for_stream(
        stream_id => stream_id, min_index => 13
    )
$$ LANGUAGE sql;

COMMIT;
