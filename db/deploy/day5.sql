-- Deploy aoc-2022:day5 to pg
-- requires: aocschema

BEGIN;

CREATE FUNCTION trigger_set_timestamp() RETURNS TRIGGER
    LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

CREATE TABLE IF NOT EXISTS aoc.container (
    id BIGINT PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL,
    created_at timestamptz NOT NULL DEFAULT current_timestamp
);

CREATE UNIQUE INDEX uidx_container_name ON aoc.container(name);


CREATE TABLE IF NOT EXISTS aoc.container_location (
    container_id BIGINT PRIMARY KEY REFERENCES aoc.container(id) NOT NULL,
    stack_number BIGINT NOT NULL,
    stack_position BIGINT NOT NULL,
    created_at timestamptz NOT NULL DEFAULT current_timestamp,
    updated_at timestamptz NOT NULL DEFAULT current_timestamp
);

CREATE UNIQUE INDEX uidx_container_stack_number_postion
    ON aoc.container_location(stack_number, stack_position);

CREATE TRIGGER container_location_updated_at BEFORE UPDATE ON aoc.container_location
    FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();


CREATE TABLE IF NOT EXISTS aoc.container_move_set (
    id BIGINT PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
    created_at timestamptz NOT NULL DEFAULT current_timestamp
);

CREATE TABLE IF NOT EXISTS aoc.container_move (
    id BIGINT PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
    container_move_set_id BIGINT NOT NULL REFERENCES aoc.container_move_set(id),
    move_number BIGINT NOT NULL,
    number_containers BIGINT NOT NULL,
    from_stack_number BIGINT NOT NULL,
    to_stack_number BIGINT NOT NULL,
    created_at timestamptz NOT NULL DEFAULT current_timestamp
);

CREATE OR REPLACE FUNCTION aoc.move_container(
    from_stack BIGINT, to_stack BIGINT
) RETURNS aoc.container_location LANGUAGE sql AS $$
    WITH container_at_stack AS (
        SELECT container_id, new_position
        FROM aoc.container_location, LATERAL (
            SELECT max(stack_position) + 1 AS new_position
            FROM aoc.container_location
            WHERE stack_number = to_stack
            LIMIT 1
        )
        WHERE stack_number = from_stack
        ORDER BY stack_position DESC LIMIT 1
    )
    UPDATE aoc.container_location cl SET
        stack_number = to_stack,
        stack_position = new_position
    FROM container_at_stack cas
    WHERE cl.container_id = cas.container_id
    RETURNING *
$$;


CREATE TYPE aoc.stack_report AS (
    stack_number BIGINT,
    top_stack_position BIGINT,
    top_container_name TEXT
);

CREATE OR REPLACE FUNCTION aoc.get_top_container_per_stack(
) RETURNS SETOF aoc.stack_report LANGUAGE sql AS $$
    WITH top_stack_positions AS (
        SELECT
            stack_number,
            max(stack_position) as top_stack_position
        FROM aoc.container_location
        GROUP BY 1
    )
    SELECT
        cl.stack_number,
        cl.stack_position as top_stack_position,
        c.name as top_container_name
    FROM aoc.container_location cl
    INNER JOIN container c on c.id = cl.container_id
    INNER JOIN top_stack_positions tsp
        ON tsp.stack_number = cl.stack_number
        AND tsp.top_stack_position = cl.stack_position
$$;

CREATE OR REPLACE FUNCTION aoc.run_container_move_set(
    move_set_id BIGINT
) RETURNS SETOF aoc.stack_report LANGUAGE plpgsql AS $$
    DECLARE moves aoc.container_move[];
    DECLARE move aoc.container_move;
    DECLARE iteration BIGINT;
    BEGIN;
        moves := (
            SELECT array_agg(cm)
            FROM aoc.container_move cm
            WHERE container_move_set_id = move_set_id
            ORDER BY move_number
        );
        FOREACH move in ARRAY moves
        LOOP
            iteration := move.number_containers;
            WHILE iteration > 0 LOOP
                (
                    SELECT aoc.move_container(
                        from_stack => move.from_stack_number,
                        to_stack => move.to_stack_number
                    )
                );
                iteration := iteration - 1;
            END LOOP;
        END LOOP;
        RETURN QUERY (SELECT * FROM aoc.get_top_container_per_stack());
    END;
$$;

COMMIT;
