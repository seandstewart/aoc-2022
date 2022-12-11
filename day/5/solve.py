#!/usr/bin/env python
from __future__ import annotations

import csv
import re
from typing import TypedDict

from yesql import support

from src import read
from src.repository import repository


def parse() -> tuple[list[Container], list[Move]]:
    input = read.get_input(5)
    map_text, moves_text = input.split("\n\n")
    map_text_array = map_text.splitlines()
    stacks = [s for s in map_text_array[-1].split() if s]
    locs = [*range(1, len(map_text_array[0]) + 1, 4)]
    stacks_by_locs = dict(zip(locs, stacks))
    container_entries = [*reversed(map_text_array[:-1])]
    containers = [
        dict(name=cname, stack_number=int(stack), stack_position=pos)
        for pos, entry in enumerate(container_entries, start=1)
        for loc, stack in stacks_by_locs.items()
        if (cname := entry[loc].strip())
    ]

    move_pattern = re.compile(
        r"move\s(?P<number_containers>\d+)\sfrom\s(?P<from_stack_number>\d+)\sto\s(?P<to_stack_number>\d+)")
    moves = [
        match.groupdict()
        for m in moves_text.splitlines()
        if (match := move_pattern.match(m))
    ]
    return containers, moves


class Container(TypedDict):
    name: str
    stack_number: int
    stack_position: int


class Move(TypedDict):
    number_containers: str
    from_stack_number: str
    to_stack_number: str


def solve():
    containers, moves = parse()
    repo = repository.ContainerRepository()
    with repo.executor.transaction(rollback=True) as connection:
        num_saved = repo.save_containers(
            containers=support.dumps(containers), connection=connection
        )
        move_set_id = repo.save_container_move_set(
            moves=support.dumps(moves), connection=connection
        )
        reports = repo.move_containers(move_set_id=move_set_id, connection=connection)
        return "".join(r.top_container_name for r in reports)


if __name__ == "__main__":
    print(solve())
