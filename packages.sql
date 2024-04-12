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


