DECLARE
    current_schema VARCHAR2(100);
BEGIN
    SELECT USER INTO current_schema FROM dual;

    IF current_schema != 'METRO_ADMIN' THEN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = METRO_ADMIN';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Exception handling to ignore if schema change is not possible
END;
/


-- TRAIN -- 

DECLARE
    train_count NUMBER;
BEGIN
    -- Check if there are existing records in the Train table
    SELECT COUNT(*) INTO train_count FROM Train;

    -- If no records are found, proceed with populating the Train table
    IF train_count = 0 THEN
        -- For orangeline_inbound
        DECLARE
            v_train_id NUMBER := 1;  -- Starting train_id
        BEGIN
            FOR i IN 1..144 LOOP  -- Populate 144 trains for 12 hours
                INSERT INTO Train (train_id, train_name, model)
                VALUES (v_train_id, 'Train for Orange Line Inbound', 'Model A');
                
                v_train_id := v_train_id + 1;  -- Increment train_id
            END LOOP;
        END;

        -- For orangeline_outbound
        DECLARE
            v_train_id NUMBER := 145;  -- Starting train_id
        BEGIN
            FOR i IN 1..144 LOOP  -- Populate 144 trains for 12 hours
                INSERT INTO Train (train_id, train_name, model)
                VALUES (v_train_id, 'Train for Orange Line Outbound', 'Model B');
                
                v_train_id := v_train_id + 1;  -- Increment train_id
            END LOOP;
        END;

        COMMIT;
    END IF;
END;
/



-- ROUTE -- 

DECLARE
    route_count NUMBER;
BEGIN
    -- Check if there are existing records in the Route table
    SELECT COUNT(*) INTO route_count FROM Route;

    -- If no records are found, proceed with inserting data into the Route table
    IF route_count = 0 THEN
        -- Insert data into Route table
        INSERT INTO Route (route_id, route_name, distance) VALUES (1, 'orangeline_inbound', 100);
        INSERT INTO Route (route_id, route_name, distance) VALUES (2, 'orangeline_outbound', 100);
        
        COMMIT;
    END IF;
END;
/



--Station 


DECLARE
    station_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(station_insert_error, -1);
BEGIN
    -- Check if the current schema is metro_admin, if not, switch the schema
    IF SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'METRO_ADMIN' THEN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = METRO_ADMIN';
    END IF;

    -- Insert data into Station table with exception handling
    FOR i IN 1..20 LOOP
        -- Check if the Station table already contains data for the specified station_id before inserting
        DECLARE
            station_count NUMBER;
        BEGIN
            SELECT COUNT(*)
            INTO station_count
            FROM Station
            WHERE station_id = i;

            IF station_count = 0 THEN
                INSERT INTO Station (station_id, station_name, location, capacity)
                VALUES (i,
                        CASE i
                            WHEN 1 THEN 'Oak Grove'
                            WHEN 2 THEN 'Malden Center'
                            WHEN 3 THEN 'Wellington'
                            WHEN 4 THEN 'Assembly'
                            WHEN 5 THEN 'Sullivan Square'
                            WHEN 6 THEN 'Community College'
                            WHEN 7 THEN 'North Station'
                            WHEN 8 THEN 'Haymarket'
                            WHEN 9 THEN 'State'
                            WHEN 10 THEN 'Downtown Crossing'
                            WHEN 11 THEN 'Chinatown'
                            WHEN 12 THEN 'Tufts Medical Center'
                            WHEN 13 THEN 'Back Bay'
                            WHEN 14 THEN 'Massachusetts Avenue'
                            WHEN 15 THEN 'Ruggles'
                            WHEN 16 THEN 'Roxbury Crossing'
                            WHEN 17 THEN 'Jackson Square'
                            WHEN 18 THEN 'Stony Brook'
                            WHEN 19 THEN 'Green Street'
                            WHEN 20 THEN 'Forest Hills'
                        END,
                        CASE i
                            WHEN 1 THEN 'Malden'
                            WHEN 2 THEN 'Malden'
                            WHEN 3 THEN 'Medford'
                            WHEN 4 THEN 'Somerville'
                            WHEN 5 THEN 'Charlestown'
                            WHEN 6 THEN 'Charlestown'
                            WHEN 7 THEN 'West End'
                            WHEN 8 THEN 'Downtown Boston'
                            WHEN 9 THEN 'Downtown Boston'
                            WHEN 10 THEN 'Downtown Crossing'
                            WHEN 11 THEN 'Chinatown'
                            WHEN 12 THEN 'South End'
                            WHEN 13 THEN 'Back Bay'
                            WHEN 14 THEN 'Back Bay'
                            WHEN 15 THEN 'Roxbury'
                            WHEN 16 THEN 'Roxbury'
                            WHEN 17 THEN 'Jamaica Plain'
                            WHEN 18 THEN 'Jamaica Plain'
                            WHEN 19 THEN 'Jamaica Plain'
                            WHEN 20 THEN 'Jamaica Plain'
                        END,
                        CASE i
                            WHEN 1 THEN 200
                            WHEN 2 THEN 150
                            WHEN 3 THEN 180
                            WHEN 4 THEN 170
                            WHEN 5 THEN 190
                            WHEN 6 THEN 160
                            WHEN 7 THEN 220
                            WHEN 8 THEN 210
                            WHEN 9 THEN 200
                            WHEN 10 THEN 180
                            WHEN 11 THEN 190
                            WHEN 12 THEN 170
                            WHEN 13 THEN 220
                            WHEN 14 THEN 200
                            WHEN 15 THEN 180
                            WHEN 16 THEN 170
                            WHEN 17 THEN 160
                            WHEN 18 THEN 150
                            WHEN 19 THEN 140
                            WHEN 20 THEN 220
                        END);
            END IF;
        END;
    END LOOP;
    
    COMMIT;
