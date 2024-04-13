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
        p_employee_id => 17,
        p_route_id => 1,
        p_original_schedule_time => TO_DATE('2024-04-20 07:25:00', 'YYYY-MM-DD HH24:MI:SS'),
        p_new_schedule_time => TO_DATE('2024-04-20 07:35:00', 'YYYY-MM-DD HH24:MI:SS'),
        p_reason => 'Delay due to unexpected circumstances'
    );
    COMMIT;
END;

BEGIN
    reject_schedule_change(
        p_schedule_change_id => 7
    );
    COMMIT;
END;


BEGIN
    accept_schedule_change(
        p_schedule_change_id => 7
    );
    COMMIT;
END;



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
            WHERE station_id >= v_employee_station_id
            AND route_id = v_route_id
            AND "Time" >= v_original_schedule_time AND "Time" <= TRUNC(v_original_schedule_time)+INTERVAL '1' DAY;
        
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Master_table updated successfully.');
        ELSE
            UPDATE Master_table
            SET "Time" = "Time" + (v_new_schedule_time - v_original_schedule_time)
            WHERE station_id <= v_employee_station_id
            AND route_id = v_route_id
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


BEGIN
    update_master_table_schedule(p_schedule_change_id => 7);
    commit;
END;
/
commit;



--- few queries to test things out ---- 
SELECT
    srst_id,
    route_id,
    station_id,
    TO_CHAR("Date", 'YYYY-MM-DD') AS "Date",
    train_id,
    TO_CHAR("Time", 'YYYY MM DD HH24 MI SS') AS "Time"
FROM Master_table
WHERE station_id = 1 AND route_id = 1 AND TRUNC(TIME)=
ORDER BY route_id ASC, "Date" ASC, "Time" ASC;


SELECT
  srst_id,
  route_id,
  station_id,
  TO_CHAR("Date", 'YYYY-MM-DD') AS "Date",
  train_id,
  TO_CHAR("Time", 'YYYY MM DD HH24 MI SS') AS "Time"
FROM Master_table
WHERE station_id = 17 
  AND route_id = 1 
  AND "Time" >= TO_DATE('2024-04-20 07:20:00', 'YYYY-MM-DD HH24:MI:SS')  -- Check for specific date
ORDER BY route_id ASC, "Date" ASC, "Time" ASC;


SELECT
  srst_id,
  route_id,
  station_id,
  TO_CHAR("Date", 'YYYY-MM-DD') AS "Date",
  train_id,
  TO_CHAR("Time", 'YYYY-MM-DD HH24:MI:SS') AS "Time"
FROM Master_table
WHERE route_id = 1 
AND Station_id >= 15 AND STATION_ID<=20
  AND "Time" >= TO_DATE('2024-04-20 07:15:00', 'YYYY-MM-DD HH24:MI:SS')  -- Check for specific date and time
ORDER BY route_id ASC, "Date" ASC,  STATION_ID ASC,"Time" ASC;



