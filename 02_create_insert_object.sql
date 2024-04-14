alter session set current_schema=METRO_ADMIN;

CREATE OR REPLACE PACKAGE metro_admin_pkg AS
    PROCEDURE create_metro_tables;
END metro_admin_pkg;
/

CREATE OR REPLACE PACKAGE BODY metro_admin_pkg AS
    PROCEDURE create_metro_tables AS
        v_table_count NUMBER;
        v_error_code NUMBER;
        v_error_message VARCHAR2(4000);
    BEGIN
        -- Dropping tables and their constraints if they exist
        FOR T IN (
            SELECT table_name
            FROM all_tables
            WHERE table_name IN ('TRAIN', 'ROUTE', 'STATION', 'EMPLOYEE', 'MASTER_TABLE', 'SCHEDULE_CHANGE_REQUEST', 'COMMUTER', 'TICKET', 'TICKETING_SYSTEM', 'FEEDBACK')
        ) LOOP
            BEGIN
                EXECUTE IMMEDIATE 'DROP TABLE ' || T.table_name || ' CASCADE CONSTRAINTS';
                DBMS_OUTPUT.PUT_LINE('Dropped Table ' || T.table_name);
            EXCEPTION
                WHEN OTHERS THEN
                    v_error_code := SQLCODE;
                    v_error_message := SQLERRM;
                    IF v_error_code = -942 THEN -- ORA-00942: table or view does not exist
                        DBMS_OUTPUT.PUT_LINE('Table ' || T.table_name || ' does not exist');
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('Error dropping table ' || T.table_name || ': ' || v_error_message);
                    END IF;
            END;
        END LOOP;

        -- Check if the current schema is 'metro_admin'
        IF SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') <> 'METRO_ADMIN' THEN
            EXECUTE IMMEDIATE 'alter session set current_schema=metro_admin';
        END IF;

        -- Check if the table Train exists and create it if it doesn't
        SELECT COUNT(*)
        INTO v_table_count
        FROM user_tables
        WHERE table_name = 'TRAIN';

        IF v_table_count = 0 THEN
            EXECUTE IMMEDIATE '
                CREATE TABLE Train (
                    train_id NUMBER PRIMARY KEY,
                    train_name VARCHAR2(100),
                    model VARCHAR2(50)
                )';
                DBMS_OUTPUT.PUT_LINE('Created Table TRAIN');
        END IF;

        -- Check if the table Route exists and create it if it doesn't
        SELECT COUNT(*)
        INTO v_table_count
        FROM user_tables
        WHERE table_name = 'ROUTE';

        IF v_table_count = 0 THEN
            EXECUTE IMMEDIATE '
                CREATE TABLE Route (
                    route_id NUMBER PRIMARY KEY,
                    route_name VARCHAR2(100),
                    distance NUMBER
                )';
                DBMS_OUTPUT.PUT_LINE('Created Table ROUTE');
        END IF;

        -- Check if the table Station exists and create it if it doesn't
        SELECT COUNT(*)
        INTO v_table_count
        FROM user_tables
        WHERE table_name = 'STATION';

        IF v_table_count = 0 THEN
            EXECUTE IMMEDIATE '
                CREATE TABLE Station (
                    station_id NUMBER PRIMARY KEY,
                    station_name VARCHAR2(100),
                    location VARCHAR2(100),
                    capacity NUMBER
                )';
                DBMS_OUTPUT.PUT_LINE('Created Table STATION');
        END IF;

        -- Check if the table Employee exists and create it if it doesn't
        SELECT COUNT(*)
        INTO v_table_count
        FROM user_tables
        WHERE table_name = 'EMPLOYEE';

        IF v_table_count = 0 THEN
            EXECUTE IMMEDIATE '
                CREATE TABLE Employee (
                    employee_id Number PRIMARY KEY,
                    first_name VARCHAR(255) NOT NULL,
                    last_name VARCHAR(255) NOT NULL,
                    position VARCHAR(100),
                    station_id INT,
                    FOREIGN KEY (station_id) REFERENCES Station(station_id)
                )';
                DBMS_OUTPUT.PUT_LINE('Created Table EMPLOYEE');
        END IF;

        -- Check if the table Master_table exists and create it if it doesn't
        SELECT COUNT(*)
        INTO v_table_count
        FROM user_tables
        WHERE table_name = 'MASTER_TABLE';

        IF v_table_count = 0 THEN
            EXECUTE IMMEDIATE '
                CREATE TABLE Master_table (
                    srst_id NUMBER PRIMARY KEY,
                    route_id NUMBER,
                    station_id NUMBER,
                    "Date" DATE,
                    train_id NUMBER,
                    "Time" DATE,
                    CONSTRAINT fk_route_id FOREIGN KEY (route_id) REFERENCES Route(route_id),
                    CONSTRAINT fk_station_id FOREIGN KEY (station_id) REFERENCES Station(station_id),
                    CONSTRAINT fk_train_id FOREIGN KEY (train_id) REFERENCES Train(train_id)
                )';
                DBMS_OUTPUT.PUT_LINE('Created Table MASTER_TABLE');
        END IF;

        -- Check if the table schedule_change_request exists and create it if it doesn't
        SELECT COUNT(*)
        INTO v_table_count
        FROM user_tables
        WHERE table_name = 'SCHEDULE_CHANGE_REQUEST';

        IF v_table_count = 0 THEN
            EXECUTE IMMEDIATE '
                CREATE TABLE schedule_change_request (
                    schedule_change_id NUMBER PRIMARY KEY,
                    employee_id NUMBER,
                    route_id NUMBER,
                    request_date DATE,
                    original_schedule_time DATE,
                    new_schedule_time DATE,
                    status VARCHAR2(20),
                    reason VARCHAR2(100),
                    CONSTRAINT fk_employee_id FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
                    CONSTRAINT chk_status_value CHECK (status IN (''pending'', ''rejected'', ''accepted''))
                )';
                DBMS_OUTPUT.PUT_LINE('Created Table SCHEDULE CHANGE REQ');
        END IF;

        -- Check if the table Commuter exists and create it if it doesn't
        SELECT COUNT(*)
        INTO v_table_count
        FROM user_tables
        WHERE table_name = 'COMMUTER';

        IF v_table_count = 0 THEN
            EXECUTE IMMEDIATE '
                CREATE TABLE COMMUTER (
                    commuter_id INT PRIMARY KEY,
                    first_name VARCHAR2(255) NOT NULL,
                    last_name VARCHAR2(255) NOT NULL,
                    email VARCHAR2(255),
                    password VARCHAR2(100),
                    phone_number VARCHAR2(15)
                )';
                DBMS_OUTPUT.PUT_LINE('Created Table COMMUTER');
        END IF;

        -- Check if the table METRO_ADMIN.TICKETING_SYSTEM exists and create it if it doesn't
            SELECT COUNT(*)
            INTO v_table_count
            FROM user_tables
            WHERE table_name = 'TICKETING_SYSTEM';
            
            IF v_table_count = 0 THEN
                EXECUTE IMMEDIATE '
                    CREATE TABLE METRO_ADMIN.TICKETING_SYSTEM (
                        TICKET_SYSTEM_ID NUMBER PRIMARY KEY,
                        COMMUTER_ID NUMBER,
                        START_STATION VARCHAR2(100),
                        END_STATION VARCHAR2(100),
                        "TIME" DATE,
                        CONSTRAINT FK_COMMUTER_ID FOREIGN KEY (COMMUTER_ID) REFERENCES METRO_ADMIN.COMMUTER(COMMUTER_ID)
                    )';
                DBMS_OUTPUT.PUT_LINE('Created Table TICKETING SYSTEM');
            END IF;
            
            -- Check if the table Ticket exists and create it if it doesn't
            SELECT COUNT(*)
            INTO v_table_count
            FROM user_tables
            WHERE table_name = 'TICKET';
            
            IF v_table_count = 0 THEN
                EXECUTE IMMEDIATE '
                    CREATE TABLE Ticket (
                        ticket_id INT PRIMARY KEY,
                        ticketing_system_id NUMBER,
                        srst_id INT,
                        purchase_date DATE,
                        fare DECIMAL(10, 2),
                        journey_end CHAR(1) DEFAULT ''N'' CHECK (journey_end IN (''Y'', ''N'')), -- New column added
                        FOREIGN KEY (srst_id) REFERENCES MASTER_TABLE(srst_id),
                        FOREIGN KEY (ticketing_system_id) REFERENCES METRO_ADMIN.TICKETING_SYSTEM(TICKET_SYSTEM_ID)
                    )';
                DBMS_OUTPUT.PUT_LINE('Created Table TICKET');
            END IF;


        -- Check if the table Feedback exists and create it if it doesn't
        SELECT COUNT(*)
        INTO v_table_count
        FROM user_tables
        WHERE table_name = 'FEEDBACK';

        IF v_table_count = 0 THEN
            EXECUTE IMMEDIATE '
                CREATE TABLE Feedback (
                    feedback_id INT PRIMARY KEY,
                    ticket_id INT,
                    feedback_text VARCHAR2(255),
                    rating INT CHECK (rating IN (1, 2, 3, 4, 5)), -- Restricting rating values
                    date_of_feedback TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Setting default value to current date
                    FOREIGN KEY (ticket_id) REFERENCES Ticket(ticket_id)
                )';
                DBMS_OUTPUT.PUT_LINE('Created Table FEEDBACK');
        END IF;

        COMMIT;
    EXCEPTION
        -- Handle exceptions
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
            ROLLBACK;
    END create_metro_tables;