EXCEPTION
    WHEN station_insert_error THEN
        NULL; -- Ignore if the insert fails due to data already existing
    WHEN OTHERS THEN
        RAISE; -- Raise any other exceptions
END;
/





DECLARE
    employee_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(employee_insert_error, -1);
BEGIN
    -- Check if the current schema is metro_admin, if not, switch the schema
    IF SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'METRO_ADMIN' THEN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = METRO_ADMIN';
    END IF;

    -- Insert data into Employee table with exception handling
    INSERT INTO Employee (employee_id, station_id, position, first_name, last_name)
    SELECT *
    FROM (
        SELECT 1 AS employee_id, 1 AS station_id, 'Staff' AS position, 'John' AS first_name, 'Doe' AS last_name FROM DUAL UNION ALL
        SELECT 2, 2, 'Staff', 'Jane', 'Smith' FROM DUAL UNION ALL
        SELECT 3, 3, 'Staff', 'Alice', 'Johnson' FROM DUAL UNION ALL
        SELECT 4, 4, 'Staff', 'Bob', 'Brown' FROM DUAL UNION ALL
        SELECT 5, 5, 'Staff', 'Emma', 'Wilson' FROM DUAL UNION ALL
        SELECT 6, 6, 'Staff', 'David', 'Lee' FROM DUAL UNION ALL
        SELECT 7, 7, 'Staff', 'Sarah', 'Martinez' FROM DUAL UNION ALL
        SELECT 8, 8, 'Staff', 'Michael', 'Thompson' FROM DUAL UNION ALL
        SELECT 9, 9, 'Staff', 'Olivia', 'Garcia' FROM DUAL UNION ALL
        SELECT 10, 10, 'Staff', 'Daniel', 'Rodriguez' FROM DUAL UNION ALL
        SELECT 11, 11, 'Staff', 'Sophia', 'Hernandez' FROM DUAL UNION ALL
        SELECT 12, 12, 'Staff', 'Ethan', 'Moore' FROM DUAL UNION ALL
        SELECT 13, 13, 'Staff', 'Ava', 'Wood' FROM DUAL UNION ALL
        SELECT 14, 14, 'Staff', 'Noah', 'Cooper' FROM DUAL UNION ALL
        SELECT 15, 15, 'Staff', 'Mia', 'King' FROM DUAL UNION ALL
        SELECT 16, 16, 'Staff', 'James', 'Stewart' FROM DUAL UNION ALL
        SELECT 17, 17, 'Staff', 'Emily', 'Morgan' FROM DUAL UNION ALL
        SELECT 18, 18, 'Staff', 'Benjamin', 'Bailey' FROM DUAL UNION ALL
        SELECT 19, 19, 'Staff', 'Charlotte', 'Cox' FROM DUAL UNION ALL
        SELECT 20, 20, 'Staff', 'Liam', 'Rivera' FROM DUAL
    ) e
    WHERE NOT EXISTS (
        SELECT 1
        FROM Employee
        WHERE employee_id = e.employee_id
    );

    COMMIT;
EXCEPTION
    WHEN employee_insert_error THEN
        NULL; -- Ignore if the insert fails due to data already existing
    WHEN OTHERS THEN
        RAISE; -- Raise any other exceptions
END;
/




DECLARE
    srst_sequence_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(srst_sequence_error, -1);
