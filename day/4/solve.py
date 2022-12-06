#!/usr/bin/env python
from __future__ import annotations

from src import read
from src.repository import repository


def parse() -> str:
    return read.get_input(4)


def solve():
    repo = repository.AssignmentRepository()
    with repo.executor.transaction(rollback=True) as c:
        assignments = parse()
        assignment_list_id = repo.save_assignments(
            assignments=assignments, connection=c
        )
        report = repo.calculate_overlapping_assignments(
            assignment_list_id=assignment_list_id, connection=c
        )
        return report.number_overlapping


if __name__ == "__main__":
    print(solve())