END metro_admin_pkg;
/



BEGIN
    metro_admin_pkg.create_metro_tables;
END;
/



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
            FOR i IN 1..600 LOOP  -- Populate 144 trains for 12 hours
                INSERT INTO Train (train_id, train_name, model)
                VALUES (v_train_id, 'Train for Orange Line Inbound', 'Model A');
                
                v_train_id := v_train_id + 1;  -- Increment train_id
            END LOOP;
        END;

        -- For orangeline_outbound
        DECLARE
            v_train_id NUMBER := 601;  -- Starting train_id
        BEGIN
            FOR i IN 1..600 LOOP  -- Populate 144 trains for 12 hours
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
    start_time TIMESTAMP := TIMESTAMP '2024-04-20 06:00:00';
    end_time TIMESTAMP := TIMESTAMP '2024-04-20 19:00:00';
    -- Define the time interval between trains
    interval_value INTERVAL DAY TO SECOND := INTERVAL '5' MINUTE;
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
                    VALUES (srst_id_sequence.nextval, 1, station_id, DATE '2024-04-20', train_id_route1, time_for_route1);
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
                    VALUES (srst_id_sequence.nextval, 2, station_id, DATE '2024-04-20', train_id_route2, time_for_route2);
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
    master_table_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(master_table_insert_error, -1);
    master_table_count NUMBER;
    -- Define variables for start and end times for operational hours
    start_time TIMESTAMP := TIMESTAMP '2024-04-21 06:00:00';
    end_time TIMESTAMP := TIMESTAMP '2024-04-21 19:00:00';
    -- Define the time interval between trains
    interval_value INTERVAL DAY TO SECOND := INTERVAL '5' MINUTE;
    -- Initialize the train_id
    train_id_route1 NUMBER := 1;
    train_id_route2 NUMBER := 144;
    -- Initialize current_time
    current_time TIMESTAMP := start_time;
