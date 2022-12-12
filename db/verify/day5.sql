-- Verify aoc-2022:day5 on pg

BEGIN;

/*
 Test that the iterative approach to movements produces the expected result.
 */
DO $$
    DECLARE given_container_locations aoc.new_container_location[];
    DECLARE given_container_moves aoc.new_container_move[];
    DECLARE test_move_set_id BIGINT;
    DECLARE test_saved_containers BIGINT;
    DECLARE test_stack_reports aoc.stack_report[];
    DECLARE expected_saved_containers BIGINT;
    DECLARE expected_stack_reports aoc.stack_report[];
    BEGIN
        -- Given
        given_container_locations := ARRAY [
            ('N', 1, 2),
            ('Z', 1, 1),
            ('D', 2, 3),
            ('C', 2, 2),
            ('M', 2, 1),
            ('P', 3, 1)
        ];
        given_container_moves := ARRAY [
            (1, 2, 1),
            (3, 1, 3),
            (2, 2, 1),
            (1, 1, 2)
        ];
        expected_saved_containers := 6;
        expected_stack_reports := ARRAY [
            (1, 1, 'C'),
            (2, 1, 'M'),
            (3, 4, 'Z')
        ];
        -- When
        test_saved_containers := (
            SELECT aoc.save_container_locations(
                new_locations => given_container_locations
            )
        );
        test_move_set_id := (
            SELECT aoc.save_container_moves(
                new_moves => given_container_moves
            )
        );
        test_stack_reports := (
            SELECT array_agg(cms) FROM aoc.run_container_move_set(
                move_set_id => test_move_set_id
            ) cms
        );
        -- Then
        ASSERT test_saved_containers = expected_saved_containers,
            test_saved_containers::text || ' != ' || expected_saved_containers::text;
        ASSERT test_stack_reports = expected_stack_reports,
            test_stack_reports::text || ' != ' || expected_stack_reports::text;
    END;
$$;

ROLLBACK;
BEGIN;

/*
 Test that the atomic approach to movements produces the expected result.
 */
DO $$
    DECLARE given_container_locations aoc.new_container_location[];
    DECLARE given_container_moves aoc.new_container_move[];
    DECLARE test_move_set_id BIGINT;
    DECLARE test_saved_containers BIGINT;
    DECLARE test_stack_reports aoc.stack_report[];
    DECLARE expected_saved_containers BIGINT;
    DECLARE expected_stack_reports aoc.stack_report[];
    BEGIN
        -- Given
        given_container_locations := ARRAY [
            ('N', 1, 2),
            ('Z', 1, 1),
            ('D', 2, 3),
            ('C', 2, 2),
            ('M', 2, 1),
            ('P', 3, 1)
        ];
        given_container_moves := ARRAY [
            (1, 2, 1),
            (3, 1, 3),
            (2, 2, 1),
            (1, 1, 2)
        ];
        expected_saved_containers := 6;
        expected_stack_reports := ARRAY [
            (1, 1, 'M'),
            (2, 1, 'C'),
            (3, 4, 'D')
        ];
        -- When
        test_saved_containers := (
            SELECT aoc.save_container_locations(
                new_locations => given_container_locations
            )
        );
        test_move_set_id := (
            SELECT aoc.save_container_moves(
                new_moves => given_container_moves
            )
        );
        test_stack_reports := (
            SELECT array_agg(cms) FROM aoc.run_container_move_set(
                move_set_id => test_move_set_id, atomic => TRUE
            ) cms
        );
        -- Then
        ASSERT test_saved_containers = expected_saved_containers,
            test_saved_containers::text || ' != ' || expected_saved_containers::text;
        ASSERT test_stack_reports = expected_stack_reports,
            test_stack_reports::text || ' != ' || expected_stack_reports::text;
    END;
$$;

ROLLBACK;
