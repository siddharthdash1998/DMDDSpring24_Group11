/*

CREATE OR REPLACE PACKAGE METRO_ADMIN.Ticketing_System_Pkg AS
    PROCEDURE Purchase_Ticket(
        p_email IN VARCHAR2,
        p_start_station IN VARCHAR2,
        p_end_station IN VARCHAR2
    );
END Ticketing_System_Pkg;
/

CREATE OR REPLACE PACKAGE BODY METRO_ADMIN.Ticketing_System_Pkg AS
    PROCEDURE Purchase_Ticket(
        p_email IN VARCHAR2,
        p_start_station IN VARCHAR2,
        p_end_station IN VARCHAR2
    ) IS
        v_srst_id NUMBER;
        v_purchase_date DATE := SYSDATE;
        v_current_time TIMESTAMP := CURRENT_TIMESTAMP;
        v_nearest_time TIMESTAMP;
    BEGIN
        -- Find the nearest srst_id based on the current time
        SELECT MIN("Time") INTO v_nearest_time
        FROM Master_table
        WHERE "Time" > v_current_time;

        SELECT srst_id INTO v_srst_id
        FROM Master_table
        WHERE "Time" = v_nearest_time;

        -- Insert ticket details into the Ticket table
        INSERT INTO Ticket (ticket_id, srst_id, purchase_date)
        VALUES (
            TICKET_ID_SEQ.NEXTVAL,
            v_srst_id,
            v_purchase_date
        );

        -- Insert details into the TICKETING_SYSTEM table
        INSERT INTO METRO_ADMIN.TICKETING_SYSTEM (
            TICKET_SYSTEM_ID,
            COMMUTER_ID,
            START_STATION,
            END_STATION,
            "TIME"
        ) VALUES (
            TICKET_SYSTEM_ID_SEQ.NEXTVAL,
            (SELECT commuter_id FROM METRO_ADMIN.COMMUTER WHERE email = p_email),
            p_start_station,
            p_end_station,
            v_current_time
        );

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Handle case where no future schedule is available
            DBMS_OUTPUT.PUT_LINE('No future schedule available');
        WHEN OTHERS THEN
            -- Handle other exceptions
            RAISE;
    END Purchase_Ticket;
END Ticketing_System_Pkg;
/

*/