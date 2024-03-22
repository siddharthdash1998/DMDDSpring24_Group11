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


