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

