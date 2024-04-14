-- Test Cases for Commuter Table
-- Inserting a new commuter
INSERT INTO COMMUTER (commuter_id, first_name, last_name, email, password, phone_number) VALUES (99, 'John', 'Doe', 'john@example.com', 'password123', '1234567890');

-- Inserting another commuter with different details
INSERT INTO COMMUTER (commuter_id, first_name, last_name, email, password, phone_number) VALUES (98, 'Jane', 'Smith', 'jane@example.com', 'securepass', '9876543210');

-- Attempting to insert a commuter with an existing commuter_id (expected to fail due to unique constraint)
-- INSERT INTO COMMUTER (commuter_id, first_name, last_name, email, password, phone_number) VALUES (99, 'Mike', 'Johnson', 'mike@example.com', 'mypass', '5555555555');

-- Attempting to insert a commuter with a NULL value for commuter_id (expected to fail due to primary key constraint)
-- INSERT INTO COMMUTER (commuter_id, first_name, last_name, email, password, phone_number) VALUES (NULL, 'Chris', 'Wilson', 'chris@example.com', '123abc', '9998887777');

-- Attempting to insert a commuter with a NULL value for first_name (expected to fail due to NOT NULL constraint)
-- INSERT INTO COMMUTER (commuter_id, first_name, last_name, email, password, phone_number) VALUES (5, NULL, 'Smith', 'smith@example.com', 'pass123', '7777777777');


-- Test Cases for Employee Table
-- Inserting a new employee
INSERT INTO Employee (employee_id, first_name, last_name, position, station_id) VALUES (98, 'Michael', 'Smith', 'Manager', 1);

-- Inserting another employee with different details
INSERT INTO Employee (employee_id, first_name, last_name, position, station_id) VALUES (99, 'Emily', 'Johnson', 'Assistant', 2);

-- Attempting to insert an employee with an existing employee_id (expected to fail due to unique constraint)
-- INSERT INTO Employee (employee_id, first_name, last_name, position, station_id) VALUES (98, 'Chris', 'Wilson', 'Clerk', 3);

-- Attempting to insert an employee with a NULL value for employee_id (expected to fail due to primary key constraint)
-- INSERT INTO Employee (employee_id, first_name, last_name, position, station_id) VALUES (NULL, 'Sarah', 'Taylor', 'Clerk', 4);

-- Attempting to insert an employee with a NULL value for first_name (expected to fail due to NOT NULL constraint)
-- INSERT INTO Employee (employee_id, first_name, last_name, position, station_id) VALUES (5, NULL, 'Anderson', 'Clerk', 5);

COMMIT; -- Committing changes to the database

-- Test Cases for Schedule Change Request Table
-- Inserting a new schedule change request
INSERT INTO schedule_change_request (schedule_change_id, employee_id, route_id, request_date, original_schedule_time, new_schedule_time, status, reason) 
VALUES (98, 1, 1, TO_DATE('2024-04-13', 'YYYY-MM-DD'), TO_DATE('2024-04-15 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-04-15 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'pending', 'Delay in train arrival');

-- Inserting another schedule change request with different details
INSERT INTO schedule_change_request (schedule_change_id, employee_id, route_id, request_date, original_schedule_time, new_schedule_time, status, reason) 
VALUES (99, 2, 2, TO_DATE('2024-04-14', 'YYYY-MM-DD'), TO_DATE('2024-04-16 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-04-16 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'accepted', 'Adjustment for maintenance work');

-- Attempting to insert a schedule change request with an existing schedule_change_id (expected to fail due to unique constraint)
-- INSERT INTO schedule_change_request (schedule_change_id, employee_id, route_id, request_date, original_schedule_time, new_schedule_time, status, reason) 
-- VALUES (99, 3, 3, TO_DATE('2024-04-15', 'YYYY-MM-DD'), TO_DATE('2024-04-17 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-04-17 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'pending', 'Emergency situation');

-- Attempting to insert a schedule change request with a NULL value for schedule_change_id (expected to fail due to primary key constraint)
-- INSERT INTO schedule_change_request (schedule_change_id, employee_id, route_id, request_date, original_schedule_time, new_schedule_time, status, reason) 
-- VALUES (NULL, 4, 4, TO_DATE('2024-04-16', 'YYYY-MM-DD'), TO_DATE('2024-04-18 07:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-04-18 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'accepted', 'Weather conditions');

-- Attempting to insert a schedule change request with a NULL value for employee_id (expected to fail due to foreign key constraint)
-- INSERT INTO schedule_change_request (schedule_change_id, employee_id, route_id, request_date, original_schedule_time, new_schedule_time, status, reason) 
-- VALUES (5, NULL, 5, TO_DATE('2024-04-17', 'YYYY-MM-DD'), TO_DATE('2024-04-19 06:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-04-19 07:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'rejected', 'Track maintenance');

COMMIT; -- Committing changes to the database
