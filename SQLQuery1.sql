USE AdventureWorks2019;
GO
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

--List of all customer
SELECT * 
FROM Sales.Customer;

-- List of all customers where company name ends in 'N'
SELECT 
    c.CustomerID,
    s.Name AS CompanyName
FROM Sales.Customer c
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE s.Name LIKE '%n';

--List of all customers who live in Berlin or London
SELECT 
    c.CustomerID,
    ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
    a.City
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON c.CustomerID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');

--List of all customers who live in UK or USA
SELECT 
    c.CustomerID,
    ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
    cr.Name AS Country
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON c.CustomerID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States');

--List of all products sorted by product name
SELECT 
    ProductID,
    Name AS ProductName,
    ProductNumber,
    Color,
    StandardCost,
    ListPrice
FROM Production.Product
ORDER BY Name;

--List of all products where product name starts with an 'A'
SELECT 
    ProductID,
    Name AS ProductName,
    ProductNumber,
    Color,
    StandardCost,
    ListPrice
FROM Production.Product
WHERE Name LIKE 'A%'
ORDER BY Name;

--List of customers who have ever placed an order
SELECT DISTINCT 
    p.ProductID,
    p.Name AS ProductName,
    p.ProductNumber,
    p.Color,
    p.StandardCost,
    p.ListPrice
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
ORDER BY p.Name;

--List of customers who live in London and have bought chai
SELECT DISTINCT 
    c.CustomerID,
    ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
    a.City,
    pr.Name AS ProductName
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON c.CustomerID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
WHERE a.City = 'London'
  AND pr.Name = 'Chai';

--List of customers who never placed an order
  SELECT 
    c.CustomerID,
    ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE soh.SalesOrderID IS NULL;


--List of customers who ordered Tofu
SELECT DISTINCT
    c.CustomerID,
    ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
    pr.Name AS ProductName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE pr.Name = 'Tofu';

--Details of the first order of the system
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    c.CustomerID,
    ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
    pr.ProductID,
    pr.Name AS ProductName,
    sod.OrderQty,
    sod.UnitPrice,
    sod.LineTotal
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
WHERE soh.OrderDate = (
    SELECT MIN(OrderDate)
    FROM Sales.SalesOrderHeader
);


--Find the details of the most expensive order date
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    c.CustomerID,
    ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
    pr.ProductID,
    pr.Name AS ProductName,
    sod.OrderQty,
    sod.UnitPrice,
    sod.LineTotal,
    soh.TotalDue
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
WHERE soh.TotalDue = (
    SELECT MAX(TotalDue)
    FROM Sales.SalesOrderHeader
);

--For each order, get the OrderID and average quantity of items in that order
SELECT 
    SalesOrderID,
    AVG(OrderQty) AS AvgQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

--For each order, get the OrderID, minimum quantity, and maximum quantity for that order
SELECT 
    SalesOrderID,
    MIN(OrderQty) AS MinQuantity,
    MAX(OrderQty) AS MaxQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

--Get a list of all managers and total number of employees who report to them

SELECT 
    m.BusinessEntityID AS ManagerID,
    p.FirstName + ' ' + p.LastName AS ManagerName,
    COUNT(e.BusinessEntityID) AS NumberOfEmployees
FROM HumanResources.Employee e
JOIN HumanResources.Employee m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
JOIN Person.Person p ON m.BusinessEntityID = p.BusinessEntityID
GROUP BY m.BusinessEntityID, p.FirstName, p.LastName;


