#!/usr/bin/env python
from __future__ import annotations

from typing import TypedDict

from yesql import support

from src import read
from src.repository import repository


def parse() -> list[MoveSet]:
    data = read.get_input(2)
    return [
        dict(left_move=row[0], right_move=row[1])
        for line
        in data.splitlines()
        if (row := line.split())
    ]

def solve() -> tuple[int, int, int]:
    tournaments = repository.TournamentRepository()
    with tournaments.executor.transaction(rollback=True) as conn:
        tourney = parse()
        tourney_id = tournaments.save_tournament(moves=support.dumps(tourney), connection=conn)
        outcome = tournaments.calculate_tournament_outcome(tournament_id=tourney_id, connection=conn)
        return outcome


class MoveSet(TypedDict):
    left_move: str
    right_move: str


if __name__ == '__main__':
    id, left, right = solve()
    print(right)