BEGIN
    -- Drop sequence srst_id_sequence if it exists
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE srst_id_sequence';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -2289 THEN
                NULL; -- Sequence does not exist, ignore
            ELSE
                RAISE; -- Raise other errors
            END IF;
    END;

    -- Create sequence srst_id_sequence
    EXECUTE IMMEDIATE 'CREATE SEQUENCE srst_id_sequence';

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        RAISE; -- Raise any other exceptions
END;
/



DECLARE
    master_table_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(master_table_insert_error, -1);
    master_table_count NUMBER;
    -- Define variables for start and end times for operational hours
    start_time TIMESTAMP := TIMESTAMP '2024-03-13 06:00:00';
    end_time TIMESTAMP := TIMESTAMP '2024-03-13 18:00:00';
    -- Define the time interval between trains
    interval_value INTERVAL DAY TO SECOND := INTERVAL '30' MINUTE;
    -- Initialize the train_id
    train_id_route1 NUMBER := 1;
    train_id_route2 NUMBER := 144;
    -- Initialize current_time
    current_time TIMESTAMP := start_time;
BEGIN
    -- Check if there are existing records in the Master_table
    SELECT COUNT(*) INTO master_table_count FROM Master_table;

    -- If no records are found, proceed with populating the Master_table
    IF master_table_count = 0 THEN
        -- Loop through each minute within the operational hours
        WHILE current_time <= end_time LOOP
            -- Loop through each station for Route 1
            FOR station_id IN 1..20 LOOP
                -- Calculate time for Route 1
                DECLARE
                    time_for_route1 TIMESTAMP := current_time + (station_id * interval_value);
                BEGIN
                    -- Insert data into Master_table for Route 1
                    INSERT INTO Master_table (srst_id, route_id, station_id, "Date", train_id, "Time")
                    VALUES (srst_id_sequence.nextval, 1, station_id, DATE '2024-03-13', train_id_route1, time_for_route1);
                END;
            END LOOP;

            -- Loop through each station for Route 2
            FOR station_id IN REVERSE 1..20 LOOP
                -- Calculate time for Route 2
                DECLARE
                    time_for_route2 TIMESTAMP := current_time + ((20 - station_id) * interval_value);
                BEGIN
                    -- Insert data into Master_table for Route 2
                    INSERT INTO Master_table (srst_id, route_id, station_id, "Date", train_id, "Time")
                    VALUES (srst_id_sequence.nextval, 2, station_id, DATE '2024-03-13', train_id_route2, time_for_route2);
                END;
            END LOOP;

            -- Increment current_time for the next set of trains
            current_time := current_time + interval_value;
            -- Increment train_id for the next set of trains
            train_id_route1 := train_id_route1 + 1;
            train_id_route2 := train_id_route2 + 1;
        END LOOP;

        COMMIT;
    END IF;
EXCEPTION
    WHEN master_table_insert_error THEN
        NULL; -- Ignore if the insert fails due to data already existing
    WHEN OTHERS THEN
        RAISE; -- Raise any other exceptions
END;
/





DECLARE
    e_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_insert_error, -1);
