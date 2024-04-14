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

BEGIN
    Ticketing_System_Pkg.Add_Ticketing_Entry(1, 'Haymarket', 'State');
    Ticketing_System_Pkg.Add_Ticketing_Entry(2, 'North Station', 'Community College');
    Ticketing_System_Pkg.Add_Ticketing_Entry(3, 'Assembly', 'Back Bay');
    Ticketing_System_Pkg.Add_Ticketing_Entry(4, 'Forest Hills', 'Chinatown');
    Ticketing_System_Pkg.Add_Ticketing_Entry(5, 'Wellington', 'Downtown Crossing');
    COMMIT;
END;
/

BEGIN
    Ticketing_System_Pkg.Add_Ticketing_Entry(10, 'Oak Grove', 'Jackson Square');
    Ticketing_System_Pkg.Add_Ticketing_Entry(11, 'Forest Hills', 'Ruggles');
    COMMIT;
END;
/


BEGIN 
    Feedback_Pkg.Add_Feedback(2, 'Excellent service!', 5, 3);
    Feedback_Pkg.Add_Feedback(6, 'Very helpful staff!', 4, 7);
    Feedback_Pkg.Add_Feedback(10, 'Smooth ride!', 4, 8);
    Feedback_Pkg.Add_Feedback(12, 'Clean train!', 5, 13);
    Feedback_Pkg.Add_Feedback(9,'Great service!', 5,1);
    commit;
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



BEGIN
    update_master_table_schedule(p_schedule_change_id => 10);
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
AND Station_id >= 17 AND STATION_ID<=20
  AND "Time" >= TO_DATE('2024-04-20 07:25:00', 'YYYY-MM-DD HH24:MI:SS')  -- Check for specific date and time
ORDER BY route_id ASC, "Date" ASC,  STATION_ID ASC,"Time" ASC;