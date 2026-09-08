import mysql.connector as connector

# Task 1
connection = connector.connect(user = "root", password = "4815", db = "LittleLemonDB")
cursor = connection.cursor()

# Task 2
show_tables_query = "SHOW TABLES"
cursor.execute(show_tables_query)
results = cursor.fetchall()
print(results)

# Task 3
join_query = """ SELECT CONCAT(c.Name, ' ', c.LastName) AS FullName, c.PhoneNumber, c.Email FROM Customers c INNER JOIN Bookings b ON c.CustomerID = b.CustomerID INNER JOIN Orders o ON o.BookingID = b.BookingID WHERE o.TotalCost > 60"""
cursor.execute(join_query)
results = cursor.fetchall()
columns = cursor.column_names
print("\n", columns)
for x in results:
    print(x)