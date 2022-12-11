-- :name save_containers :scalar
SELECT * FROM aoc.save_container_locations(
    new_locations => ARRAY (
        SELECT jsonb_populate_recordset(
            null::aoc.new_container_location, :containers::jsonb
        )
    )
);

-- :name save_container_move_set :scalar
SELECT * FROM aoc.save_container_moves(
    new_moves => ARRAY (
        SELECT jsonb_populate_recordset(
            null::aoc.new_container_move,
            :moves::jsonb
        )
    )
);


-- :name move_containers :many
SELECT * FROM aoc.run_container_move_set(move_set_id => :move_set_id::bigint);
