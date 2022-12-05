-- Verify aoc-2022:day3 on pg

BEGIN;

DO $$
    DECLARE total BIGINT;
    DECLARE expected_total BIGINT;
    BEGIN
        -- Given
        expected_total := 52;
        -- When
        total := (SELECT count(*) FROM aoc.item);
        -- Then
        ASSERT total = expected_total, total::text || ' != ' || expected_total::text;
    END;
$$
;

DO $$
    DECLARE test_rucksacks TEXT;
    DECLARE test_inventory_id BIGINT;
    DECLARE expected_inventory_report aoc.inventory_report;
    DECLARE test_inventory_report aoc.inventory_report;
    BEGIN
        -- Given
        test_rucksacks :=
        'vJrwpWtwJgWrhcsFMMfFFhFp
        jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
        PmmdzqPrVvPwwTWBwg
        wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
        ttgJtRGJQctTZtZT
        CrZsJsPPZsGzwwsLwLmpwMDw'
        ;
        test_inventory_id := (
            SELECT aoc.save_inventory(rucksacks => test_rucksacks)
        );
        expected_inventory_report := (
            test_inventory_id,
            157,
            '{L,p,P,s,t,v}'::text[]
        );
        -- When
        test_inventory_report := (
            SELECT aoc.calculate_overlap_magnitude(inventory_id => test_inventory_id)
        );
        -- Then
        ASSERT test_inventory_report = expected_inventory_report,
            test_inventory_report::text
            || ' != '
            || expected_inventory_report::text
        ;


    END;

$$
;

ROLLBACK;
