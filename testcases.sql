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


-- Verify Commuter Registration
SELECT * FROM METRO_ADMIN.COMMUTER;

-- Check Commuter Details
SELECT * FROM METRO_ADMIN.COMMUTER WHERE first_name || ' ' || last_name IN (
    'Amit Sharma', 'Priya Patel', 'Anjali Yadav', 'Sandeep Kumar', 'Pooja Joshi',
    'Rajesh Mishra', 'Sunita Thakur', 'Vikas Singhal', 'Divya Shah', 'Ajay Rastogi',
    'Shilpa Sharma', 'Rajendra Patil', 'Rahul Verma', 'Neha Gupta', 'Deepak Singh'
);

-- Ensure Unique Email Addresses
SELECT email, COUNT(*) FROM METRO_ADMIN.COMMUTER GROUP BY email HAVING COUNT(*) > 1;

-- Validate Password Encryption
-- This depends on the specific hashing algorithm used for password encryption. If bcrypt is used, you can't directly verify the hash since bcrypt generates a different hash every time due to its salted nature. Instead, you can ensure that the passwords are stored securely in hashed form.

-- Confirm Commuter Count
SELECT COUNT(*) FROM METRO_ADMIN.COMMUTER;

-- Verify Commuter IDs
SELECT commuter_id, COUNT(*) FROM METRO_ADMIN.COMMUTER GROUP BY commuter_id HAVING COUNT(*) > 1;

-- Validate Phone Numbers
SELECT phone_number FROM METRO_ADMIN.COMMUTER WHERE phone_number NOT LIKE '9876543%';



