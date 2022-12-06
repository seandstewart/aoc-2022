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
    DECLARE test_number_inventory_groups BIGINT;
    DECLARE expected_number_inventory_groups BIGINT;
    DECLARE expected_inventory_report_by_compartment aoc.inventory_report;
    DECLARE test_inventory_report_by_compartment aoc.inventory_report;
    DECLARE expected_inventory_report_by_group aoc.inventory_report;
    DECLARE test_inventory_report_by_group aoc.inventory_report;
    BEGIN
        -- Given
        test_rucksacks :=
        'vJrwpWtwJgWrhcsFMMfFFhFp
        jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
        PmmdzqPrVvPwwTWBwg
        wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
        ttgJtRGJQctTZtZT
        CrZsJsPPZsGzwwsLwLmpwMDw
        '
        ;
        test_inventory_id := (
            SELECT aoc.save_inventory(rucksacks => test_rucksacks)
        );

        expected_number_inventory_groups := 2;
        expected_inventory_report_by_compartment := (
            test_inventory_id,
            157,
            '{L,p,P,s,t,v}'::text[]
        );
        expected_inventory_report_by_group := (
            test_inventory_id,
            70,
            '{r,Z}'::text[]
        );
        -- When
        test_inventory_report_by_compartment := (
            SELECT aoc.calculate_overlap_magnitude_by_compartment(inventory_id => test_inventory_id)
        );
        test_inventory_report_by_group := (
            SELECT aoc.calculate_overlap_magnitude_by_group(inventory_id => test_inventory_id)
        );
        test_number_inventory_groups := (
            SELECT count(*)
            FROM aoc.inventory_group
            WHERE inventory_id = test_inventory_id
        );
        -- Then
        ASSERT test_number_inventory_groups = expected_number_inventory_groups,
            'Wrong number of groups: '
            || test_number_inventory_groups::text
            || ' != '
            || expected_number_inventory_groups::text
        ;
        ASSERT test_inventory_report_by_compartment = expected_inventory_report_by_compartment,
            test_inventory_report_by_compartment::text
            || ' != '
            || expected_inventory_report_by_compartment::text
        ;
        ASSERT test_inventory_report_by_group = expected_inventory_report_by_group,
            test_inventory_report_by_group::text
            || ' != '
            || expected_inventory_report_by_group::text
        ;


    END;

$$
;

ROLLBACK;
