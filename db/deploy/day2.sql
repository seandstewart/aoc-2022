-- Deploy aoc-2022:rock-paper-scissors to pg
-- requires: aocschema

BEGIN;

-- region: schema

CREATE TABLE IF NOT EXISTS aoc.shape (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL,
    point_value BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp
);

CREATE UNIQUE INDEX IF NOT EXISTS uidx_shapes_name ON aoc.shape(name);

CREATE TABLE IF NOT EXISTS aoc.outcome (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL,
    point_value BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp
);

CREATE UNIQUE INDEX IF NOT EXISTS uidx_outcomes_name ON aoc.outcome(name);

CREATE TABLE IF NOT EXISTS aoc.shape_outcome (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    left_shape_id BIGINT REFERENCES aoc.shape(id) ON DELETE CASCADE NOT NULL,
    right_shape_id BIGINT REFERENCES aoc.shape(id) ON DELETE CASCADE NOT NULL,
    outcome_id BIGINT REFERENCES aoc.outcome(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp
);

CREATE UNIQUE INDEX uidx_shape_outcome ON aoc.shape_outcome(left_shape_id, right_shape_id, outcome_id);

CREATE TABLE IF NOT EXISTS aoc.shape_alias (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    alias TEXT NOT NULL,
    shape_id BIGINT REFERENCES aoc.shape(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp
);

CREATE UNIQUE INDEX IF NOT EXISTS uidx_shapes_aliases_alias ON aoc.shape_alias(alias);


CREATE TABLE IF NOT EXISTS aoc.tournament (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp
);

CREATE TABLE IF NOT EXISTS aoc.game (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tournament_id BIGINT REFERENCES aoc.tournament(id) ON DELETE CASCADE NOT NULL,
    left_shape_id BIGINT REFERENCES aoc.shape(id) ON DELETE CASCADE NOT NULL,
    right_shape_id BIGINT REFERENCES aoc.shape(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT current_timestamp
);

-- endregion
-- region: functions


CREATE type aoc.new_move AS (
    left_move TEXT,
    right_move TEXT
);


CREATE OR REPLACE FUNCTION aoc.save_tournament(
    "moves" aoc.new_move[]
) RETURNS BIGINT AS $$
    WITH resolved_moves_shapes AS (
        SELECT
            lsa.shape_id as left_shape_id,
            rsa.shape_id as right_shape_id
        FROM unnest($1) AS m
        INNER JOIN aoc.shape_alias lsa
            ON lsa.alias = m.left_move
        INNER JOIN aoc.shape_alias rsa
            ON rsa.alias = m.right_move
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

CREATE TYPE aoc.tournament_outcome AS (
    tournament_id BIGINT, elf_score BIGINT, player_score BIGINT
);

CREATE OR REPLACE FUNCTION aoc.calculate_tournament_outcome("tournament_id" BIGINT)
RETURNS aoc.tournament_outcome AS $$
    SELECT
        g.tournament_id,
        sum(oe.point_value + ls.point_value) as elf_score,
        sum(op.point_value + rs.point_value) as player_score
    FROM aoc.game g
    INNER JOIN aoc.shape ls ON ls.id = g.left_shape_id
    INNER JOIN aoc.shape rs ON rs.id = g.right_shape_id
    INNER JOIN aoc.shape_outcome sop
        ON sop.right_shape_id = g.right_shape_id
        AND sop.left_shape_id = g.left_shape_id
    INNER JOIN aoc.outcome op ON sop.outcome_id = op.id
    INNER JOIN aoc.shape_outcome soe
        ON soe.left_shape_id = g.right_shape_id
        AND soe.right_shape_id = g.left_shape_id
    INNER JOIN aoc.outcome oe ON soe.outcome_id = oe.id
    WHERE g.tournament_id = $1
    GROUP BY 1
$$ LANGUAGE sql;

-- endregion
-- region: configuration


INSERT INTO aoc.shape (name, point_value)
VALUES
    ('rock'::text, 1::bigint),
    ('paper'::text, 2::bigint),
    ('scissors'::text, 3::bigint)
ON CONFLICT (name) DO UPDATE SET point_value = excluded.point_value;


WITH alias_to_name AS (
    SELECT alias::text, shape_name::text FROM unnest(
        ARRAY [
            ('A'::text, 'rock'::text),
            ('B'::text, 'paper'::text),
            ('C'::text, 'scissors'::text),
            ('X'::text, 'rock'::text),
            ('Y'::text, 'paper'::text),
            ('Z'::text, 'scissors'::text)
        ]
    ) AS t(alias text, shape_name text)
)
INSERT INTO aoc.shape_alias (alias, shape_id)
SELECT
    alias,
    id AS shape_id
FROM alias_to_name an
INNER JOIN aoc.shape s ON s.name = an.shape_name
ON CONFLICT (alias) DO UPDATE SET shape_id = excluded.shape_id
;


INSERT INTO aoc.outcome(name, point_value)
VALUES
    ('win'::text, 6::bigint),
    ('draw'::text, 3::bigint),
    ('lose'::text, 0::bigint)
ON CONFLICT (name) DO UPDATE SET point_value = excluded.point_value
;

WITH move_to_outcome_name AS (
    SELECT left_shape_name::text, right_shape_name::text, outcome_name::text
    FROM unnest(
        ARRAY [
            ('rock'::text, 'paper'::text, 'win'::text),
            ('rock'::text, 'rock'::text, 'draw'::text),
            ('rock'::text, 'scissors'::text, 'lose'::text),
            ('paper'::text, 'scissors'::text, 'win'::text),
            ('paper'::text, 'paper'::text, 'draw'::text),
            ('paper'::text, 'rock'::text, 'lose'::text),
            ('scissors'::text, 'rock'::text, 'win'::text),
            ('scissors'::text, 'scissors'::text, 'draw'::text),
            ('scissors'::text, 'paper'::text, 'lose'::text)
        ]
    ) AS mo(left_shape_name text, right_shape_name text, outcome_name text)
)
INSERT INTO aoc.shape_outcome (left_shape_id, right_shape_id, outcome_id)
SELECT
    ls.id AS left_shape_id,
    rs.id AS right_shape_id,
    o.id AS outcome_id
FROM move_to_outcome_name mo
INNER JOIN aoc.shape rs on rs.name = mo.right_shape_name
INNER JOIN aoc.shape ls on ls.name = mo.left_shape_name
INNER JOIN aoc.outcome o on o.name = mo.outcome_name
ON CONFLICT DO NOTHING
;

-- endregion

COMMIT;
