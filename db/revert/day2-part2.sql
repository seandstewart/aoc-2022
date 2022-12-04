-- Revert aoc-2022:day2-part2 from pg

BEGIN;

DROP TABLE IF EXISTS aoc.outcome_alias CASCADE;
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

COMMIT;
