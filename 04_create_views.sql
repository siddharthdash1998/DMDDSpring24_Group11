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

DECLARE
    e_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_insert_error, -1);
    view_already_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(view_already_exists, -955); -- ORA-00955: name is already used by an existing object

BEGIN
    -- Attempt to create the view for pending schedule change requests
    BEGIN
        EXECUTE IMMEDIATE '
            CREATE OR REPLACE VIEW pending_schedule_change_requests AS
            SELECT 
                schedule_change_id,
                employee_id,
                route_id,
                request_date,
                original_schedule_time,
                new_schedule_time,
                status,
                reason
            FROM 
                schedule_change_request
            WHERE 
                status = ''pending''';
        DBMS_OUTPUT.PUT_LINE('View PENDING_SCHEDULE_CHANGE_REQUESTS created.');
    EXCEPTION
        WHEN view_already_exists THEN
            DBMS_OUTPUT.PUT_LINE('View PENDING_SCHEDULE_CHANGE_REQUESTS already exists. Skipping creation.');
    END;

    -- Attempt to create the view for accepted schedule change requests
    BEGIN
        EXECUTE IMMEDIATE '
            CREATE OR REPLACE VIEW accepted_schedule_change_requests AS
            SELECT 
                schedule_change_id,
                employee_id,
                route_id,
                request_date,
                original_schedule_time,
                new_schedule_time,
                status,
                reason
            FROM 
                schedule_change_request
            WHERE 
                status = ''accepted''';
        DBMS_OUTPUT.PUT_LINE('View ACCEPTED_SCHEDULE_CHANGE_REQUESTS created.');
    EXCEPTION
        WHEN view_already_exists THEN
            DBMS_OUTPUT.PUT_LINE('View ACCEPTED_SCHEDULE_CHANGE_REQUESTS already exists. Skipping creation.');
    END;

    -- Attempt to create the view for rejected schedule change requests
    BEGIN
        EXECUTE IMMEDIATE '
            CREATE OR REPLACE VIEW rejected_schedule_change_requests AS
            SELECT 
                schedule_change_id,
                employee_id,
                route_id,
                request_date,
                original_schedule_time,
                new_schedule_time,
                status,
                reason
            FROM 
                schedule_change_request
            WHERE 
                status = ''rejected''';
        DBMS_OUTPUT.PUT_LINE('View REJECTED_SCHEDULE_CHANGE_REQUESTS created.');
    EXCEPTION
        WHEN view_already_exists THEN
            DBMS_OUTPUT.PUT_LINE('View REJECTED_SCHEDULE_CHANGE_REQUESTS already exists. Skipping creation.');
    END;

EXCEPTION
    WHEN e_insert_error THEN
        NULL; -- Ignore exception for duplicate values
END;
/

----- THE ABOVE IS FOR PENDING SCHEDULE CHANGE REQUESTS -- 



--- STATION WISE SCHEDULE ---- 

DECLARE
    e_insert_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_insert_error, -1);
    view_already_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(view_already_exists, -955); -- ORA-00955: name is already used by an existing object

BEGIN
    -- Attempt to create the view for Oak Grove station schedule
    BEGIN
        EXECUTE IMMEDIATE '
            CREATE OR REPLACE VIEW OAK_GROVE_SCHEDULE AS
            SELECT 
                srst_id,
                route_id,
                station_id,
                ''Oak Grove'' AS station_name,
                "Date",
                train_id,
                TO_CHAR("Time", ''YYYY-MM-DD HH24:MI:SS'') AS "Time"
            FROM 
                Master_table 
            WHERE 
                station_id = 1
            ORDER BY 
                "Time" ASC';
        DBMS_OUTPUT.PUT_LINE('View OAK_GROVE_SCHEDULE created.');
    EXCEPTION
        WHEN view_already_exists THEN
            DBMS_OUTPUT.PUT_LINE('View OAK_GROVE_SCHEDULE already exists. Skipping creation.');
    END;

    -- Attempt to create the view for Malden Center station schedule
    BEGIN
        EXECUTE IMMEDIATE '
            CREATE OR REPLACE VIEW MALDEN_CENTER_SCHEDULE AS
            SELECT 
                srst_id,
                route_id,
                station_id,
                ''Malden Center'' AS station_name,
                "Date",
                train_id,
                TO_CHAR("Time", ''YYYY-MM-DD HH24:MI:SS'') AS "Time"
            FROM 
                Master_table 
            WHERE 
                station_id = 2
            ORDER BY 
                "Time" ASC';
        DBMS_OUTPUT.PUT_LINE('View MALDEN_CENTER_SCHEDULE created.');
    EXCEPTION
        WHEN view_already_exists THEN
            DBMS_OUTPUT.PUT_LINE('View MALDEN_CENTER_SCHEDULE already exists. Skipping creation.');
    END;

    -- Add more stations as needed

EXCEPTION
    WHEN e_insert_error THEN
        NULL; -- Ignore exception for duplicate values
END;
/



----------------------------

-- Create view for Orange Line Inbound
CREATE OR REPLACE VIEW OrangeLine_Inbound AS
SELECT s.station_id, s.station_name, s.location, s.capacity
FROM Station s
JOIN (
    SELECT 1 AS order_id, station_id FROM Station WHERE station_id = 1
    UNION ALL SELECT 2, station_id FROM Station WHERE station_id = 2
    UNION ALL SELECT 3, station_id FROM Station WHERE station_id = 3
    UNION ALL SELECT 4, station_id FROM Station WHERE station_id = 4
    UNION ALL SELECT 5, station_id FROM Station WHERE station_id = 5
    UNION ALL SELECT 6, station_id FROM Station WHERE station_id = 6
    UNION ALL SELECT 7, station_id FROM Station WHERE station_id = 7
    UNION ALL SELECT 8, station_id FROM Station WHERE station_id = 8
    UNION ALL SELECT 9, station_id FROM Station WHERE station_id = 9
    UNION ALL SELECT 10, station_id FROM Station WHERE station_id = 10
    UNION ALL SELECT 11, station_id FROM Station WHERE station_id = 11
    UNION ALL SELECT 12, station_id FROM Station WHERE station_id = 12
    UNION ALL SELECT 13, station_id FROM Station WHERE station_id = 13
    UNION ALL SELECT 14, station_id FROM Station WHERE station_id = 14
    UNION ALL SELECT 15, station_id FROM Station WHERE station_id = 15
    UNION ALL SELECT 16, station_id FROM Station WHERE station_id = 16
    UNION ALL SELECT 17, station_id FROM Station WHERE station_id = 17
    UNION ALL SELECT 18, station_id FROM Station WHERE station_id = 18
    UNION ALL SELECT 19, station_id FROM Station WHERE station_id = 19
    UNION ALL SELECT 20, station_id FROM Station WHERE station_id = 20
) o ON s.station_id = o.station_id
ORDER BY o.order_id;

-- Create view for Orange Line Outbound
CREATE OR REPLACE VIEW OrangeLine_Outbound AS
SELECT s.station_id, s.station_name, s.location, s.capacity
FROM Station s
JOIN (
    SELECT 1 AS order_id, station_id FROM Station WHERE station_id = 20
    UNION ALL SELECT 2, station_id FROM Station WHERE station_id = 19
    UNION ALL SELECT 3, station_id FROM Station WHERE station_id = 18
    UNION ALL SELECT 4, station_id FROM Station WHERE station_id = 17
    UNION ALL SELECT 5, station_id FROM Station WHERE station_id = 16
    UNION ALL SELECT 6, station_id FROM Station WHERE station_id = 15
    UNION ALL SELECT 7, station_id FROM Station WHERE station_id = 14
    UNION ALL SELECT 8, station_id FROM Station WHERE station_id = 13
    UNION ALL SELECT 9, station_id FROM Station WHERE station_id = 12
    UNION ALL SELECT 10, station_id FROM Station WHERE station_id = 11
    UNION ALL SELECT 11, station_id FROM Station WHERE station_id = 10
    UNION ALL SELECT 12, station_id FROM Station WHERE station_id = 9
    UNION ALL SELECT 13, station_id FROM Station WHERE station_id = 8
    UNION ALL SELECT 14, station_id FROM Station WHERE station_id = 7
    UNION ALL SELECT 15, station_id FROM Station WHERE station_id = 6
    UNION ALL SELECT 16, station_id FROM Station WHERE station_id = 5
    UNION ALL SELECT 17, station_id FROM Station WHERE station_id = 4
    UNION ALL SELECT 18, station_id FROM Station WHERE station_id = 3
    UNION ALL SELECT 19, station_id FROM Station WHERE station_id = 2
    UNION ALL SELECT 20, station_id FROM Station WHERE station_id = 1
) o ON s.station_id = o.station_id
ORDER BY o.order_id;




----------------Feedback received ordered by Station -----------------------

CREATE OR REPLACE VIEW Feedback_With_Station AS
SELECT f.feedback_id,
       f.feedback_text,
       f.rating,
       f.date_of_feedback,
       s.station_name
FROM Feedback f
JOIN Ticket t ON f.ticket_id = t.ticket_id
JOIN MASTER_TABLE mt ON t.srst_id = mt.srst_id
JOIN Station s ON mt.station_id = s.station_id;


