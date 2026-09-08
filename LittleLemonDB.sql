# Exercise: Create a virtual table to summarize data
# Task 1
CREATE VIEW OrdersView AS (
SELECT OrderID, Quantity, Cost FROM OrderDetails
);

SELECT * FROM OrdersView WHERE Quantity > 1;

# Task 2
SELECT c.CustomerID, CONCAT(c.Name, ' ', c.LastName) AS FullName, o.OrderID, o.Cost, m.ProductName
FROM Customers c
INNER JOIN Bookings b ON c.CustomerID = b.CustomerID
INNER JOIN Orders ord ON b.BookingID = ord.BookingID
INNER JOIN OrderDetails o ON ord.OrderID = o.OrderID
INNER JOIN Menu m ON o.ProductID = m.ProductID
ORDER BY o.Cost ASC;

# Task 3
SELECT ProductName FROM Menu
WHERE ProductID = ANY (
	SELECT ProductID
    FROM OrderDetails
    WHERE Quantity > 1
);

# Exercise: Create optimized queries to manage and analyze data
# Task 1
DROP PROCEDURE IF EXISTS GetMaxQuantity;
DELIMITER //
CREATE PROCEDURE GetMaxQuantity()
BEGIN
	SELECT MAX(Quantity) AS "Max Quantity in Order" FROM OrderDetails;
END //
DELIMITER ;

CALL GetMaxQuantity();

# Task 2
SET @id = 1;

PREPARE GetOrderDetails FROM
'
SELECT 
    o.OrderID, 
    o.Quantity, 
    o.Cost
FROM OrderDetails o
INNER JOIN Orders ord 
    ON ord.OrderID = o.OrderID
INNER JOIN Bookings b 
    ON b.BookingID = ord.BookingID
INNER JOIN Customers c 
    ON b.CustomerID = c.CustomerID
WHERE c.CustomerID = ?
';

EXECUTE GetOrderDetails USING @id;
DEALLOCATE PREPARE GetOrderDetails;

# Task 3
DROP PROCEDURE IF EXISTS CancelOrder;
DELIMITER //
CREATE PROCEDURE CancelOrder(id INT)
BEGIN
	DELETE FROM OrderDeliveryStatus WHERE OrderID = id;
    DELETE FROM OrderDetails WHERE OrderID = id;
	DELETE FROM Orders WHERE OrderID = id;
	SELECT CONCAT('Order ', id, ' is cancelled') AS Confirmation;
END //
DELIMITER ;

CALL CancelOrder(5);

# Exercise: Create SQL queries to check available bookings based on user input
# Task 1
INSERT INTO Bookings (BookingID, BookingDate, TableNumber, CustomerID, EmployeeID) VALUES 
(11, '2022-10-10', 5, 1, 1), 
(12, '2022-11-12', 3, 3, 1), 
(13, '2022-10-11', 2, 2, 2),
(14, '2022-10-13', 2, 1, 3);
SELECT * FROM Bookings;

# Task 2
DROP PROCEDURE IF EXISTS CheckBooking;
DELIMITER //
CREATE PROCEDURE CheckBooking(bk_date DATE, id INT)
BEGIN
	SELECT (CASE
		WHEN id IN (SELECT TableNumber FROM Bookings WHERE BookingDate = bk_date) THEN CONCAT('Table ', id, ' is already booked')
        ELSE CONCAT('Table ', id, ' is free')
        END) AS "Booking status";
END //
DELIMITER ;

CALL CheckBooking('2022-11-12', 3);

# Task 3
DROP PROCEDURE IF EXISTS AddValidBooking;

DELIMITER //

CREATE PROCEDURE AddValidBooking(bk_date DATE, id INT)
BEGIN
    DECLARE table_count INT DEFAULT 0;
    DECLARE new_booking_id INT DEFAULT 0;

    START TRANSACTION;

    SELECT COALESCE(MAX(BookingID), 0) + 1
    INTO new_booking_id
    FROM Bookings;

    INSERT INTO Bookings (
        BookingID,
        CustomerID,
        TableNumber,
        BookingDate,
        EmployeeID
    )
    VALUES (
        new_booking_id,
        1,
        id,
        bk_date,
        1
    );

    SELECT COUNT(*)
    INTO table_count
    FROM Bookings
    WHERE BookingDate = bk_date
      AND TableNumber = id;

    IF table_count > 1 THEN
        ROLLBACK;
        SELECT CONCAT(
            'Table ', id, ' is already booked - booking cancelled'
        ) AS "Booking status";
    ELSE
        COMMIT;
        SELECT CONCAT(
            'Table ', id, ' is free - booking successful'
        ) AS "Booking status";
    END IF;
END //

DELIMITER ;

CALL AddValidBooking("2022-12-17", 6);

# Exercise: Create SQL queries to add and update bookings
# Task 1
DROP PROCEDURE IF EXISTS AddBooking;
DELIMITER //
CREATE PROCEDURE AddBooking(bk_id INT, ct_id INT, bk_date DATE, em_id INT, tb_id INT)
BEGIN
	INSERT INTO Bookings (BookingID, CustomerID, BookingDate, EmployeeID, TableNumber)
    VALUES (bk_id, ct_id, bk_date, em_id, tb_id);
    SELECT 'New booking added' as Confirmation;
END //
DELIMITER ;

CALL AddBooking(20, 1, "2022-12-18", 3, 5);

# Task 2
DROP PROCEDURE IF EXISTS UpdateBooking;
DELIMITER //
CREATE PROCEDURE UpdateBooking(bk_id INT, bk_date DATE)
BEGIN
	UPDATE Bookings SET BookingDate = bk_date WHERE BookingID = bk_id;
	SELECT CONCAT('Booking ', bk_id, ' updated') as Confirmation;
END //
DELIMITER ;

CALL UpdateBooking(9, "2022-12-17");

# Task 3
DROP PROCEDURE IF EXISTS CancelBooking;
DELIMITER //
CREATE PROCEDURE CancelBooking(id INT)
BEGIN
	DELETE FROM Bookings WHERE BookingID = id;
    SELECT CONCAT('Booking ', id, ' cancelled') as Confirmation;
END //
DELIMITER ;

CALL CancelBooking(20);
