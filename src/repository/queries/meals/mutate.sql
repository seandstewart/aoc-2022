-- :name persist_meals :many
INSERT INTO aoc.meals (calories, elf_id)
SELECT
    nm.calories,
    nm.elf_id
FROM jsonb_populate_recordset(null::aoc.meals, :meals::jsonb) nm
ON CONFLICT DO NOTHING
RETURNING *;
