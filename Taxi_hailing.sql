-- create the user table 

CREATE TABLE Users (
  user_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  firstname VARCHAR(255) NOT NULL,
  lastname VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL
);

-- create the driver's table
CREATE TABLE Drivers (
  driver_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  user_id INTEGER NOT NULL,
  license_number VARCHAR(50) UNIQUE NOT NULL,
  rating FLOAT DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- create the rider's table
CREATE TABLE Riders (
  rider_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  user_id INTEGER NOT NULL,
  is_driver BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- create the vehicles' table 
CREATE TABLE Vehicles (
  vehicle_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  driver_id INTEGER NOT NULL,
  make VARCHAR(50) NOT NULL,
  model VARCHAR(50) NOT NULL,
  year INTEGER NOT NULL,
  license_plate_number VARCHAR(20) UNIQUE NOT NULL,
  FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id) ON DELETE CASCADE
);
-- create the rides' table 

CREATE TABLE Rides (
  ride_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  pickup_location VARCHAR(255) NOT NULL,
  destination VARCHAR(255) NOT NULL,
  ride_status ENUM('requested', 'accepted', 'in_progress', 'completed') NOT NULL DEFAULT 'requested',
  ride_start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ride_end_time TIMESTAMP NULL DEFAULT NULL,
  driver_id INTEGER,
  user_id INTEGER,
  CONSTRAINT fk_rides_drivers FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id) ON DELETE SET NULL,
  CONSTRAINT fk_rides_users FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- create rating's table

CREATE TABLE Ratings (
  rating_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  driver_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  ride_id INTEGER NOT NULL,
  rating_value INTEGER NOT NULL,
  FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (ride_id) REFERENCES Rides(ride_id) ON DELETE CASCADE
);

-- create the RideReceipts

CREATE TABLE RideReceipts (
  receipt_id INTEGER PRIMARY KEY AUTO_INCREMENT,
  ride_id INTEGER NOT NULL,
  driver_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  pickup_location VARCHAR(255) NOT NULL,
  destination VARCHAR(255) NOT NULL,
  pickup_time TIMESTAMP NULL DEFAULT NULL,
  dropoff_time TIMESTAMP NULL DEFAULT NULL,
  receipt_issued_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fare_amount DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (ride_id) REFERENCES Rides(ride_id) ON DELETE CASCADE,
  FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- insert users
INSERT INTO Users (user_id, firstname, lastname, email, password)
VALUES
  (1, 'John', 'Doe', 'john.doe@example.com', 'password1'),
  (2, 'Jane', 'Doe', 'jane.doe@example.com', 'password2'),
  (3, 'Bob', 'Smith', 'bob.smith@example.com', 'password3'),
  (4, 'Alice', 'Lee', 'alice.lee@example.com', 'password4'),
  (5, 'Mark', 'Johnson', 'mark.johnson@example.com', 'password5');


-- insert drivers
INSERT INTO Drivers (driver_id, user_id, license_number, rating)
VALUES
  (1, 2, 'ABC123', 4.5),
  (2, 4, 'DEF456', 4.2);


-- insert riders
INSERT INTO Riders (rider_id, user_id, is_driver)
VALUES
  (1, 1, FALSE),
  (2, 3, FALSE),
  (3, 4, TRUE),
  (4, 5, FALSE);


-- insert vehicles
INSERT INTO Vehicles (vehicle_id, driver_id, make, model, year, license_plate_number)
VALUES
  (1, 1, 'Toyota', 'Camry', 2019, 'XYZ789'),
  (2, 2, 'Honda', 'Accord', 2018, 'UVW246'),
  (3, 2, 'Ford', 'Mustang', 2020, 'MNO012');

  -- insert ratings
INSERT INTO Ratings (rating_id, driver_id, user_id, ride_id, rating_value)
VALUES
(1, 1, 2, 1, 4),
(2, 2, 4, 2, 3),
(3, 1, 4, 4, 5),
(4, 2, 3, 6, 4),
(5, 1, 2, 5, 2),
(6, 2, 4, 2, 5),
(7, 1, 3, 1, 3);

-- insert rides
INSERT INTO Rides (ride_id, pickup_location, destination, ride_status, ride_start_time, ride_end_time, driver_id, user_id)
VALUES
  (1, '123 Main St', '456 Elm St', 'completed', '2023-04-17 10:00:00', '2023-04-17 10:30:00', 1, 1),
  (2, '789 Oak St', '321 Maple St', 'in_progress', '2023-04-17 11:00:00', NULL, 2, 2),
  (3, '456 Elm St', '123 Main St', 'requested', '2023-04-17 12:00:00', NULL, NULL, 3),
  (4, '321 Maple St', '789 Oak St', 'accepted', '2023-04-17 13:00:00', NULL, 1, 4);
-- add another ride
  
-- insert ride receipts
INSERT INTO RideReceipts (receipt_id, ride_id, driver_id, user_id, pickup_location, destination, pickup_time, dropoff_time, receipt_issued_time, fare_amount)
VALUES
  (1, 1, 1, 1, '123 Main St', '456 Elm St', '2023-04-17 10:00:00', '2023-04-17 10:30:00', '2023-04-17 10:35:00', 25.00),
  (2, 2, 2, 2, '789 Oak St', '321 Maple St', '2023-04-17 11:00:00', NULL, '2023-04-17 11:15:00', 20.00),
  (3, 3, 2, 3, '456 Elm St', '123 Main St', '2023-04-17 12:00:00', NULL, '2023-04-17 12:05:00', 30.00),
  (4, 4, 1, 4, '321 Maple St', '789 Oak St', '2023-04-17 13:00:00', NULL, '2023-04-17 13:20:00', 22.50);



-- create view to generate receipt 

CREATE VIEW RideReceiptsView AS
SELECT
  rr.receipt_id,
  r.ride_id,
  CONCAT(u.firstname, ' ', u.lastname) AS rider_name,
  CONCAT(d.firstname, ' ', d.lastname) AS driver_name,
  rr.pickup_location,
  rr.destination,
  rr.pickup_time,
  rr.dropoff_time,
  rr.receipt_issued_time,
  rr.fare_amount
FROM
  RideReceipts rr
  JOIN Rides r ON rr.ride_id = r.ride_id
  JOIN Users u ON rr.user_id = u.user_id
  JOIN Drivers dr ON rr.driver_id = dr.driver_id
  JOIN Users d ON dr.user_id = d.user_id;

-- get receipt
SELECT * FROM RideReceiptsView; 

-- this PROCEDURE sets the rider status to true
DELIMITER //
CREATE PROCEDURE set_user_as_driver (IN p_user_id INT)
BEGIN
  UPDATE Riders SET is_driver = TRUE WHERE user_id = p_user_id;
END //
DELIMITER ;

-- set the rider to be a driver
CALL set_user_as_driver(3);  

-- while this PROCEDURE returns it to false
DELIMITER //
CREATE PROCEDURE set_rider_not_driver (IN p_user_id INT)
BEGIN
  UPDATE Riders SET is_driver = FALSE WHERE user_id = p_user_id;
END //
DELIMITER ;

-- set back to false 
CALL set_rider_not_driver(3);  


-- for some reason the trigger is not working maybe i am doing something wrong
-- create a trigger that logs when a rating is deleted
CREATE TRIGGER log_ratings_delete
AFTER DELETE ON ratings
FOR EACH ROW
BEGIN
  INSERT INTO rating_deletion_logs (rating_id, deleted_at)
  VALUES (OLD.rating_id, NOW());
END;