BEGIN
    -- Sample schedule change requests
    INSERT INTO schedule_change_request (schedule_change_id, employee_id, route_id, request_date, original_schedule_time, new_schedule_time, status, reason)
    VALUES (1, 1, 1, TO_DATE('2024-03-13', 'YYYY-MM-DD'), TO_DATE('2024-03-13 06:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-03-13 07:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'pending', 'Requesting schedule change for earlier shift');

    INSERT INTO schedule_change_request (schedule_change_id, employee_id, route_id, request_date, original_schedule_time, new_schedule_time, status, reason)
    VALUES (2, 2, 2, TO_DATE('2024-03-13', 'YYYY-MM-DD'), TO_DATE('2024-03-13 07:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-03-13 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'pending', 'Requesting schedule change for later shift');

    -- Additional sample schedule change requests
    INSERT INTO schedule_change_request (schedule_change_id, employee_id, route_id, request_date, original_schedule_time, new_schedule_time, status, reason)
    VALUES (3, 3, 1, TO_DATE('2024-03-13', 'YYYY-MM-DD'), TO_DATE('2024-03-13 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-03-13 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'pending', 'Requesting schedule change for earlier shift');

    INSERT INTO schedule_change_request (schedule_change_id, employee_id, route_id, request_date, original_schedule_time, new_schedule_time, status, reason)
    VALUES (4, 4, 2, TO_DATE('2024-03-13', 'YYYY-MM-DD'), TO_DATE('2024-03-13 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-03-13 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'pending', 'Requesting schedule change for later shift');

    INSERT INTO schedule_change_request (schedule_change_id, employee_id, route_id, request_date, original_schedule_time, new_schedule_time, status, reason)
    VALUES (5, 5, 1, TO_DATE('2024-03-13', 'YYYY-MM-DD'), TO_DATE('2024-03-13 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-03-13 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'pending', 'Requesting schedule change for earlier shift');

    INSERT INTO schedule_change_request (schedule_change_id, employee_id, route_id, request_date, original_schedule_time, new_schedule_time, status, reason)
    VALUES (6, 6, 2, TO_DATE('2024-03-13', 'YYYY-MM-DD'), TO_DATE('2024-03-13 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-03-13 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'pending', 'Requesting schedule change for later shift');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        NULL; -- Ignore the exception for duplicate values
END;
/


-- COMMUTER -- 
DECLARE 
    commuter_insert_error EXCEPTION; 
    PRAGMA EXCEPTION_INIT(commuter_insert_error, -1); 
BEGIN 
    -- Insert commuter data here 
    INSERT INTO METRO_ADMIN.Commuter (commuter_id, first_name, last_name, email, phone_number) 
    VALUES (1, 'John', 'Doe', 'john.doe@example.com', '123-456-7890'); 

    INSERT INTO METRO_ADMIN.Commuter (commuter_id, first_name, last_name, email, phone_number) 
    VALUES (2, 'Jane', 'Smith', 'jane.smith@example.com', '987-654-3210'); 

    INSERT INTO METRO_ADMIN.Commuter (commuter_id, first_name, last_name, email, phone_number) 
    VALUES (3, 'Alice', 'Johnson', 'alice.johnson@example.com', '555-123-4567'); 
EXCEPTION 
    WHEN commuter_insert_error THEN 
        NULL; -- Ignore the exception for commuter insertion 
END; 
/ 

-- TICKETING_SYSTEM -- 
DECLARE 
    ticketing_system_insert_error EXCEPTION; 
    PRAGMA EXCEPTION_INIT(ticketing_system_insert_error, -1); 
BEGIN 
    -- Insert ticketing system data here 
    INSERT INTO METRO_ADMIN.Ticketing_System (ticket_system_id, commuter_id, start_station, end_station, "TIME") 
    VALUES (1, 1, 'Oak Grove', 'Forest Hills', TIMESTAMP '2024-03-13 07:00:00'); 

    INSERT INTO METRO_ADMIN.Ticketing_System (ticket_system_id, commuter_id, start_station, end_station, "TIME") 
    VALUES (2, 2, 'Malden Center', 'Downtown Crossing', TIMESTAMP '2024-03-13 08:15:00'); 

    INSERT INTO METRO_ADMIN.Ticketing_System (ticket_system_id, commuter_id, start_station, end_station, "TIME") 
    VALUES (3, 3, 'Wellington', 'Back Bay', TIMESTAMP '2024-03-13 09:30:00'); 
EXCEPTION 
    WHEN ticketing_system_insert_error THEN 
        NULL; -- Ignore the exception for ticketing system insertion 
END; 
/ 

DECLARE
    ticket_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(ticket_insert_error, -1);
BEGIN
    -- Insert ticket data here
    INSERT INTO METRO_ADMIN.Ticket (ticket_id, ticket_system_id, srst_id, purchase_date, fare)
    VALUES (1, 1, 1, DATE '2024-03-13', 2.50);
    
    INSERT INTO METRO_ADMIN.Ticket (ticket_id, ticket_system_id, srst_id, purchase_date, fare)
    VALUES (2, 2, 2, DATE '2024-03-13', 2.75);
    
    INSERT INTO METRO_ADMIN.Ticket (ticket_id, ticket_system_id, srst_id, purchase_date, fare)
    VALUES (3, 3, 3, DATE '2024-03-13', 3.00);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        NULL; -- Ignore the exception for duplicate values
    WHEN OTHERS THEN
        RAISE; -- Raise any other exceptions
END;
/

-- FEEDBACK -- 
DECLARE
    feedback_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(feedback_insert_error, -1);
BEGIN
    -- Insert feedback data here
    INSERT INTO METRO_ADMIN.Feedback (feedback_id, ticket_id, feedback_text, rating, date_of_feedback)
    VALUES (1, 1, 'Great service!', 5, DATE '2024-03-13');
    
    INSERT INTO METRO_ADMIN.Feedback (feedback_id, ticket_id, feedback_text, rating, date_of_feedback)
    VALUES (2, 2, 'Train was delayed.', 3, DATE '2024-03-13');
    
    INSERT INTO METRO_ADMIN.Feedback (feedback_id, ticket_id, feedback_text, rating, date_of_feedback)
    VALUES (3, 3, 'Clean trains.', 4, DATE '2024-03-13');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        NULL; -- Ignore the exception for duplicate values
    WHEN OTHERS THEN
        RAISE; -- Raise any other exceptions
END;
/


