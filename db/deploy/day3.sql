-- Deploy aoc-2022:day3 to pg
-- requires: aocschema

BEGIN;

-- region: schema

CREATE TABLE IF NOT EXISTS aoc.inventory (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS aoc.inventory_group(
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    number BIGINT NOT NULL,
    inventory_id BIGINT REFERENCES aoc.inventory(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uidx_inventory_group_number
    ON aoc.inventory_group(number, inventory_id);

CREATE TABLE IF NOT EXISTS aoc.rucksack (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    inventory_group_id BIGINT REFERENCES aoc.inventory_group(id)
        ON DELETE CASCADE NOT NULL,
    raw TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uidx_rucksack_inventory_raw
    ON aoc.rucksack(inventory_group_id, raw);

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
    ), parsed_rucksacks AS (
        SELECT
            ni.id as inventory_id,
            ((row_number() over (order by ni.id)) - 1) / 3 + 1 as group_number,
            raw
        FROM regexp_split_to_table(rucksacks, E'\\s+') as raw,
           LATERAL ( SELECT id FROM new_inventory ) ni
        WHERE length(raw) > 0
    ), new_groups AS (
        INSERT INTO aoc.inventory_group(number, inventory_id)
        SELECT DISTINCT
            pr.group_number,
            pr.inventory_id
        FROM parsed_rucksacks pr
        RETURNING *
    ), new_rucksacks AS (
        INSERT INTO aoc.rucksack (inventory_group_id, raw)
        SELECT
            ng.id as inventory_group_id,
            pr2.raw
        FROM parsed_rucksacks pr2
            INNER JOIN new_groups ng
            ON ng.inventory_id = pr2.inventory_id
            AND ng.number = pr2.group_number
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

CREATE OR REPLACE FUNCTION aoc.calculate_overlap_magnitude_by_compartment("inventory_id" bigint)
RETURNS aoc.inventory_report AS $$
    WITH items_by_rucksack AS (
        SELECT DISTINCT
            ig.inventory_id,
            c.rucksack_id,
            ci.compartment_id,
            ci.item_id,
            i.item_type
        FROM
            aoc.inventory_group ig
            INNER JOIN aoc.rucksack r on ig.id = r.inventory_group_id
            INNER JOIN aoc.compartment c on c.rucksack_id = r.id
            INNER JOIN aoc.compartment_item ci on c.id = ci.compartment_id
            INNER JOIN aoc.item i on ci.item_id = i.id
        WHERE ig.inventory_id = $1
    ), overlaps_by_compartment AS (
        SELECT DISTINCT
            ibr.inventory_id,
            ibr.rucksack_id,
            ibr.item_id,
            ibr.item_type
        FROM items_by_rucksack ibr
        INNER JOIN items_by_rucksack ibr2
            ON ibr2.item_id = ibr.item_id
            AND ibr2.rucksack_id = ibr.rucksack_id
            AND ibr2.compartment_id != ibr.compartment_id
    )
    SELECT
        obc.inventory_id,
        sum(obc.item_id) AS overlap_magnitude,
        array_agg(DISTINCT obc.item_type) AS overlap_items
    FROM overlaps_by_compartment obc
    GROUP BY 1

$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION aoc.calculate_overlap_magnitude_by_group(
    "inventory_id" bigint
) RETURNS aoc.inventory_report AS $$
    WITH items_by_rucksack AS (
        SELECT DISTINCT
            ig.inventory_id,
            r.inventory_group_id,
            c.rucksack_id,
            ci.item_id,
            i.item_type
        FROM
            aoc.inventory_group ig
            INNER JOIN aoc.rucksack r on ig.id = r.inventory_group_id
            INNER JOIN aoc.compartment c on c.rucksack_id = r.id
            INNER JOIN aoc.compartment_item ci on c.id = ci.compartment_id
            INNER JOIN aoc.item i on ci.item_id = i.id
        WHERE ig.inventory_id = $1
    ), overlaps_by_group AS (
        SELECT DISTINCT
            ibr.inventory_id,
            ibr.inventory_group_id,
            ibr.item_id,
            ibr.item_type
        FROM items_by_rucksack ibr
        INNER JOIN items_by_rucksack ibr2
            ON ibr2.item_id = ibr.item_id
            AND ibr2.inventory_group_id = ibr.inventory_group_id
            AND ibr2.rucksack_id != ibr.rucksack_id
        INNER JOIN items_by_rucksack ibr3
            ON ibr3.item_id = ibr.item_id
            AND ibr3.inventory_group_id = ibr.inventory_group_id
            AND ibr3.rucksack_id not in (ibr.rucksack_id, ibr2.rucksack_id)
    )
    SELECT
        obg.inventory_id,
        sum(obg.item_id) as overlap_magnitude,
        array_agg(distinct obg.item_type) as overlap_items
    FROM overlaps_by_group obg
    GROUP BY 1
$$ LANGUAGE sql;

COMMIT;
