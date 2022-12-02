-- :name persist_elves :many
INSERT INTO aoc.elves (id, created_at)
SELECT DISTINCT ON (ne.id)
    ne.id,
    coalesce(ne.created_at, current_timestamp)
FROM jsonb_populate_recordset(null::aoc.elves, :elves::jsonb) ne
ON CONFLICT DO NOTHING
RETURNING *;
