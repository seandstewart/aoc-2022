-- Deploy aoc-2022:day1 to pg
-- requires: aocschema

BEGIN;

CREATE TABLE aoc.elves (
    id BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    created_at timestamptz NOT NULL DEFAULT current_timestamp
);

CREATE TABLE aoc.meals (
    id BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    calories BIGINT NOT NULL,
    elf_id BIGINT REFERENCES aoc.elves (id) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT current_timestamp
);


COMMIT;
