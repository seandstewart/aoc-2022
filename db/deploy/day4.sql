-- Deploy aoc-2022:day4 to pg
-- requires: aocschema

BEGIN;

-- region: schema

CREATE TABLE IF NOT EXISTS aoc.assignment_list(
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at timestamptz NOT NULL DEFAULT current_timestamp
);

CREATE TABLE IF NOT EXISTS aoc.section_assignment(
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    assignment_list_id BIGINT REFERENCES aoc.assignment_list(id) NOT NULL,
    assignment_one int8range NOT NULL,
    assignment_two int8range NOT NULL,
    created_at timestamptz NOT NULL DEFAULT current_timestamp
);

CREATE INDEX idx_section_assignments_sections
    ON aoc.section_assignment USING gist (assignment_one, assignment_two);

-- endregion
-- region: logic
CREATE OR REPLACE FUNCTION aoc.save_assignments("assignments" text)
RETURNS BIGINT AS $$
    WITH new_assignment_list AS (
        INSERT INTO aoc.assignment_list DEFAULT VALUES RETURNING *
    ), assignment_pairs AS (
        SELECT
            p.number,
            array_agg(int8range(section[1], section[2], '[]'))::int8range[] as pair
        FROM (
            SELECT
                number,
                regexp_split_to_array(section, E'-')::bigint[] as section
            FROM (
                SELECT
                    row_number() over (order by tb) as number,
                    regexp_split_to_table(tb, E',') as section
                FROM regexp_split_to_table($1, E'\\s+') as tb
                WHERE length(tb) > 0
            ) as parsed
        ) p
        GROUP BY 1
    ), new_assignments AS (
        INSERT INTO aoc.section_assignment (assignment_list_id, assignment_one, assignment_two)
        SELECT
            nal.id as assignment_list_id,
            pair[1] as assignment_one,
            pair[2] as assignment_two
        FROM assignment_pairs ap, lateral (
            SELECT id FROM new_assignment_list LIMIT 1
        ) nal
        RETURNING *
    )
    SELECT assignment_list_id FROM new_assignments LIMIT 1
$$ LANGUAGE sql;

DROP TYPE IF EXISTS aoc.assignment_report;
CREATE TYPE aoc.assignment_report AS (
    assignment_list_id BIGINT,
    number_overlapping BIGINT,
    overlapping_assignments aoc.section_assignment[]
);

CREATE OR REPLACE FUNCTION aoc.calculate_overlapping_assignments_by_pair_containment(
    "assignment_list_id" BIGINT
) RETURNS aoc.assignment_report AS $$
    SELECT
        sa.assignment_list_id,
        count(*) AS number_overlapping,
        array_agg(sa) as overlapping_assignments
    FROM aoc.section_assignment sa
    WHERE
        sa.assignment_list_id = $1
        AND (
            sa.assignment_one @> assignment_two
            OR sa.assignment_two @> sa.assignment_one
        )
    GROUP BY 1
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION aoc.calculate_overlapping_assignments_by_pair(
    "assignment_list_id" BIGINT
) RETURNS aoc.assignment_report AS $$
    SELECT
        sa.assignment_list_id,
        count(*) AS number_overlapping,
        array_agg(sa) as overlapping_assignments
    FROM aoc.section_assignment sa
    WHERE
        sa.assignment_list_id = $1
        AND sa.assignment_one && assignment_two
    GROUP BY 1
$$ LANGUAGE sql;

COMMIT;
