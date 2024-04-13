alter session set current_schema=METRO_ADMIN;
ALTER TABLE Employee MODIFY station_id NUMBER;

-- Create package specification for schedule_management_pkg
CREATE OR REPLACE PACKAGE schedule_management_pkg AS
    -- Procedure to insert a schedule change request
    PROCEDURE insert_schedule_change_request(
        p_employee_id IN schedule_change_request.employee_id%TYPE,
        p_route_id IN schedule_change_request.route_id%TYPE,
        p_request_date IN schedule_change_request.request_date%TYPE,
        p_original_schedule_time IN schedule_change_request.original_schedule_time%TYPE,
        p_new_schedule_time IN schedule_change_request.new_schedule_time%TYPE,
        p_reason IN schedule_change_request.reason%TYPE
    );

    -- Procedure to update status of a schedule change request
    PROCEDURE update_schedule_change_status(
        p_schedule_change_id IN schedule_change_request.schedule_change_id%TYPE,
        p_status IN schedule_change_request.status%TYPE
    );
END schedule_management_pkg;
/

-- Create package body for schedule_management_pkg
CREATE OR REPLACE PACKAGE BODY schedule_management_pkg AS
    -- Procedure to insert a schedule change request
    PROCEDURE insert_schedule_change_request(
        p_employee_id IN schedule_change_request.employee_id%TYPE,
        p_route_id IN schedule_change_request.route_id%TYPE,
        p_request_date IN schedule_change_request.request_date%TYPE,
        p_original_schedule_time IN schedule_change_request.original_schedule_time%TYPE,
        p_new_schedule_time IN schedule_change_request.new_schedule_time%TYPE,
        p_reason IN schedule_change_request.reason%TYPE
    ) AS
        v_schedule_change_id schedule_change_request.schedule_change_id%TYPE;
    BEGIN
        -- Generate a unique schedule_change_id using the logic similar to Feedback table
        SELECT NVL(MAX(schedule_change_id), 0) + 1 INTO v_schedule_change_id FROM schedule_change_request;
        
        INSERT INTO schedule_change_request (
            schedule_change_id,
            employee_id,
            route_id,
            request_date,
            original_schedule_time,
            new_schedule_time,
            status,
            reason
        ) VALUES (
            v_schedule_change_id,
            p_employee_id,
            p_route_id,
            p_request_date,
            p_original_schedule_time,
            p_new_schedule_time,
            'pending', -- Default status
            p_reason
        );
        COMMIT;
    END insert_schedule_change_request;

    -- Procedure to update status of a schedule change request
    PROCEDURE update_schedule_change_status(
        p_schedule_change_id IN schedule_change_request.schedule_change_id%TYPE,
        p_status IN schedule_change_request.status%TYPE
    ) AS
    BEGIN
        UPDATE schedule_change_request
        SET status = p_status
        WHERE schedule_change_id = p_schedule_change_id;
    END update_schedule_change_status;
END schedule_management_pkg;
/


BEGIN
    schedule_management_pkg.insert_schedule_change_request(
        p_employee_id => 16, -- Replace with the appropriate employee ID
        p_route_id => 1,
        p_request_date => SYSDATE,
        p_original_schedule_time => TO_DATE('2024-04-20 07:20:00', 'YYYY-MM-DD HH24:MI:SS'),
        p_new_schedule_time => TO_DATE('2024-04-20 07:30:00', 'YYYY-MM-DD HH24:MI:SS'),
        p_reason => 'Delay due to unexpected circumstances'
    );
    COMMIT;
END;

BEGIN
    schedule_management_pkg.update_schedule_change_status(
        p_schedule_change_id => 8,
        p_status => 'accepted'
    );
    COMMIT;
END;

