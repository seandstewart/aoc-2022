#!/usr/bin/env python
from __future__ import annotations

from yesql import support

from src import read
from src.repository import repository


def parse() -> str:
    return read.get_input(6)


def solve():
    repo = repository.StreamRepository()
    with repo.executor.transaction(rollback=True) as c:
        stream_data = parse()
        stream_id = repo.save_stream(data=stream_data)
        first_packet = repo.locate_message_start_marker(stream_id=stream_id)
        return first_packet.marker_index


if __name__ == "__main__":
    print(solve())
