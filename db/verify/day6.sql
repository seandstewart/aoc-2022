-- Verify aoc-2022:day6 on pg

BEGIN;

CREATE TYPE aoc.day6_test_case AS (
    given_data text,
    expected_packet_index bigint,
    expected_message_index bigint
);

DO $$
    DECLARE test_cases aoc.day6_test_case[];
    DECLARE test_case aoc.day6_test_case;
    DECLARE test_stream_data TEXT;
    DECLARE test_steam_id BIGINT;
    DECLARE test_stream_packet aoc.stream_data;
    DECLARE test_stream_message aoc.stream_data;
    DECLARE expected_packet_index BIGINT;
    DECLARE expected_message_index BIGINT;
    DECLARE
    BEGIN
        test_cases := ARRAY [
            ('mjqjpqmgbljsphdztnvjfqwrcgsmlb', 7, 19),
            ('bvwbjplbgvbhsrlpgdmjqwftvncz', 5, 23),
            ('nppdvjthqldpwncqszvftbrmjlhg', 6, 23),
            ('nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg', 10, 29),
            ('zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw', 11, 26)
        ];
        FOREACH test_case IN ARRAY test_cases
        LOOP
            -- Given
            test_stream_data := test_case.given_data;
            expected_packet_index := test_case.expected_packet_index;
            expected_message_index := test_case.expected_message_index;
            -- When
            test_steam_id := (SELECT aoc.save_stream(data => test_stream_data));
            test_stream_packet := (
                SELECT aoc.locate_packet_start_marker_for_stream(
                    stream_id => test_steam_id
                )
            );
            test_stream_message := (
                SELECT aoc.locate_message_start_marker_for_stream(
                    stream_id => test_steam_id
                )
            );
            -- Then
            ASSERT test_stream_packet.marker_index = expected_packet_index, test_stream_packet;
            ASSERT test_stream_message.marker_index = expected_message_index, test_stream_message;
        END LOOP;
    END;
$$;

ROLLBACK;
