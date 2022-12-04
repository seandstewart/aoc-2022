-- :name save_tournament :scalar
WITH new_moves AS (
    SELECT * FROM jsonb_populate_recordset(null::aoc.new_move, :moves::jsonb)
)
SELECT aoc.save_tournament(
    moves => array_agg((nm.*)::aoc.new_move)::aoc.new_move[]
) FROM new_moves nm;
