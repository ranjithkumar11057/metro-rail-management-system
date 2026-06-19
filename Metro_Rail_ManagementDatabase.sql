 CREATE DATABASE metro_rail_db;
USE metro_rail_db;
CREATE TABLE Metro_Cities (
    City_Id         INT           NOT NULL,
    City_Name       VARCHAR(50)   NOT NULL,
    State           VARCHAR(50)   NOT NULL,
    Metro_Operator  VARCHAR(60)   NOT NULL,
    Opening_Year    YEAR          NOT NULL,
    PRIMARY KEY (City_Id)
) ENGINE=InnoDB;
 select * from Stations
 CREATE TABLE Stations (
    Station_Id     INT           NOT NULL,
    City_Id        INT           NOT NULL,
    Station_Name   VARCHAR(60)   NOT NULL,
    Station_Code   VARCHAR(10)   NOT NULL,
    Zone           VARCHAR(10)   NOT NULL,
    Opening_Date   DATE          NOT NULL,
    PRIMARY KEY (Station_Id),
    UNIQUE KEY uq_station_code (Station_Code),
    CONSTRAINT fk_station_city FOREIGN KEY (City_Id) REFERENCES Metro_Cities(City_Id)
) ENGINE=InnoDB;
desc Stations
 select * from Routes
 CREATE TABLE Routes (
    Route_Id          INT           NOT NULL,
    Route_Name        VARCHAR(40)   NOT NULL,
    City_Id           INT           NOT NULL,
    Start_Station_Id  INT           NOT NULL,
    End_Station_Id    INT           NOT NULL,
    Distance_Km       DECIMAL(6,2)  NOT NULL,
    PRIMARY KEY (Route_Id),
    CONSTRAINT fk_route_city  FOREIGN KEY (City_Id)          REFERENCES Metro_Cities(City_Id),
    CONSTRAINT fk_route_start FOREIGN KEY (Start_Station_Id) REFERENCES Stations(Station_Id),
    CONSTRAINT fk_route_end   FOREIGN KEY (End_Station_Id)   REFERENCES Stations(Station_Id)
) ENGINE=InnoDB;
  select * from Trains
  CREATE TABLE Trains (
    Train_Id          INT           NOT NULL,
    Route_Id          INT           NOT NULL,
    Train_Number      VARCHAR(15)   NOT NULL,
    Manufacturer      VARCHAR(20)   NOT NULL,
    Capacity          INT           NOT NULL,
    Commission_Date   DATE          NOT NULL,
    PRIMARY KEY (Train_Id),
    UNIQUE KEY uq_train_number (Train_Number),
    CONSTRAINT fk_train_route FOREIGN KEY (Route_Id) REFERENCES Routes(Route_Id)
) ENGINE=InnoDB;
  select * from Trains
  
  CREATE TABLE Passengers (
    Passenger_Id        INT           NOT NULL,
    First_Name          VARCHAR(40)   NOT NULL,
    Last_Name            VARCHAR(40)   NOT NULL,
    Gender               VARCHAR(10)   NOT NULL,
    Age                  INT           NOT NULL,
    Phone                VARCHAR(15)   NOT NULL,
    Email                VARCHAR(80)   NOT NULL,
    City_Id              INT           NOT NULL,
    Registration_Date    DATE          NOT NULL,
    PRIMARY KEY (Passenger_Id),
    CONSTRAINT fk_passenger_city FOREIGN KEY (City_Id) REFERENCES Metro_Cities(City_Id)
) ENGINE=InnoDB;

select count(*) from Tickets
CREATE TABLE Smart_Cards (
    Card_Id        INT            NOT NULL,
    Passenger_Id   INT            NOT NULL,
    Card_Number    VARCHAR(12)    NOT NULL,
    Issue_Date     DATE           NOT NULL,
    Balance        DECIMAL(10,2)  NOT NULL,
    Status         VARCHAR(10)    NOT NULL,
    PRIMARY KEY (Card_Id),
    UNIQUE KEY uq_card_number (Card_Number),
    CONSTRAINT fk_card_passenger FOREIGN KEY (Passenger_Id) REFERENCES Passengers(Passenger_Id)
) ENGINE=InnoDB;

CREATE TABLE Tickets (
    Ticket_Id               INT            NOT NULL,
    Passenger_Id             INT            NOT NULL,
    Source_Station_Id        INT            NOT NULL,
    Destination_Station_Id   INT            NOT NULL,
    Journey_Date              DATE           NOT NULL,
    Fare                       DECIMAL(8,2)   NOT NULL,
    Ticket_Type                 VARCHAR(20)    NOT NULL,
    PRIMARY KEY (Ticket_Id),
    CONSTRAINT fk_ticket_passenger FOREIGN KEY (Passenger_Id)            REFERENCES Passengers(Passenger_Id),
    CONSTRAINT fk_ticket_src       FOREIGN KEY (Source_Station_Id)       REFERENCES Stations(Station_Id),
    CONSTRAINT fk_ticket_dst       FOREIGN KEY (Destination_Station_Id)  REFERENCES Stations(Station_Id)
) ENGINE=InnoDB;

