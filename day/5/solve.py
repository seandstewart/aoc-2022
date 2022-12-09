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
    map_csv = reversed(
        re.sub(
            " ", "", re.sub(" {3}", ",", re.sub(r"([\[\]])+", " ", map_text))
        ).splitlines()
    )
    reader = csv.DictReader(map_csv)
    containers = [
        dict(stack=int(stack), name=name, position=i)
        for i, row in enumerate(reader, start=1)
        for stack, name in row.items()
    ]
    move_pattern = re.compile(
        r"move\s(?P<number>\d)\sfrom\s(?P<start>\d)\sto\s(?P<target>\d)")
    moves = [
        move_pattern.match(moves_text).groupdict()
        for m in moves_text.splitlines()
    ]
    return containers, moves


class Container(TypedDict):
    stack: int
    name: str
    position: int


class Move(TypedDict):
    number: str
    start: str
    target: str


def solve():
    ...


if __name__ == "__main__":
    print(solve())