BEGIN
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
                    VALUES (srst_id_sequence.nextval, 1, station_id, DATE '2024-04-21', train_id_route1, time_for_route1);
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
                    VALUES (srst_id_sequence.nextval, 2, station_id, DATE '2024-04-21', train_id_route2, time_for_route2);
                END;
            END LOOP;

            -- Increment current_time for the next set of trains
            current_time := current_time + interval_value;
            -- Increment train_id for the next set of trains
            train_id_route1 := train_id_route1 + 1;
            train_id_route2 := train_id_route2 + 1;
        END LOOP;

        COMMIT;
EXCEPTION
    WHEN master_table_insert_error THEN
        NULL; -- Ignore if the insert fails due to data already existing
    WHEN OTHERS THEN
        RAISE; -- Raise any other exceptions
END;
/

DECLARE
    master_table_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(master_table_insert_error, -1);
    master_table_count NUMBER;
    -- Define variables for start and end times for operational hours
    start_time TIMESTAMP := TIMESTAMP '2024-04-22 06:00:00';
    end_time TIMESTAMP := TIMESTAMP '2024-04-22 19:00:00';
    -- Define the time interval between trains
    interval_value INTERVAL DAY TO SECOND := INTERVAL '5' MINUTE;
    -- Initialize the train_id
    train_id_route1 NUMBER := 1;
    train_id_route2 NUMBER := 144;
    -- Initialize current_time
    current_time TIMESTAMP := start_time;
BEGIN
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
                    VALUES (srst_id_sequence.nextval, 1, station_id, DATE '2024-04-22', train_id_route1, time_for_route1);
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
                    VALUES (srst_id_sequence.nextval, 2, station_id, DATE '2024-04-22', train_id_route2, time_for_route2);
                END;
            END LOOP;

            -- Increment current_time for the next set of trains
            current_time := current_time + interval_value;
            -- Increment train_id for the next set of trains
            train_id_route1 := train_id_route1 + 1;
            train_id_route2 := train_id_route2 + 1;
        END LOOP;

        COMMIT;
EXCEPTION
    WHEN master_table_insert_error THEN
        NULL; -- Ignore if the insert fails due to data already existing
    WHEN OTHERS THEN
        RAISE; -- Raise any other exceptions
END;
/

