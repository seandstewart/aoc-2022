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
            row_number() over (order by ni.id) as number,
            raw
        FROM regexp_split_to_table(rucksacks, E'\\s+') as raw,
           LATERAL ( SELECT id FROM new_inventory ) ni
        WHERE length(raw) > 0
    ),
        groupings AS (
        SELECT
            row_number() over (order by ng.group_rucksacks) as group_number,
            ng.inventory_id,
            ng.group_rucksacks
        FROM (
            SELECT
                pr.inventory_id,
                array_agg(pr.raw) as group_rucksacks
            FROM parsed_rucksacks pr
            GROUP BY 1, (pr.number - 1 / 3)
            ORDER BY 1, (pr.number - 1 / 3)
        ) as ng
    ), new_groups AS (
        INSERT INTO aoc.inventory_group(number, inventory_id)
        SELECT
            g.group_number,
            g.inventory_id
        FROM groupings g
        RETURNING *
    ), new_rucksacks AS (
        INSERT INTO aoc.rucksack (inventory_group_id, raw)
        SELECT
            nr.inventory_group_id,
            nr.raw
        FROM (
            SELECT
                ng.id as inventory_group_id,
                unnest(g.group_rucksacks) as raw
            FROM
             new_groups ng
                 INNER JOIN groupings g
             ON g.inventory_id = ng.inventory_id AND g.group_number = ng.number
             ) nr
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
    WITH compartments AS (
    SELECT DISTINCT
        ig.inventory_id,
        c.rucksack_id,
        ci.compartment_id
    FROM aoc.rucksack r
    INNER JOIN aoc.inventory_group ig on r.inventory_group_id = ig.id
    INNER JOIN aoc.compartment c on r.id = c.rucksack_id
    INNER JOIN aoc.compartment_item ci on c.id = ci.compartment_id
    WHERE ig.inventory_id = $1
    ORDER BY 1,2,3
), rucksacks AS (
    SELECT DISTINCT
        cr.inventory_id,
        cr.rucksack_id,
        oi.overlapping_items[1] as overlapping_item_id
    FROM compartments cr, LATERAL (
        SELECT
            cr.compartment_id,
            array(
                SELECT unnest(
                    array_agg(DISTINCT ci2.item_id) filter (
                        where
                        ci2.compartment_id = cr.compartment_id
                    )
                )
                INTERSECT
                SELECT unnest(
                    array_agg(DISTINCT ci2.item_id) filter (
                        where ci2.compartment_id != cr.compartment_id
                        and cr2.rucksack_id = cr.rucksack_id

                    )
                )
            ) as overlapping_items
        FROM aoc.compartment_item ci2
        INNER JOIN compartments cr2 ON ci2.compartment_id = cr2.compartment_id
        GROUP BY 1
    ) oi
)
SELECT rucksacks.inventory_id,
       sum(rucksacks.overlapping_item_id) as overlapping_magnitude,
       array_agg(distinct i.item_type order by i.item_type) as overlapping_items
FROM rucksacks
INNER JOIN aoc.item i on i.id = rucksacks.overlapping_item_id
GROUP BY 1
$$ LANGUAGE sql;


COMMIT;
