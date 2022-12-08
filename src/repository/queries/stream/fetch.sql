-- :name locate_packet_start_marker :one
SELECT * FROM aoc.locate_packet_start_marker_for_stream(stream_id => :stream_id);

-- :name locate_message_start_marker :one
SELECT * FROM aoc.locate_message_start_marker_for_stream(stream_id => :stream_id);
