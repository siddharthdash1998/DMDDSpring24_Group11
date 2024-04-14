alter session set current_schema=ADMIN;

SET SERVEROUTPUT ON;

DECLARE
    v_user_exists    NUMBER;
    v_user_connected NUMBER;
BEGIN
    -- Check if the user exists
    SELECT
        COUNT(*)
    INTO v_user_exists
    FROM
        all_users
    WHERE
        username = 'METRO_ADMIN';
    
    -- Check if the user is already connected
    SELECT
        COUNT(*)
    INTO v_user_connected
    FROM
        v$session
    WHERE
        username = 'METRO_ADMIN';

    -- Drop the user if it exists and not connected
    IF v_user_exists > 0 THEN
        IF v_user_connected = 0 THEN
            EXECUTE IMMEDIATE 'DROP USER METRO_ADMIN CASCADE';
            DBMS_OUTPUT.PUT_LINE('User METRO_ADMIN dropped.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('User METRO_ADMIN is already connected. Cannot drop user.');
            RETURN;
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('User METRO_ADMIN does not exist.');
    END IF;

    -- Create the user
    EXECUTE IMMEDIATE 'CREATE USER METRO_ADMIN IDENTIFIED BY Ninepeople009';

    -- Grant privileges to the user
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE, CREATE TABLE, CREATE VIEW, CREATE USER, DROP USER, CREATE SESSION, CREATE PROCEDURE, CREATE SEQUENCE, CREATE TRIGGER TO METRO_ADMIN WITH ADMIN OPTION';
    
    -- Grant SELECT privilege on dba_users to METRO_ADMIN
    EXECUTE IMMEDIATE 'GRANT SELECT ON dba_users TO METRO_ADMIN';

    -- Set quota on the user's tablespace
    EXECUTE IMMEDIATE 'ALTER USER METRO_ADMIN QUOTA 10M ON DATA';
    
    DBMS_OUTPUT.PUT_LINE('User METRO_ADMIN created with privileges.');
    
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON DBMS_OUTPUT TO METRO_ADMIN';
    
END;
/

alter session set current_schema=METRO_ADMIN;

DECLARE
    v_count NUMBER;
BEGIN
    -- Check if Employee user exists
    SELECT COUNT(*)
    INTO v_count
    FROM dba_users
    WHERE username = 'EMPLOYEEUSER';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER EmployeeUser IDENTIFIED BY Ninepeople009';
    ELSE
        DBMS_OUTPUT.PUT_LINE('Employee user already exists');
    END IF;

    -- Check if Commuter user exists
    SELECT COUNT(*)
    INTO v_count
    FROM dba_users
    WHERE username = 'COMMUTERUSER';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER CommuterUser IDENTIFIED BY Ninepeople009';
        
    ELSE
        DBMS_OUTPUT.PUT_LINE('Commuter user already exists');
    END IF;

    -- Grant permissions to Employee user
BEGIN
    -- Grant DML (Data Manipulation Language) privileges on the SCHEDULE_CHANGE_REQUEST table
    EXECUTE IMMEDIATE 'GRANT INSERT, UPDATE, DELETE ON METRO_ADMIN.SCHEDULE_CHANGE_REQUEST TO EmployeeUser';

    -- Grant necessary privileges for connecting to the database
    EXECUTE IMMEDIATE 'GRANT CONNECT TO EmployeeUser';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO EmployeeUser';
        
        DBMS_OUTPUT.PUT_LINE('Permissions granted to Employee');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error granting permissions to Employee: ' || SQLERRM);
    END;

    -- Grant permissions to views for Employee user
    BEGIN
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.ACCEPTED_SCHEDULE_CHANGE_REQUESTS TO EmployeeUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.PENDING_SCHEDULE_CHANGE_REQUESTS TO EmployeeUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.REJECTED_SCHEDULE_CHANGE_REQUESTS TO EmployeeUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.MALDEN_CENTER_SCHEDULE TO EmployeeUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.OAK_GROVE_SCHEDULE TO EmployeeUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.ORANGE_LINE_OUTBOUND_STATIONS TO EmployeeUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.ORANGELINE_INBOUND TO EmployeeUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.ORANGELINE_OUTBOUND TO EmployeeUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.FEEDBACK_WITH_STATION TO EmployeeUser';
        DBMS_OUTPUT.PUT_LINE('Views access granted to Employee');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error granting views access to Employee: ' || SQLERRM);
    END;

    -- Grant permissions to views for Commuter user
    BEGIN
        EXECUTE IMMEDIATE 'GRANT CONNECT TO CommuterUser';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO CommuterUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.MALDEN_CENTER_SCHEDULE TO CommuterUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.OAK_GROVE_SCHEDULE TO CommuterUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.ORANGE_LINE_OUTBOUND_STATIONS TO CommuterUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.ORANGELINE_INBOUND TO CommuterUser';
        EXECUTE IMMEDIATE 'GRANT SELECT ON METRO_ADMIN.ORANGELINE_OUTBOUND TO CommuterUser';
        DBMS_OUTPUT.PUT_LINE('Views access granted to Commuter');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error granting views access to Commuter: ' || SQLERRM);
    END;
END;
/

