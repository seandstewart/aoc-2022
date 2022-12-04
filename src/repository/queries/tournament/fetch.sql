-- :name calculate_tournament_outcome :one
SELECT * FROM aoc.calculate_tournament_outcome(tournament_id => :tournament_id::bigint);
