-- Report 1: Number of tickets sold per route
SELECT r.route_id, r.route_name, COUNT(t.ticket_id) AS tickets_sold
FROM Route r
LEFT JOIN Master_table m ON r.route_id = m.route_id
LEFT JOIN Ticket t ON m.srst_id = t.srst_id
GROUP BY r.route_id, r.route_name
ORDER BY tickets_sold DESC;

-- Report 2: Total revenue generated from ticket sales
SELECT SUM(t.fare) AS total_revenue
FROM Ticket t;

-- Report 3: Number of employees per station
SELECT s.station_id, s.station_name, COUNT(e.employee_id) AS num_employees
FROM Station s
LEFT JOIN Employee e ON s.station_id = e.station_id
GROUP BY s.station_id, s.station_name
ORDER BY num_employees DESC;

-- Report 4: Average rating of feedback received
SELECT AVG(f.rating) AS average_rating
FROM Feedback f;

-- Report 5: Total number of commuters
SELECT COUNT(*) AS total_commuters
FROM Commuter;

-- Report 6: Total number of schedule change requests by status
SELECT status, COUNT(*) AS num_requests
FROM schedule_change_request
GROUP BY status;
