-- Deploy aoc-2022:day3 to pg
-- requires: aocschema

BEGIN;

-- region: schema

CREATE TABLE IF NOT EXISTS aoc.inventory (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS aoc.rucksack (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    inventory_id BIGINT REFERENCES aoc.inventory(id) ON DELETE CASCADE NOT NULL,
    raw TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uidx_rucksack_inventory_raw ON aoc.rucksack(inventory_id, raw);

CREATE TABLE IF NOT EXISTS aoc.compartment (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    rucksack_id BIGINT REFERENCES aoc.rucksack(id) ON DELETE CASCADE NOT NULL,
    raw TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uidx_compartment_rucksack_raw ON aoc.compartment(rucksack_id, raw);

CREATE TABLE IF NOT EXISTS aoc.item (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    item_type TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uidx_item_type ON aoc.item(item_type);

CREATE TABLE IF NOT EXISTS aoc.compartment_item (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    item_id BIGINT REFERENCES aoc.item(id) ON DELETE CASCADE NOT NULL,
    compartment_id BIGINT REFERENCES aoc.compartment(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- endregion
-- region: configuration

INSERT INTO aoc.item(item_type)
SELECT regexp_split_to_table(
    'abcdefghijklmnopqrstuvwxyz' ||
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    ''
) as item_type
ON CONFLICT (item_type) DO NOTHING;

-- endregion
-- region: logic

CREATE OR REPLACE FUNCTION string_nchars("string" text, "length" integer)
RETURNS SETOF TEXT AS $$
    SELECT substring(
        $1 from n for $2
    ) FROM generate_series(
        1, length($1), $2
    ) n;
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION aoc.save_inventory("rucksacks" text) RETURNS BIGINT AS $$
    WITH new_inventory AS (
        INSERT INTO aoc.inventory DEFAULT VALUES RETURNING *
    ), new_rucksacks AS (
        INSERT INTO aoc.rucksack (inventory_id, raw)
        SELECT
            ni.id as inventory_id,
            raw
        FROM
            regexp_split_to_table(
                rucksacks, E'\\s+'
            ) as raw, LATERAL ( SELECT id FROM new_inventory ) ni
        WHERE length(raw) > 0
        RETURNING *
    ), new_compartments AS (
        INSERT INTO aoc.compartment (rucksack_id, raw)
        SELECT DISTINCT
            nr.id as rucksack_id,
            string_nchars(
                string => nr.raw, length => length(nr.raw) / 2
            ) as raw
        FROM new_rucksacks nr
        ON CONFLICT (rucksack_id, raw)
        DO UPDATE SET
            rucksack_id=excluded.rucksack_id,
            raw=excluded.raw
        RETURNING *
    ), new_compartment_items AS (
        INSERT INTO aoc.compartment_item (item_id, compartment_id)
        SELECT
            item.id as item_id,
            nci.id as compartment_id
        FROM (
            SELECT
                nc.id,
                regexp_split_to_table(nc.raw, '') as item_type
            FROM new_compartments nc
        ) nci
        INNER JOIN aoc.item ON nci.item_type = item.item_type
    )
    SELECT id FROM new_inventory;
$$ LANGUAGE sql;

DROP TYPE IF EXISTS aoc.inventory_report;
CREATE TYPE aoc.inventory_report AS (
    inventory_id BIGINT,
    overlap_magnitude BIGINT,
    overlap_items text[]
);

CREATE OR REPLACE FUNCTION aoc.calculate_overlap_magnitude("inventory_id" bigint)
RETURNS aoc.inventory_report AS $$
    WITH compartment_items AS (
        SELECT
            r.inventory_id,
            c.rucksack_id,
            ci.compartment_id,
            ci.item_id
        FROM aoc.rucksack r
        INNER JOIN aoc.compartment c on r.id = c.rucksack_id
        INNER JOIN aoc.compartment_item ci on c.id = ci.compartment_id
        WHERE r.inventory_id = $1
    )
    SELECT
        cir.inventory_id,
        sum(DISTINCT oi.item_id) as overlap_magnitude,
        array_agg(DISTINCT i.item_type ORDER BY i.item_type) as overlap_items
    FROM compartment_items cir, LATERAL (
        SELECT DISTINCT item_id
        FROM compartment_items _ci1
        WHERE
            _ci1.rucksack_id = cir.rucksack_id
            AND _ci1.compartment_id != cir.compartment_id
            AND _ci1.item_id = cir.item_id
        LIMIT 1
        ) oi
    INNER JOIN aoc.item i ON oi.item_id = i.id
    GROUP BY 1
    LIMIT 1
$$ LANGUAGE sql;


COMMIT;
