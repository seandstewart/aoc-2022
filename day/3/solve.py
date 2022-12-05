#!/usr/bin/env python
from __future__ import annotations

from src import read
from src.repository import repository


def parse() -> str:
    return read.get_input(3)


def solve():
    inventories = repository.InventoryRepository()
    with inventories.executor.transaction(rollback=True) as conn:
        rucksacks = parse()
        inventory_id = inventories.save_inventory(
            rucksacks=rucksacks, connection=conn
        )
        report = inventories.calculate_overlap_magnitude(
            inventory_id=inventory_id, connection=conn
        )
        return report.overlap_magnitude


if __name__ == "__main__":
    print(solve())