CREATE TABLE Payments (
    Payment_Id      INT            NOT NULL,
    Ticket_Id       INT            NOT NULL,
    Payment_Date    DATE           NOT NULL,
    Amount          DECIMAL(8,2)   NOT NULL,
    Payment_Method  VARCHAR(20)    NOT NULL,
    Payment_Status  VARCHAR(10)    NOT NULL,
    PRIMARY KEY (Payment_Id),
    CONSTRAINT fk_payment_ticket FOREIGN KEY (Ticket_Id) REFERENCES Tickets(Ticket_Id)
) ENGINE=InnoDB;
 
 CREATE TABLE Employees (
    Employee_Id    INT            NOT NULL,
    Station_Id     INT            NOT NULL,
    Employee_Name  VARCHAR(40)    NOT NULL,
    Designation    VARCHAR(30)    NOT NULL,
    Joining_Date   DATE           NOT NULL,
    Salary         DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (Employee_Id),
    CONSTRAINT fk_employee_station FOREIGN KEY (Station_Id) REFERENCES Stations(Station_Id)
) ENGINE=InnoDB;

CREATE TABLE Maintenance_Logs (
    Maintenance_Id     INT            NOT NULL,
    Train_Id           INT            NOT NULL,
    Employee_Id        INT            NOT NULL,
    Maintenance_Date   DATE           NOT NULL,
    Issue_Reported     VARCHAR(30)    NOT NULL,
    Maintenance_Cost   DECIMAL(10,2)  NOT NULL,
    Status             VARCHAR(15)    NOT NULL,
    PRIMARY KEY (Maintenance_Id),
    CONSTRAINT fk_mlog_train    FOREIGN KEY (Train_Id)    REFERENCES Trains(Train_Id),
    CONSTRAINT fk_mlog_employee FOREIGN KEY (Employee_Id) REFERENCES Employees(Employee_Id)
) ENGINE=InnoDB;
 select * from Maintenance_Logs
 
 =====================================================
--  1. Total passengers registered in each city
SELECT mc.city_name,
       COUNT(p.passenger_id) AS total_passengers
FROM Passengers p
JOIN Metro_Cities mc
ON p.city_id = mc.city_id
GROUP BY mc.city_name;
select * from Tickets
-- 2. Total revenue collected by payment method
SELECT payment_method,
       SUM(amount) AS total_revenue
FROM Payments
WHERE payment_status='Success'
GROUP BY payment_method;
select * from Payments
-- 3. Average fare by ticket type
SELECT ticket_type,
       AVG(fare) AS avg_fare
FROM Tickets
GROUP BY ticket_type;
-- 4. Total employees by designation
SELECT designation,
       COUNT(*) employee_count
FROM Employees
GROUP BY designation;
=====================================================
-- Top 3 Busiest Stations
-- Find stations with maximum passenger traffic.
SELECT
    s.station_name,
    COUNT(*) total_journeys
FROM Tickets t
JOIN Stations s
ON t.source_station_id=s.station_id
GROUP BY s.station_name
ORDER BY total_journeys DESC
LIMIT 10


-- 5. Maintenance cost by train
SELECT train_id,
       SUM(maintenance_cost) total_cost
FROM Maintenance_Logs
GROUP BY train_id;
=======================================

-- 2. Subqueries
-- 2. Employees earning above average salary

SELECT *
FROM Employees
WHERE salary >
(
   SELECT AVG(salary)
   FROM Employees
);
------------------------------------------
-- Passengers who have booked at least one ticket
SELECT *
FROM Passengers p
WHERE EXISTS
(
    SELECT 1
    FROM Tickets t
    WHERE t.passenger_id = p.passenger_id
);
=======================================================
-- Revenue by Month and City
-- Joins
SELECT
    mc.city_name,
    YEAR(p.payment_date) AS year,
    MONTH(p.payment_date) AS month,
    SUM(p.amount) AS revenue
FROM Payments p
JOIN Tickets t ON p.ticket_id = t.ticket_id
JOIN Stations s ON t.source_station_id = s.station_id
JOIN Metro_Cities mc ON s.city_id = mc.city_id
GROUP BY mc.city_name,
         YEAR(p.payment_date),
         MONTH(p.payment_date)
