-- Verify aoc-2022:rock-paper-scissors on pg

BEGIN;

-- Check the configuration
DO $$
    BEGIN
        ASSERT (SELECT count(*) = 3 FROM aoc.shape);
        ASSERT (SELECT count(*) = 6 FROM aoc.shape_alias);
        ASSERT (SELECT count(*) = 9 FROM aoc.shape_outcome);

    END;
$$;

-- Check the functionality
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
        expected_outcome := (test_tourney_id, 15, 15);
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
