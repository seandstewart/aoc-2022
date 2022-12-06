-- :name calculate_overlap_magnitude :one
SELECT * FROM aoc.calculate_overlap_magnitude_by_group(
    inventory_id => :inventory_id::bigint
);