ORDER BY mc.city_name,
         year,
         month;
====================================================
-- Top 5 Revenue Generating Cities
SELECT
    mc.city_name,
    SUM(p.amount) total_revenue
FROM Payments p
JOIN Tickets t
ON p.ticket_id=t.ticket_id
JOIN Stations s
ON t.source_station_id=s.station_id
JOIN Metro_Cities mc
ON s.city_id=mc.city_id
GROUP BY mc.city_name
ORDER BY total_revenue DESC
LIMIT 5;

select * from payments
-- Most Profitable Route
-- Management wants to identify high-revenue routes.
SELECT
    r.route_name,
    SUM(t.fare) total_revenue
FROM Routes r
JOIN Tickets t
ON r.start_station_id=t.source_station_id
GROUP BY r.route_name
ORDER BY total_revenue DESC;
select * from Routes

==========================================
-- Yearly ,Monthly Revenue Trend
SELECT
    YEAR(payment_date) year,
    MONTH(payment_date) month,
    SUM(amount) revenue
FROM Payments
GROUP BY YEAR(payment_date),
         MONTH(payment_date)
ORDER BY year,month;
==================================================
-- Top 5 Frequent Travelers
SELECT
    passenger_id,
    COUNT(*) total_trips
FROM Tickets
GROUP BY passenger_id
ORDER BY total_trips DESC
LIMIT 5;
===============================================
-- Stations With No Employees
SELECT station_name
FROM Stations
WHERE station_id NOT IN
(
   SELECT station_id
   FROM Employees
);
-- method:2
SELECT
    s.station_name
FROM Stations s
LEFT JOIN Employees e
ON s.station_id = e.station_id
WHERE e.employee_id IS NULL;
===================================================
-- Which passengers have never purchased a metro ticket?
SELECT
    p.passenger_id,
    CONCAT(p.first_name,' ',p.last_name) AS full_name
FROM Passengers p
LEFT JOIN Tickets t
    ON p.passenger_id = t.passenger_id
WHERE t.ticket_id IS NULL;
=======================================
-- window functions 
SELECT
    passenger_id,
    COUNT(*) total_trips,
    DENSE_RANK() OVER(
        ORDER BY COUNT(*) DESC
    ) traveler_rank
FROM Tickets
GROUP BY passenger_id;

-- What is the cumulative revenue earned by the metro system over time?
SELECT
    payment_date,
    amount,
    SUM(amount)
    OVER(ORDER BY payment_date ) running_total
FROM Payments;
===================================================
-- CTE(Common Table Expression) 
-- Who are the Top 5 Most Frequent Metro Travelers?
WITH Passenger_Trips AS
(
    SELECT
        passenger_id,
        COUNT(*) AS total_trips
    FROM Tickets
    GROUP BY passenger_id
)

SELECT
    passenger_id,
    total_trips
FROM Passenger_Trips
ORDER BY total_trips DESC
LIMIT 5;
-----------------------------------------------
-- Rank Passengers Based on Total Trips
WITH Passenger_Trips AS
(
    SELECT
        passenger_id,
        COUNT(*) total_trips
    FROM Tickets
    GROUP BY passenger_id
)
SELECT
    passenger_id,
    total_trips,
    DENSE_RANK() OVER(
        ORDER BY total_trips DESC
    ) traveler_rank
FROM Passenger_Trips;

=================================================
-- views
-- Which passengers have smart cards, and what is their current card balance and status?
CREATE VIEW vw_smart_card_summary AS
SELECT
    p.passenger_id,
    CONCAT(p.first_name,' ',p.last_name) AS full_name,
    sc.card_number,
    sc.balance,
    sc.status
FROM Passengers p
JOIN Smart_Cards sc
ON p.passenger_id = sc.passenger_id;

SELECT *
FROM vw_smart_card_summary;
-------------------------------------------------
-- Which Smart Card holders are the most active metro travelers, and how many trips have they completed?
SELECT
    p.passenger_id,
    CONCAT(p.first_name,' ',p.last_name) AS full_name,
    sc.card_number,
    COUNT(t.ticket_id) AS total_trips
FROM Passengers p
JOIN Smart_Cards sc
    ON p.passenger_id = sc.passenger_id
LEFT JOIN Tickets t
    ON p.passenger_id = t.passenger_id
GROUP BY
    p.passenger_id,
    p.first_name,
    p.last_name,
    sc.card_number
ORDER BY total_trips DESC;
======================================================
-- Stored Procedures
-- Get Passenger Travel History
DELIMITER $$

CREATE PROCEDURE GetPassengerTravelHistory
(
    IN p_passenger_id INT
)
BEGIN

