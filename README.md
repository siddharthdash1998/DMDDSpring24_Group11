# DMDDSpring24_Group11
Project Repository for Database Management and Database Design Spring 2024 for Group 11

Metro Line Management System
Project Topic: Implementing a database system for a metro system in a city of 1 million people, akin to the T in Boston, Massachusetts.

Developed a comprehensive database system for Boston's T (Public Transportation System) to address issues related to time delays, schedule mismanagement, and lack of commuter feedback. This project showcases skills in database design, SQL/PL-SQL programming, procedure and trigger development, and addressing real-world challenges in the transportation domain. 

• Designed an efficient database schema to handle various aspects of the metro system, including train schedules, schedule change requests, real-time updates, commuter feedback, and fare calculation.

• Implemented database views and reports to provide insights into train availability, next arrivals, busiest stations, frequent commuters, schedule changes, ticket sales, and feedback ratings.

• Created database packages for table creation, commuter onboarding, ticketing system, and feedback management.

• Developed stored procedures for table creation, commuter registration/update/deletion, ticket entry, feedback submission, schedule change request handling, and journey status updates.

• Implemented triggers for ticket creation and journey end updates, ensuring data integrity and automation.

• Developed a fare calculation function to provide a fair and distance-based pricing system, addressing the issue of fare evasion and potential revenue loss.

• Utilized SQL, PL/SQL, and database design principles to create a robust and scalable solution for managing Boston's T metro system efficiently.

• Addressed key challenges such as real-time schedule updates, commuter feedback integration, and fare calculation optimization.

• Contributed to improving the reliability, transparency, and commuter experience of Boston's public transportation system.


DEMO Sequence: Please start from file with prefix 01 till 06. For files with prefix 07 and 08, kindly create a connection to the database with the mentioned users and their credentials in file 05 to test the views that have been granted to the users.

Entity Relationship Diagram (ERD):

![ERD](ERD.jpeg)


The ERD will depict the entities involved in the metro system and their relationships. It will include entities such as stations, trains, schedules, tickets, commuters, employees, and feedback. Relationships will be established to define how these entities interact with each other.

First, we explore the entities:

Station: Represents each station in the metro system. Attributes: station_id (Primary Key), station_name, location, capacity.

Route: Represents the routes followed by trains. Attributes: route_id (Primary Key), route_name, distance.

Route-Station-Schedule-Train (Master) Table: srst_id (station-route-train-schedule)(Primary Key), station_id (Foreign Key referencing Station), route_id (Foreign Key referencing Route), train_id (referencing Train Table), DATE and TIME.

Train: Represents each train in the metro system. Attributes: train_id (Primary Key), train_name, capacity, model.

Ticketing System: Represents details given by the commuter. Attributes: ticket_system_id, commuter_id (Foreign Key),start_station, end_station, time.

Ticket: Represents tickets generated once the ticketing system is updated with the details. Attributes: ticket_id (Primary Key), srst_id (Foreign Key referencing Master Table), purchase_date, fare.

Commuter: Represents commuters using the metro system. Attributes: commuter_id (Primary Key), name, email, phone_number.

Employee: Represents employees working in the metro system. Attributes: employee_id (Primary Key), name, position, station_id (Foreign Key).

Feedback: Represents feedback provided by commuters. Attributes: feedback_id (Primary Key), Ticket_system_id (Foreign Key), feedback_text, rating, date.

Views List:

ACCEPTED_SCHEDULE_CHANGE_REQUESTS Provides information about schedule change requests that have been accepted. Access: Only granted to employees.

PENDING_SCHEDULE_CHANGE_REQUESTS Displays pending schedule change requests that require approval. Access: Only granted to employees.

REJECTED_SCHEDULE_CHANGE_REQUESTS Shows schedule change requests that have been rejected. Access: Only granted to employees.

MALDEN_CENTER_SCHEDULE Offers details about schedules related to the Malden Center station. Access: Granted to both employees and commuters.

OAK_GROVE_SCHEDULE Displays schedules associated with the Oak Grove station. Access: Granted to both employees and commuters.

ORANGE_LINE_OUTBOUND_STATIONS Lists stations along the outbound route of the Orange Line. Access: Granted to both employees and commuters.

ORANGELINE_INBOUND Provides data related to inbound trains on the Orange Line. Access: Granted to both employees and commuters.

ORANGELINE_OUTBOUND Provides data related to outbound trains on the Orange Line. Access: Granted to both employees and commuters.

FEEDBACK_WITH_STATION Combines feedback information with station details. Access: Granted to employees for feedback analysis.

Usage:

Employee Access: Employees have access to views related to schedule change requests (ACCEPTED_SCHEDULE_CHANGE_REQUESTS, PENDING_SCHEDULE_CHANGE_REQUESTS, REJECTED_SCHEDULE_CHANGE_REQUESTS). They can view, analyze, and manage schedule change requests using these views. Additionally, employees have access to the FEEDBACK_WITH_STATION view for feedback analysis.

Commuter Access: Commuters have access to views providing schedule information for their convenience (MALDEN_CENTER_SCHEDULE, OAK_GROVE_SCHEDULE, ORANGE_LINE_OUTBOUND_STATIONS, ORANGELINE_INBOUND, ORANGELINE_OUTBOUND). These views help commuters plan their journeys effectively.

