-- Verify aoc-2022:day4 on pg

BEGIN;

DO $$
    DECLARE test_assignment_text TEXT;
    DECLARE test_assignment_list_id BIGINT;
    DECLARE test_containment_assignment_report aoc.assignment_report;
    DECLARE test_assignment_report aoc.assignment_report;
    DECLARE expected_containment_assignment_overlaps BIGINT;
    DECLARE expected_assignment_overlaps BIGINT;
    BEGIN
        -- Given
        test_assignment_text := '2-4,6-8
        2-3,4-5
        5-7,7-9
        2-8,3-7
        6-6,4-6
        2-6,4-8
        ';
        expected_containment_assignment_overlaps := 2;
        expected_assignment_overlaps := 4;
        -- When
        test_assignment_list_id := (SELECT aoc.save_assignments(assignments => test_assignment_text));
        test_assignment_report := (
            SELECT aoc.calculate_overlapping_assignments_by_pair(
                assignment_list_id => test_assignment_list_id
            )
        );
        test_containment_assignment_report := (
            SELECT aoc.calculate_overlapping_assignments_by_pair_containment(
                assignment_list_id => test_assignment_list_id
            )
        );
        -- Then
        ASSERT test_assignment_report.number_overlapping = expected_assignment_overlaps;
        ASSERT test_containment_assignment_report.number_overlapping = expected_containment_assignment_overlaps;
    END
$$;

ROLLBACK;
