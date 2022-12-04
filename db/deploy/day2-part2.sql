-- Deploy aoc-2022:day2-part2 to pg
-- requires: day2

BEGIN;

-- region: schema updates....

CREATE TABLE IF NOT EXISTS aoc.outcome_alias (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    alias TEXT NOT NULL,
    outcome_id BIGINT REFERENCES aoc.outcome(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp
);

CREATE UNIQUE INDEX uidx_outcome_alias ON aoc.outcome_alias(alias);


CREATE OR REPLACE FUNCTION aoc.save_tournament(
    "moves" aoc.new_move[]
) RETURNS BIGINT AS $$
    WITH resolved_moves_shapes AS (
        SELECT
            lsa.shape_id as left_shape_id,
            so.right_shape_id as right_shape_id
        FROM unnest($1) AS m
        INNER JOIN aoc.shape_alias lsa
            ON lsa.alias = m.left_move
        INNER JOIN aoc.outcome_alias rsa
            ON rsa.alias = m.right_move
        INNER JOIN aoc.shape_outcome so
            ON so.outcome_id = rsa.outcome_id
            AND so.left_shape_id = lsa.shape_id
    ), new_tournament AS (
        INSERT INTO aoc.tournament DEFAULT VALUES RETURNING *
    ), games AS (
        INSERT INTO aoc.game (tournament_id, left_shape_id, right_shape_id)
            SELECT nt.id,
                   rms.left_shape_id,
                   rms.right_shape_id
            FROM resolved_moves_shapes rms,
                 LATERAL (
                     SELECT id FROM new_tournament
                     ) AS nt
            RETURNING *
        )
    SELECT new_tournament.id
    FROM new_tournament;
$$ LANGUAGE sql;

-- endregion
-- region: update configuration

DELETE FROM aoc.shape_alias WHERE alias = ANY(ARRAY ['X', 'Y', 'Z']);
WITH alias_to_name AS (
    SELECT alias::text, outcome_name::text FROM unnest(
        ARRAY [
            ('X'::text, 'lose'::text),
            ('Y'::text, 'draw'::text),
            ('Z'::text, 'win'::text)
        ]
    ) AS t(alias text, outcome_name text)
)
INSERT INTO aoc.outcome_alias (alias, outcome_id)
SELECT
    alias,
    id AS outcome_id
FROM alias_to_name an
INNER JOIN aoc.outcome s ON s.name = an.outcome_name
ON CONFLICT (alias) DO UPDATE SET outcome_id = excluded.outcome_id;


COMMIT;