DECLARE
    master_table_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(master_table_insert_error, -1);
    master_table_count NUMBER;
    -- Define variables for start and end times for operational hours
    start_time TIMESTAMP := TIMESTAMP '2024-04-23 06:00:00';
    end_time TIMESTAMP := TIMESTAMP '2024-04-23 19:00:00';
    -- Define the time interval between trains
    interval_value INTERVAL DAY TO SECOND := INTERVAL '5' MINUTE;
    -- Initialize the train_id
    train_id_route1 NUMBER := 1;
    train_id_route2 NUMBER := 144;
    -- Initialize current_time
    current_time TIMESTAMP := start_time;
BEGIN
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
                    VALUES (srst_id_sequence.nextval, 1, station_id, DATE '2024-04-23', train_id_route1, time_for_route1);
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
                    VALUES (srst_id_sequence.nextval, 2, station_id, DATE '2024-04-23', train_id_route2, time_for_route2);
                END;
            END LOOP;

            -- Increment current_time for the next set of trains
            current_time := current_time + interval_value;
            -- Increment train_id for the next set of trains
            train_id_route1 := train_id_route1 + 1;
            train_id_route2 := train_id_route2 + 1;
        END LOOP;

        COMMIT;
EXCEPTION
    WHEN master_table_insert_error THEN
        NULL; -- Ignore if the insert fails due to data already existing
    WHEN OTHERS THEN
        RAISE; -- Raise any other exceptions
END;
/

DECLARE
    master_table_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(master_table_insert_error, -1);
    master_table_count NUMBER;
    -- Define variables for start and end times for operational hours
    start_time TIMESTAMP := TIMESTAMP '2024-04-24 06:00:00';
    end_time TIMESTAMP := TIMESTAMP '2024-04-24 19:00:00';
    -- Define the time interval between trains
    interval_value INTERVAL DAY TO SECOND := INTERVAL '5' MINUTE;
    -- Initialize the train_id
    train_id_route1 NUMBER := 1;
    train_id_route2 NUMBER := 144;
    -- Initialize current_time
    current_time TIMESTAMP := start_time;
BEGIN
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
                    VALUES (srst_id_sequence.nextval, 1, station_id, DATE '2024-04-24', train_id_route1, time_for_route1);
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
                    VALUES (srst_id_sequence.nextval, 2, station_id, DATE '2024-04-24', train_id_route2, time_for_route2);
                END;
            END LOOP;

            -- Increment current_time for the next set of trains
            current_time := current_time + interval_value;
            -- Increment train_id for the next set of trains
            train_id_route1 := train_id_route1 + 1;
            train_id_route2 := train_id_route2 + 1;
        END LOOP;

        COMMIT;
EXCEPTION
    WHEN master_table_insert_error THEN
        NULL; -- Ignore if the insert fails due to data already existing
    WHEN OTHERS THEN
        RAISE; -- Raise any other exceptions
END;
/

DECLARE
    master_table_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(master_table_insert_error, -1);
    master_table_count NUMBER;
    -- Define variables for start and end times for operational hours
    start_time TIMESTAMP := TIMESTAMP '2024-04-25 06:00:00';
    end_time TIMESTAMP := TIMESTAMP '2024-04-25 19:00:00';
    -- Define the time interval between trains
    interval_value INTERVAL DAY TO SECOND := INTERVAL '5' MINUTE;
    -- Initialize the train_id
    train_id_route1 NUMBER := 1;
    train_id_route2 NUMBER := 144;
    -- Initialize current_time
    current_time TIMESTAMP := start_time;
BEGIN
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
                    VALUES (srst_id_sequence.nextval, 1, station_id, DATE '2024-04-25', train_id_route1, time_for_route1);
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
                    VALUES (srst_id_sequence.nextval, 2, station_id, DATE '2024-04-25', train_id_route2, time_for_route2);
                END;
            END LOOP;

            -- Increment current_time for the next set of trains
            current_time := current_time + interval_value;
            -- Increment train_id for the next set of trains
            train_id_route1 := train_id_route1 + 1;
            train_id_route2 := train_id_route2 + 1;
        END LOOP;

        COMMIT;
EXCEPTION
    WHEN master_table_insert_error THEN
        NULL; -- Ignore if the insert fails due to data already existing
    WHEN OTHERS THEN
        RAISE; -- Raise any other exceptions
END;
/

