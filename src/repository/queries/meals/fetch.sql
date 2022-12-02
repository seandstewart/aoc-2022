-- :name get_elf_with_max_calories :one
SELECT m.elf_id, sum(m.calories)
FROM aoc.meals m
GROUP BY 1 ORDER BY 2 DESC LIMIT 1;
