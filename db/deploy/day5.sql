-- Deploy aoc-2022:day5 to pg
-- requires: aocschema

ALTER SYSTEM SET log_min_messages = 'DEBUG';
ALTER SYSTEM RESET log_min_error_statement;
ALTER SYSTEM SET log_error_verbosity = 'TERSE';
BEGIN;

-- region: schema

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
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    container_id BIGINT REFERENCES aoc.container(id) NOT NULL,
    stack_number BIGINT NOT NULL,
    stack_position BIGINT NOT NULL,
    created_at timestamptz NOT NULL DEFAULT current_timestamp,
    updated_at timestamptz NOT NULL DEFAULT current_timestamp
);

CREATE UNIQUE INDEX uidx_container_stack_number_position
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

-- endregion
-- region: logic

CREATE TYPE aoc.new_container_location AS (
    name TEXT,
    stack_number BIGINT,
    stack_position BIGINT
);


CREATE OR REPLACE FUNCTION aoc.save_container_locations(
    new_locations aoc.new_container_location[]
) RETURNS BIGINT LANGUAGE sql AS $$
    WITH container_locations AS (
        SELECT (unnest(new_locations)::aoc.new_container_location).*
    ), new_container AS (
        INSERT INTO aoc.container (name)
        SELECT DISTINCT name FROM container_locations
        ON CONFLICT (name) DO UPDATE SET name=excluded.name
        RETURNING *
    ), new_location AS (
        INSERT INTO aoc.container_location (container_id, stack_number, stack_position)
        SELECT DISTINCT ON (cl.stack_number, cl.stack_position)
            nc.id as container_id,
            cl.stack_number,
            cl.stack_position
        FROM new_container nc
        INNER JOIN container_locations cl
            ON cl.name = nc.name
        ON CONFLICT (stack_number, stack_position)
        DO UPDATE SET container_id = excluded.container_id
        RETURNING *
    )
    SELECT count(*) FROM new_location LIMIT 1
$$;

CREATE TYPE aoc.new_container_move AS (
    number_containers BIGINT,
    from_stack_number BIGINT,
    to_stack_number BIGINT
);


CREATE OR REPLACE FUNCTION aoc.save_container_moves(
    new_moves aoc.new_container_move[]
) RETURNS BIGINT LANGUAGE sql AS $$
    WITH container_moves AS (
        SELECT
            generate_series(1, cardinality(new_moves)) as move_number,
            (unnest(new_moves)::aoc.new_container_move).*
        ORDER BY move_number
    ), new_move_set AS (
        INSERT INTO aoc.container_move_set DEFAULT VALUES RETURNING *
    ), new_container_move AS (
        INSERT INTO aoc.container_move (
            container_move_set_id,
            move_number,
            number_containers,
            from_stack_number,
            to_stack_number
        )
        SELECT
            cms.container_move_set_id,
            cm.*
        FROM container_moves cm, LATERAL (
            SELECT id AS container_move_set_id FROM new_move_set LIMIT 1
        ) cms
        RETURNING container_move_set_id
    )
    SELECT container_move_set_id FROM new_container_move LIMIT 1
$$;


CREATE TYPE aoc.stack_report AS (
    stack_number BIGINT,
    top_stack_position BIGINT,
    top_container_name TEXT
);

CREATE OR REPLACE FUNCTION aoc.move_container(
    from_stack BIGINT, to_stack BIGINT
) RETURNS aoc.stack_report LANGUAGE sql AS $$
    WITH container_at_stack AS (
        SELECT container_id, stack_number, stack_position, np.new_position
        FROM aoc.container_location, LATERAL (
            SELECT coalesce(max(stack_position), 0) + 1 AS new_position
            FROM aoc.container_location
            WHERE stack_number = to_stack
            LIMIT 1
        ) np
        WHERE stack_number = from_stack
        ORDER BY stack_position DESC LIMIT 1
    ), updated_location AS (
        UPDATE aoc.container_location cl SET
            stack_number = to_stack,
            stack_position = new_position
        FROM container_at_stack cas
        WHERE
            cl.container_id = cas.container_id
            AND cl.stack_number = cas.stack_number
            AND cl.stack_position = cas.stack_position
        RETURNING cl.*
    )
    SELECT
        ul.stack_number,
        ul.stack_position,
        c.name
    FROM aoc.container c
    INNER JOIN updated_location ul ON ul.container_id = c.id
$$;

CREATE OR REPLACE FUNCTION aoc.get_top_container_per_stack(
) RETURNS SETOF aoc.stack_report LANGUAGE sql AS $$
    WITH top_stack_positions AS (
        SELECT
            stack_number,
            max(stack_position) as stack_position
        FROM aoc.container_location
        GROUP BY 1
        ORDER BY 1, stack_position DESC
    )
    SELECT
        cl.stack_number,
        cl.stack_position as top_stack_position,
        c.name as top_container_name
    FROM aoc.container_location cl
    INNER JOIN aoc.container c on c.id = cl.container_id
    INNER JOIN top_stack_positions tsp
        ON tsp.stack_number = cl.stack_number
        AND tsp.stack_position = cl.stack_position
    ORDER BY 1
$$;

CREATE OR REPLACE FUNCTION aoc.run_container_move_set(
    move_set_id BIGINT
) RETURNS SETOF aoc.stack_report LANGUAGE plpgsql AS $$
    DECLARE moves aoc.container_move[];
    DECLARE move aoc.container_move;
    DECLARE iteration BIGINT;
    DECLARE total_moved BIGINT;
    DECLARE current_position aoc.stack_report;
    BEGIN
        moves := ARRAY (
            SELECT cm
            FROM aoc.container_move cm
            WHERE container_move_set_id = move_set_id
            ORDER BY move_number
        );
        RAISE INFO 'Got % move(s) for move-set.', cardinality(moves);
        FOREACH move in ARRAY moves
        LOOP
            RAISE LOG 'Running Move #%: move % from % to %',
                move.move_number,
                move.number_containers,
                move.from_stack_number,
                move.to_stack_number;
            iteration := move.number_containers;
            total_moved := 0;
            WHILE iteration > 0 LOOP
                current_position := aoc.move_container(
                    from_stack => move.from_stack_number,
                    to_stack => move.to_stack_number
                );
                iteration := iteration - 1;
                total_moved := total_moved + 1;
                RAISE DEBUG 'Ran Move #% (%/%): moved % to %, (pos %)',
                    move.move_number,
                    total_moved,
                    move.number_containers,
                    current_position.top_container_name,
                    current_position.stack_number,
                    current_position.top_stack_position
                ;
            END LOOP;
        END LOOP;
        RETURN QUERY (
            SELECT * FROM aoc.get_top_container_per_stack() ORDER BY stack_number
        );
    END;
$$;

COMMIT;