DECLARE
    master_table_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(master_table_insert_error, -1);
    master_table_count NUMBER;
    -- Define variables for start and end times for operational hours
    start_time TIMESTAMP := TIMESTAMP '2024-04-26 06:00:00';
    end_time TIMESTAMP := TIMESTAMP '2024-04-26 19:00:00';
    -- Define the time interval between trains
    interval_value INTERVAL DAY TO SECOND := INTERVAL '5' MINUTE;
    -- Initialize the train_id
    train_id_route1 NUMBER := 1;
    train_id_route2 NUMBER := 144;
    -- Initialize current_time
    current_time TIMESTAMP := start_time;
BEGIN
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
                    VALUES (srst_id_sequence.nextval, 1, station_id, DATE '2024-04-26', train_id_route1, time_for_route1);
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
                    VALUES (srst_id_sequence.nextval, 2, station_id, DATE '2024-04-26', train_id_route2, time_for_route2);
                END;
            END LOOP;

            -- Increment current_time for the next set of trains
            current_time := current_time + interval_value;
            -- Increment train_id for the next set of trains
            train_id_route1 := train_id_route1 + 1;
            train_id_route2 := train_id_route2 + 1;
        END LOOP;

        COMMIT;
EXCEPTION
    WHEN master_table_insert_error THEN
        NULL; -- Ignore if the insert fails due to data already existing
    WHEN OTHERS THEN
        RAISE; -- Raise any other exceptions
END;
/

DECLARE
    master_table_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(master_table_insert_error, -1);
    master_table_count NUMBER;
    -- Define variables for start and end times for operational hours
    start_time TIMESTAMP := TIMESTAMP '2024-04-27 06:00:00';
    end_time TIMESTAMP := TIMESTAMP '2024-04-27 19:00:00';
    -- Define the time interval between trains
    interval_value INTERVAL DAY TO SECOND := INTERVAL '5' MINUTE;
    -- Initialize the train_id
    train_id_route1 NUMBER := 1;
    train_id_route2 NUMBER := 144;
    -- Initialize current_time
    current_time TIMESTAMP := start_time;
BEGIN
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
                    VALUES (srst_id_sequence.nextval, 1, station_id, DATE '2024-04-27', train_id_route1, time_for_route1);
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
                    VALUES (srst_id_sequence.nextval, 2, station_id, DATE '2024-04-27', train_id_route2, time_for_route2);
                END;
            END LOOP;

            -- Increment current_time for the next set of trains
            current_time := current_time + interval_value;
            -- Increment train_id for the next set of trains
            train_id_route1 := train_id_route1 + 1;
            train_id_route2 := train_id_route2 + 1;
        END LOOP;

        COMMIT;
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

commit;

DECLARE
BEGIN
    -- Drop the sequence if it exists
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE METRO_ADMIN.commuter_id_seq';
        DBMS_OUTPUT.PUT_LINE('Dropped Sequence COMMUTER_ID_SEQ');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -2289 THEN -- Sequence does not exist
                RAISE;
            END IF;
    END;

    -- Create the sequence
    EXECUTE IMMEDIATE 'CREATE SEQUENCE METRO_ADMIN.commuter_id_seq START WITH 1 INCREMENT BY 1';
    DBMS_OUTPUT.PUT_LINE('Created Sequence COMMUTER_ID_SEQ');

    -- Create the package specification
    EXECUTE IMMEDIATE '
        CREATE OR REPLACE PACKAGE METRO_ADMIN.Commuter_Onboarding_Pkg AS
            PROCEDURE Register_Commuter(
                p_first_name IN VARCHAR2,
                p_last_name IN VARCHAR2,
                p_email IN VARCHAR2,
                p_password IN VARCHAR2,
                p_phone_number IN VARCHAR2
            );

            PROCEDURE Update_Commuter(
                p_commuter_id IN NUMBER,
                p_first_name IN VARCHAR2,
                p_last_name IN VARCHAR2,
                p_email IN VARCHAR2,
                p_password IN VARCHAR2,
                p_phone_number IN VARCHAR2
            );

            PROCEDURE Delete_Commuter(
                p_commuter_id IN NUMBER
            );
        END Commuter_Onboarding_Pkg;';

    -- Create the package body
    EXECUTE IMMEDIATE '
        CREATE OR REPLACE PACKAGE BODY METRO_ADMIN.Commuter_Onboarding_Pkg AS
            PROCEDURE Register_Commuter(
                p_first_name IN VARCHAR2,
                p_last_name IN VARCHAR2,
                p_email IN VARCHAR2,
                p_password IN VARCHAR2,
                p_phone_number IN VARCHAR2
            ) IS
            BEGIN
                INSERT INTO METRO_ADMIN.COMMUTER (commuter_id, first_name, last_name, email, password, phone_number) 
                VALUES (METRO_ADMIN.commuter_id_seq.NEXTVAL, p_first_name, p_last_name, p_email, p_password, p_phone_number);
            END Register_Commuter;

            PROCEDURE Update_Commuter(
                p_commuter_id IN NUMBER,
                p_first_name IN VARCHAR2,
                p_last_name IN VARCHAR2,
                p_email IN VARCHAR2,
                p_password IN VARCHAR2,
                p_phone_number IN VARCHAR2
            ) IS
            BEGIN
                UPDATE METRO_ADMIN.COMMUTER 
                SET first_name = p_first_name,
                    last_name = p_last_name,
                    email = p_email,
                    password = p_password,
                    phone_number = p_phone_number
                WHERE commuter_id = p_commuter_id;
            END Update_Commuter;

            PROCEDURE Delete_Commuter(
                p_commuter_id IN NUMBER
            ) IS
            BEGIN
                DELETE FROM METRO_ADMIN.COMMUTER WHERE commuter_id = p_commuter_id;
            END Delete_Commuter;
        END Commuter_Onboarding_Pkg;';

    DBMS_OUTPUT.PUT_LINE('Created Sequence, Package Specification, and Package Body');
