-- :name all :many
SELECT * FROM aoc.meals;

-- :name get_elf_with_max_calories :one
SELECT m.elf_id, sum(m.calories)
FROM aoc.meals m
GROUP BY 1 ORDER BY 2 DESC LIMIT 1;

-- :name get_total_calories_for_top_three :scalar
WITH top_three as (
    SELECT m.elf_id, sum(m.calories) as calories
    FROM aoc.meals m
    GROUP BY 1 ORDER BY 2 DESC LIMIT 3
)
SELECT sum(top_three.calories) as total
FROM top_three;
