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