END;
/


--- above is working --- 


-- BEGIN
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Amit', 'Sharma', 'amit_sharma@example.com', 'password1', '987654321');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Priya', 'Patel', 'priya_patel@example.com', 'password2', '987654322');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Anjali', 'Yadav', 'anjali_yadav@example.com', 'password3', '987654326');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Sandeep', 'Kumar', 'sandeep_kumar@example.com', 'password4', '987654327');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Pooja', 'Joshi', 'pooja_joshi@example.com', 'password5', '987654328');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Rajesh', 'Mishra', 'rajesh_mishra@example.com', 'password6', '987654329');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Sunita', 'Thakur', 'sunita_thakur@example.com', 'password7', '987654330');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Vikas', 'Singhal', 'vikas_singhal@example.com', 'password8', '987654331');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Divya', 'Shah', 'divya_shah@example.com', 'password9', '987654332');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Ajay', 'Rastogi', 'ajay_rastogi@example.com', 'password10', '987654333');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Shilpa', 'Sharma', 'shilpa_sharma@example.com', 'password11', '987654334');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Rajendra', 'Patil', 'rajendra_patil@example.com', 'password12', '987654335');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Rahul', 'Verma', 'rahul_verma@example.com', 'password13', '987654323');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Neha', 'Gupta', 'neha_gupta@example.com', 'password14', '987654324');
--     METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Deepak', 'Singh', 'deepak_singh@example.com', 'password15', '987654325');
    
--     COMMIT;
-- END;
-- /

alter session set current_schema=metro_admin;

CREATE OR REPLACE PACKAGE Ticketing_System_Pkg AS
    PROCEDURE Add_Ticketing_Entry(
        p_commuter_id NUMBER,
        p_start_station VARCHAR2,
        p_end_station VARCHAR2
    );
END Ticketing_System_Pkg;
/