--Get the OrderID and the total quantity for each order that has a total quantity greater than 300
SELECT 
    SalesOrderID,
    SUM(OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;

  
-- List of all orders placed on or after 1996/12/31
  SELECT *
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';



-- List of all orders shipped to Canada
SELECT *
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada';


--List of all orders with order total > 200
SELECT *
FROM Sales.SalesOrderHeader
WHERE TotalDue > 200;

--List of countries and sales made in each country
SELECT 
    cr.Name AS Country,
    SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name;
--List of customer contact names and number of orders they placed

SELECT 
    p.FirstName + ' ' + p.LastName AS ContactName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName;

--List of customer contact names who have placed more than 3 orders
SELECT 
    p.FirstName + ' ' + p.LastName AS ContactName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(soh.SalesOrderID) > 3;

--List of discontinued products which were ordered between 1/1/1997 and 1/1/1998
SELECT DISTINCT
    p.ProductID,
    p.Name,
    p.DiscontinuedDate
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE p.DiscontinuedDate IS NOT NULL
  AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

-- List of employee first name, last name, supervisor first name, last name
  SELECT 
    e.BusinessEntityID AS EmployeeID,
    ep.FirstName AS EmployeeFirstName,
    ep.LastName AS EmployeeLastName,
    sp.FirstName AS SupervisorFirstName,
    sp.LastName AS SupervisorLastName
FROM HumanResources.Employee e
JOIN Person.Person ep ON e.BusinessEntityID = ep.BusinessEntityID
LEFT JOIN HumanResources.Employee s ON e.OrganizationNode.GetAncestor(1) = s.OrganizationNode
LEFT JOIN Person.Person sp ON s.BusinessEntityID = sp.BusinessEntityID;

-- list of employee IDs and total sales conducted by each employee

SELECT 
    SalesPersonID AS EmployeeID,
    SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID;


-- List of employees whose first name contains the character 'a'
SELECT 
    e.BusinessEntityID,
    p.FirstName,
    p.LastName
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.FirstName LIKE '%a%';

-- List of managers who have more than four people reporting to them

SELECT 
    m.BusinessEntityID AS ManagerID,
    p.FirstName,
    p.LastName,
    COUNT(e.BusinessEntityID) AS ReportCount
FROM HumanResources.Employee e
JOIN HumanResources.Employee m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
JOIN Person.Person p ON m.BusinessEntityID = p.BusinessEntityID
GROUP BY m.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(e.BusinessEntityID) > 4;

--List of orders and product names

SELECT 
    soh.SalesOrderID,
    p.Name AS ProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID;

-- List of orders placed by the best customer

SELECT TOP 1 CustomerID, COUNT(*) AS OrderCount, SUM(TotalDue) AS TotalSpent
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY SUM(TotalDue) DESC;


-- List of orders placed by customers who do not have a fax number
SELECT DISTINCT soh.SalesOrderID, c.CustomerID
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE c.PersonID NOT IN (
    SELECT pp.BusinessEntityID
    FROM Person.PersonPhone pp
    JOIN Person.PhoneNumberType pnt ON pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID
    WHERE pnt.Name = 'Fax'
);

--List of postal codes where the product Tofu was shipped

SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name = 'Tofu';


-- List of product names that were shipped to France

SELECT DISTINCT p.Name
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';

-- List of product names and categories for the supplier 'Specialty Biscuits, Ltd.'

SELECT 
    p.Name AS ProductName,
    pc.Name AS CategoryName
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE v.Name = 'Specialty Biscuits, Ltd.';

--List of products that were never ordered
SELECT p.ProductID, p.Name
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;

--List of products where units in stock is less than 10 and units on order are 0

SELECT p.ProductID, p.Name
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;


--List of top 10 countries by sales
SELECT TOP 10 
    cr.Name AS Country,
    SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;


--Number of orders each employee has taken for customers with CustomerIDs between A and AO
SELECT 
    SalesPersonID,
    COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
WHERE CustomerID BETWEEN 1 AND 1000 -- adjust range if needed
  AND SalesPersonID IS NOT NULL
GROUP BY SalesPersonID;


-- Order date of most expensive order
SELECT TOP 1 
    SalesOrderID,
    OrderDate,
    TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

-- Product name and total revenue from that product

SELECT 
    p.Name AS ProductName,
    SUM(sod.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalRevenue DESC;

--Supplier ID and number of products offered
SELECT 
    v.BusinessEntityID AS SupplierID,
    COUNT(pv.ProductID) AS ProductCount
FROM Purchasing.Vendor v
JOIN Purchasing.ProductVendor pv ON v.BusinessEntityID = pv.BusinessEntityID
GROUP BY v.BusinessEntityID;

--Top ten customers based on their business
SELECT TOP 10 
    c.CustomerID,
    ISNULL(p.FirstName + ' ' + p.LastName, s.Name) AS CustomerName,
    SUM(soh.TotalDue) AS TotalSpent
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
GROUP BY c.CustomerID, p.FirstName, p.LastName, s.Name
ORDER BY TotalSpent DESC;


--What is the total revenue of the company
SELECT SUM(TotalDue) AS TotalCompanyRevenue
FROM Sales.SalesOrderHeader;






