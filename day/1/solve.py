#!/usr/bin/env python
from __future__ import annotations

from yesql import support

from src import read
from src.repository import repository


def parse() -> dict[int, list[int]]:
    data = read.get_input(1)
    return {
        id: [int(c) for c in inp.splitlines()]
        for id, inp in enumerate(data.split("\n\n"), start=1)
    }


def solve() -> tuple[int, int]:
    elves = repository.ElvesRepository()
    meals = repository.MealsRepository(executor=elves.executor)
    with elves.executor.transaction(rollback=True) as conn:
        meal_log = parse()
        elves.persist_elves(
            elves=support.dumps([{"id": i} for i in meal_log.keys()]),
            connection=conn
        )
        meals_to_persist = [
            {"elf_id": id, "calories": c}
            for id, calories in meal_log.items()
            for c in calories
        ]
        meals.persist_meals(
            meals=support.dumps(meals_to_persist),
            connection=conn
        )
        max_cals = meals.get_elf_with_max_calories(connection=conn)
        top_three =  meals.get_total_calories_for_top_three(connection=conn)
        return max_cals, top_three


if __name__ == '__main__':
    max_cals, top_three = solve()
    print(max_cals)
    print(top_three)
