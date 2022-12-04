-- Verify aoc-2022:day2-part2 on pg

BEGIN;

DO $$
    DECLARE test_tourney aoc.new_move[];
    DECLARE test_tourney_id BIGINT;
    DECLARE expected_outcome aoc.tournament_outcome;
    DECLARE test_outcome aoc.tournament_outcome;
    BEGIN
        -- Given
        test_tourney := ARRAY [
            ('A', 'Y'),
            ('B', 'X'),
            ('C', 'Z')
        ];
        test_tourney_id := (
            SELECT aoc.save_tournament(moves => test_tourney)
        );
        expected_outcome := (test_tourney_id, 15, 12);
        -- When
        test_outcome := (
            SELECT aoc.calculate_tournament_outcome(
                tournament_id => test_tourney_id
            )
        );
        -- Then
        ASSERT test_outcome = expected_outcome, test_outcome::text || ' != ' || expected_outcome::text;
    END;
$$;


ROLLBACK;