CREATE OR REPLACE PACKAGE BODY Ticketing_System_Pkg AS
    PROCEDURE Add_Ticketing_Entry(
        p_commuter_id NUMBER,
        p_start_station VARCHAR2,
        p_end_station VARCHAR2
    ) IS
        v_start_station_id NUMBER;
        v_end_station_id NUMBER;
    BEGIN
        -- Check if start station exists
        SELECT station_id INTO v_start_station_id
        FROM Station
        WHERE station_name = p_start_station;

        -- Check if end station exists
        SELECT station_id INTO v_end_station_id
        FROM Station
        WHERE station_name = p_end_station;

        -- Insert entry into TICKETING_SYSTEM table
        INSERT INTO METRO_ADMIN.TICKETING_SYSTEM (
            TICKET_SYSTEM_ID,
            COMMUTER_ID,
            START_STATION,
            END_STATION,
            "TIME"
        ) VALUES (
            (SELECT NVL(MAX(TICKET_SYSTEM_ID), 0) + 1 FROM METRO_ADMIN.TICKETING_SYSTEM),
            p_commuter_id,
            p_start_station,
            p_end_station,
            CURRENT_TIMESTAMP
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error occurred: ' || SQLERRM);
    END Add_Ticketing_Entry;
END Ticketing_System_Pkg;
/

CREATE OR REPLACE FUNCTION Calculate_Fare(
    p_station_distance INT
) RETURN NUMBER
IS
    v_fare NUMBER(10, 2); -- Define fare as a decimal
BEGIN
    -- Your fare calculation logic here
    -- Example: fare is $2.50 per station
    v_fare := p_station_distance * 2.00;
    RETURN v_fare;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL; -- Or handle the exception as per your requirement
END Calculate_Fare;
/

CREATE OR REPLACE PROCEDURE Insert_Ticket_Entry(
    p_ticket_system_id NUMBER,
    p_srst_id NUMBER,
    p_purchase_date DATE,
    p_fare DECIMAL
) AS
BEGIN
    INSERT INTO Ticket (ticket_id,ticketing_system_id, srst_id, purchase_date, fare)
    VALUES ((SELECT NVL(MAX(ticket_id), 0) + 1 FROM Ticket),p_ticket_system_id, p_srst_id, p_purchase_date, p_fare);
    
    -- Commit the transaction within the procedure
EXCEPTION
    WHEN OTHERS THEN
        -- Rollback the transaction if any error occurs
        RAISE;
END Insert_Ticket_Entry;
/


CREATE OR REPLACE TRIGGER Create_Ticket_Trigger
AFTER INSERT ON METRO_ADMIN.TICKETING_SYSTEM
FOR EACH ROW
DECLARE
    v_ticket_id INT;
    v_nearest_srst_id INT;
    v_station_distance INT;
    v_route_calculation INT;
    v_fare NUMBER(10,2);
BEGIN
    
    SELECT ABS(
        (SELECT station_id FROM Station WHERE station_name = :NEW.START_STATION) -
        (SELECT station_id FROM Station WHERE station_name = :NEW.END_STATION)
    )
    INTO v_station_distance
    FROM dual;
    
    SELECT(
        (SELECT station_id FROM Station WHERE station_name = :NEW.START_STATION) -
        (SELECT station_id FROM Station WHERE station_name = :NEW.END_STATION)
    )
    INTO v_route_calculation
    FROM dual;
    IF v_route_calculation < 0 THEN
        -- Find the nearest srst_id corresponding to the start station and current timestamp
        SELECT srst_id INTO v_nearest_srst_id
        FROM (
            SELECT m.srst_id, m."Time"
            FROM Master_table m
            JOIN Station s ON m.station_id = s.station_id
            WHERE s.station_name = :NEW.START_STATION 
            AND m.route_id=2
            ORDER BY ABS(EXTRACT(SECOND FROM (m."Time" - SYSTIMESTAMP))) ASC
        )
        WHERE ROWNUM = 1;
    
        v_fare := Calculate_Fare(v_station_distance);
    
        Insert_Ticket_Entry(:NEW.TICKET_SYSTEM_ID,v_nearest_srst_id, SYSDATE, v_fare);
    ELSE 
                -- Find the nearest srst_id corresponding to the start station and current timestamp
        SELECT srst_id INTO v_nearest_srst_id
        FROM (
            SELECT m.srst_id, m."Time"
            FROM Master_table m
            JOIN Station s ON m.station_id = s.station_id
            WHERE s.station_name = :NEW.START_STATION 
            AND m.route_id=1
            ORDER BY ABS(EXTRACT(SECOND FROM (m."Time" - SYSTIMESTAMP))) ASC
        )
        WHERE ROWNUM = 1;
    
        v_fare := Calculate_Fare(v_station_distance);
    
        Insert_Ticket_Entry(:NEW.TICKET_SYSTEM_ID,v_nearest_srst_id, SYSDATE, v_fare);
        
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error occurred: ' || SQLERRM);
END;
/

-- Package specification
CREATE OR REPLACE PACKAGE Feedback_Pkg AS
    PROCEDURE Add_Feedback(
        p_commuter_id INT,
        p_feedback_text VARCHAR2,
        p_rating INT,
        p_ticket_id INT
    );
END Feedback_Pkg;
/

-- Package body
CREATE OR REPLACE PACKAGE BODY Feedback_Pkg AS
    PROCEDURE Add_Feedback(
        p_commuter_id INT,
        p_feedback_text VARCHAR2,
        p_rating INT,
        p_ticket_id INT
    ) IS
    BEGIN
        INSERT INTO Feedback (feedback_id, ticket_id, feedback_text, rating)
        VALUES (
            (SELECT NVL(MAX(feedback_id), 0) + 1 FROM Feedback),
            p_ticket_id,
            p_feedback_text,
            p_rating
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Error occurred: ' || SQLERRM);
    END Add_Feedback;
END Feedback_Pkg;
/


CREATE OR REPLACE PROCEDURE Update_Journey_End_Proc(
    p_ticket_id INT
) AS
BEGIN
    UPDATE Ticket
    SET journey_end = 'Y'
    WHERE ticket_id = p_ticket_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error occurred: ' || SQLERRM);
END Update_Journey_End_Proc;
/

-- Trigger to update journey_end parameter in Ticket table
CREATE OR REPLACE TRIGGER Update_Journey_End_Trigger
AFTER INSERT ON Feedback
FOR EACH ROW
BEGIN
    Update_Journey_End_Proc(:NEW.ticket_id);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error occurred: ' || SQLERRM);
END;
/


alter session set current_schema=METRO_ADMIN;

CREATE OR REPLACE PROCEDURE add_schedule_change_request (
    p_employee_id IN NUMBER,
    p_route_id IN NUMBER,
    p_original_schedule_time IN DATE,
    p_new_schedule_time IN DATE,
    p_reason IN VARCHAR2
)
AS
    v_schedule_change_id NUMBER;
BEGIN
    -- Get the maximum schedule_change_id
    SELECT NVL(MAX(schedule_change_id), 0) + 1 INTO v_schedule_change_id FROM schedule_change_request;

    -- Insert the new row
    INSERT INTO schedule_change_request (
        schedule_change_id,
        employee_id,
        route_id,
        request_date,
        original_schedule_time,
        new_schedule_time,
        reason,
        status
    ) VALUES (
        v_schedule_change_id,
        p_employee_id,
        p_route_id,
        CURRENT_TIMESTAMP,
        p_original_schedule_time,
        p_new_schedule_time,
        p_reason,
        'pending'
    );
    
    COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE accept_schedule_change (
    p_schedule_change_id IN NUMBER
)
AS
BEGIN
    -- Update status to 'accepted'
    UPDATE schedule_change_request
    SET status = 'accepted'
    WHERE schedule_change_id = p_schedule_change_id;
    
    COMMIT;
END;
/


CREATE OR REPLACE PROCEDURE reject_schedule_change (
    p_schedule_change_id IN NUMBER
)
AS
BEGIN
    -- Update status to 'rejected'
    UPDATE schedule_change_request
    SET status = 'rejected'
    WHERE schedule_change_id = p_schedule_change_id;
    
    COMMIT;
END;
/

BEGIN
    add_schedule_change_request(
        p_employee_id => 18,
        p_route_id => 1,
        p_original_schedule_time => TO_DATE('2024-04-20 08:00:00', 'YYYY-MM-DD HH24:MI:SS'),
        p_new_schedule_time => TO_DATE('2024-04-20 08:10:00', 'YYYY-MM-DD HH24:MI:SS'),
        p_reason => 'Delay due to unexpected circumstances'
    );
    COMMIT;
END;
/

BEGIN
    reject_schedule_change(
        p_schedule_change_id => 7
    );
    COMMIT;
END;
/

select * from schedule_change_request;

BEGIN
    accept_schedule_change(
        p_schedule_change_id => 10
    );
    COMMIT;
END;
/


CREATE OR REPLACE PROCEDURE update_master_table_schedule (
    p_schedule_change_id IN NUMBER
)
AS
    v_employee_station_id NUMBER;
    v_route_id NUMBER;
    v_original_schedule_time DATE;
    v_new_schedule_time DATE;
    v_status VARCHAR2(20);
    --v_time_difference INTERVAL DAY(0) TO SECOND(0) := INTERVAL '0' DAY;
BEGIN
    -- Fetch data from schedule_change_request table for the given schedule_change_id
    SELECT employee_id, route_id, original_schedule_time, new_schedule_time, status
    INTO v_employee_station_id, v_route_id, v_original_schedule_time, v_new_schedule_time, v_status
    FROM schedule_change_request
    WHERE schedule_change_id = p_schedule_change_id;
    
    -- Check if the status is 'accepted'
    IF v_status = 'accepted' THEN
        -- Fetch station_id for the employee_id from the Employee table
        SELECT station_id INTO v_employee_station_id FROM Employee WHERE employee_id = v_employee_station_id;
        IF v_route_id = 1 THEN 
        -- Update the Master_table
            UPDATE Master_table
            SET "Time" = "Time" + (v_new_schedule_time - v_original_schedule_time)
            WHERE route_id = v_route_id
            AND "Time" >= v_original_schedule_time AND "Time" <= TRUNC(v_original_schedule_time)+INTERVAL '1' DAY;
        
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Master_table updated successfully.');
        ELSE
            UPDATE Master_table
            SET "Time" = "Time" + (v_new_schedule_time - v_original_schedule_time)
            WHERE route_id = v_route_id
            AND "Time" >= v_original_schedule_time AND "Time" <= TRUNC(v_original_schedule_time)+INTERVAL '1' DAY;
            COMMIT;
        END IF;    
    ELSE
        DBMS_OUTPUT.PUT_LINE('Cannot update Master_table. The status of the schedule change request is not accepted.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Schedule change request not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
