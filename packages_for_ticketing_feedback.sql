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



CREATE OR REPLACE PROCEDURE Insert_Ticket_Entry(
    p_ticket_system_id NUMBER,
    p_srst_id NUMBER,
    p_purchase_date DATE,
    p_fare DECIMAL
) AS
BEGIN
    INSERT INTO Ticket (ticket_id, srst_id, purchase_date, fare, TICKET_SYSTEM_ID)
    VALUES ((SELECT NVL(MAX(ticket_id), 0) + 1 FROM Ticket), p_srst_id, p_purchase_date, p_fare, p_ticket_system_id);
    
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
BEGIN

    -- Find the nearest srst_id corresponding to the start station and current timestamp
    SELECT srst_id INTO v_nearest_srst_id
    FROM (
        SELECT m.srst_id, m."Time"
        FROM Master_table m
        JOIN Station s ON m.station_id = s.station_id
        WHERE s.station_name = :NEW.START_STATION
        ORDER BY ABS(EXTRACT(SECOND FROM (m."Time" - SYSTIMESTAMP))) ASC
    )
    WHERE ROWNUM = 1;
    
    Insert_Ticket_Entry(:NEW.TICKET_SYSTEM_ID,v_nearest_srst_id, SYSDATE, 2.00);
    

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error occurred: ' || SQLERRM);
END;
/




BEGIN
    Ticketing_System_Pkg.Add_Ticketing_Entry(9, 'State', 'Chinatown');
    COMMIT;
END;
/


select * from TICKETING_SYSTEM;
select * from Ticket;

select * from station;

select * from commuter;




-- below is working -- 

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


BEGIN
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Amit', 'Sharma', 'amit_sharma@example.com', 'password1', '987654321');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Priya', 'Patel', 'priya_patel@example.com', 'password2', '987654322');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Anjali', 'Yadav', 'anjali_yadav@example.com', 'password3', '987654326');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Sandeep', 'Kumar', 'sandeep_kumar@example.com', 'password4', '987654327');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Pooja', 'Joshi', 'pooja_joshi@example.com', 'password5', '987654328');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Rajesh', 'Mishra', 'rajesh_mishra@example.com', 'password6', '987654329');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Sunita', 'Thakur', 'sunita_thakur@example.com', 'password7', '987654330');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Vikas', 'Singhal', 'vikas_singhal@example.com', 'password8', '987654331');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Divya', 'Shah', 'divya_shah@example.com', 'password9', '987654332');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Ajay', 'Rastogi', 'ajay_rastogi@example.com', 'password10', '987654333');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Shilpa', 'Sharma', 'shilpa_sharma@example.com', 'password11', '987654334');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Rajendra', 'Patil', 'rajendra_patil@example.com', 'password12', '987654335');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Rahul', 'Verma', 'rahul_verma@example.com', 'password13', '987654323');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Neha', 'Gupta', 'neha_gupta@example.com', 'password14', '987654324');
    METRO_ADMIN.Commuter_Onboarding_Pkg.Register_Commuter('Deepak', 'Singh', 'deepak_singh@example.com', 'password15', '987654325');
    
    COMMIT;
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


BEGIN
    Feedback_Pkg.Add_Feedback(49080, 'Great service!', 5, 1);
    Feedback_Pkg.Add_Feedback(49079, 'Smooth journey.', 4, 2);
    Feedback_Pkg.Add_Feedback(49078, 'Clean trains.', 5, 3);
    Feedback_Pkg.Add_Feedback(19726, 'Prompt arrival.', 4, 6);
    Feedback_Pkg.Add_Feedback(19727, 'Friendly staff.', 5, 7);
    
    COMMIT;
END;
/


select * from ticket;