SELECT
    ticket_id,
    source_station_id,
    destination_station_id,
    journey_date,
    fare
FROM Tickets
WHERE passenger_id = p_passenger_id;

CALL GetPassengerTravelHistory(101);

-------------------------------------------------------------
-- GetRevenueBetweenDates
DELIMITER $$

CREATE PROCEDURE GetRevenueBetweenDates
(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN

SELECT
    SUM(amount) AS total_revenue
FROM Payments
WHERE payment_status='Success'
AND payment_date BETWEEN p_start_date AND p_end_date;

END $$
DELIMITER ;


CALL GetRevenueBetweenDates(
'2025-01-01',
'2025-12-31'
);
-------------------------------------------
-- Who are the Top 10 Metro Travelers?
DELIMITER $$

CREATE PROCEDURE GetTopTravelers()
BEGIN

SELECT
    p.passenger_id,
    CONCAT(p.first_name,' ',p.last_name) AS full_name,
    COUNT(t.ticket_id) AS total_trips
FROM Passengers p
JOIN Tickets t
ON p.passenger_id=t.passenger_id
GROUP BY
    p.passenger_id,
    p.first_name,
    p.last_name
ORDER BY total_trips DESC
LIMIT 10;

END $$

DELIMITER ;
-------------------------------------------------------------
SHOW CREATE PROCEDURE GetRevenueBetweenDates;
=================================================================
-- Triggers
-- Prevent Negative Fare
-- Prevent inserting tickets with a negative fare.
DELIMITER $$

CREATE TRIGGER trg_check_ticket_fare

BEFORE INSERT
ON Tickets
FOR EACH ROW
BEGIN

IF NEW.fare < 0 THEN

SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Fare cannot be negative';

END IF;
END $$
DELIMITER ;
SHOW TRIGGERS;
----------------------
INSERT INTO Tickets
(
    Ticket_Id,
    Passenger_Id,
    Source_Station_Id,
    Destination_Station_Id,
    Journey_Date,
    Fare,
    Ticket_Type
)
VALUES
(
    20001,
    1,
    101,
    102,
    '2026-06-18',
    -50.00,
    'Single Journey'
);
-----------------------------------------------------------------------
-- If Maintenance_Cost > 10000, mark it as 'Major Repair'.
DELIMITER $$

CREATE TRIGGER trg_major_repair
BEFORE INSERT
ON Maintenance_Logs
FOR EACH ROW
BEGIN
    IF NEW.Maintenance_Cost > 10000 THEN
        SET NEW.Status = 'Major Repair';
    END IF;
END $$

DELIMITER ;
select * from Maintenance_Logs
INSERT INTO Maintenance_Logs
VALUES
(1002,1,1,'2025-06-18','Engine Issue',15000,'Pending');
-----------------------------------------------------------------------------
-- 3. Prevent Same Source and Destination Station
DELIMITER $$

CREATE TRIGGER trg_check_station
BEFORE INSERT
ON Tickets
FOR EACH ROW
BEGIN
    IF NEW.Source_Station_Id = NEW.Destination_Station_Id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Source and Destination cannot be same';
    END IF;
END $$

DELIMITER ;

INSERT INTO Tickets
VALUES
(20003,1,101,101,'2026-06-20',150,'Single Journey');
====================================================================================================
-- 1. Tickets Table
CREATE INDEX idx_ticket_passenger
ON Tickets(passenger_id);

CREATE INDEX idx_ticket_source_station
ON Tickets(source_station_id);

CREATE INDEX idx_ticket_destination_station
ON Tickets(destination_station_id);

CREATE INDEX idx_ticket_journey_date
ON Tickets(journey_date);

CREATE INDEX idx_ticket_type
ON Tickets(ticket_type);

show index from Tickets

select * from maintenance_logs

SHOW INDEXES FROM Payments;

CREATE INDEX idx_payment_status_date
ON Payments(payment_status, payment_date);
=================================================================================================================

CREATE INDEX idx_employee_station
ON Employees(station_id);

CREATE INDEX idx_maintenance_train
ON Maintenance_Logs(train_id);

CREATE INDEX idx_station_city
ON Stations(city_id);
======================================================= 
-- Business Questions
-- 1.Total passengers registered in each city?
-- 2. Which payment methods generate the most revenue?
-- 3. What is the average fare paid by passengers?
-- 4. Which stations are the busiest?
-- 5. Which cities generate the highest revenue?
-- 6. Which routes are most profitable?
-- 7. How is revenue changing over time?
-- 8. Who are the most frequent travelers?
-- 9. Which passengers never purchased tickets?
-- 10. Which stations have no employees?
-- 11. What is the maintenance cost of each train?
-- 12. What is cumulative revenue over time?
