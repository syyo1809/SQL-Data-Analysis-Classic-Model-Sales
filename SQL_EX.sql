-- Select, From & Where Statement
SELECT *
FROM customers
WHERE contactLastName <> 'young';

SELECT customerName, contactFirstName, contactLastName, phone, city, country
FROM customers
where country = 'USA' and contactFirstName = 'Julie'

SELECT contactFirstName, contactLastName, city, country
FROM customers
WHERE country = 'Norway'
OR country = 'Sweden'
-- Select Statement Q & A
SELECT *
FROM customers
WHERE (country = 'USA' or country = 'UK') and contactLastName = 'Brown'

select email
from employees
where jobTitle = 'Sales Rep'

-- Upper & Lower
select *
from employees
where lower(firstName) = 'leslie'

select *
from employees
where upper(email) = 'DMURPHY@CLASSICMODELCARS.COM'; -- control + shift + u

select *, upper(firstName) as uppercasename
from employees

-- In & Not In
select * 
from employees
where upper(email) in ( 'DMURPHY@CLASSICMODELCARS.COM', 'MPATTERSO@CLASSICMODELCARS.COM', 'ABOW@CLASSICMODELCARS.COM' )

select * 
from employees
where upper(email) not in ( 'DMURPHY@CLASSICMODELCARS.COM', 'MPATTERSO@CLASSICMODELCARS.COM', 'ABOW@CLASSICMODELCARS.COM' )

-- Distinct, Like & Order By
select *
from customers
where city like '%New%';

SELECT *
FROM employees
ORDER BY lastName DESC, firstName DESC

-- Examples of Distinct and Like
SELECT DISTINCT orderdate
FROM classicmodels.orders
ORDER BY orderdate

SELECT *
FROM classicmodels.orders
WHERE comments LIKE '%negotiate%'

-- Inner Join
SELECT *
FROM orders
WHERE ordernumber = 10100;

SELECT *
FROM customers
WHERE customernumber = 363;

select *
from orders T1
inner join customers T2  -- join as default of inner join
on T1.customernumber = T2.customernumber
where T1.customernumber = 363

-- Left & Right Join
SELECT
*
FROM classicmodels.employees t1
LEFT JOIN classicmodels.customers t2
ON t1.employeenumber = t2.salesrepemployeenumber
WHERE t2.customernumber IS NULL
AND jobtitle = 'Sales Rep'

-- Example and Use Case of Joins
SELECT A.customerName, B.amount, B.paymentDate
FROM classicmodels.customers A
LEFT JOIN classicmodels.payments B
ON A.customerNumber = B.customerNumber
WHERE B.customerNumber IS NULL
;

/*
show the customer first name, last name, orderdate and status for each order in the orders table with a matching customer in the
customer table. 
*/
SELECT t2.contactFirstName, t2.contactLastName, t1.orderDate, t1.status
FROM orders t1
INNER JOIN customers t2
ON t1.customerNumber = t2.customerNumber;

/*
Display the first name and last name of all customers, and the order date and ordernumber of all their orders, 
even if the customer made no orders.alter
*/
SELECT t1.contactFirstName, t1.contactLastName, t2.orderDate, t2.orderNumber
FROM customers t1
LEFT JOIN orders t2
ON t1.customerNumber = t2.customerNumber
WHERE t2.orderNumber IS NOT NULL

-- Union & Union All
SELECT *
FROM customers;

SELECT *
FROM employees;

SELECT 'customer' as type, contactFirstName as firstname, contactLastName as lastname, city
FROM customers
UNION
SELECT 'employee' as type, firstname, lastname, 'unknow' as city
FROM employees

-- Sum, Round, Group by & Having
SELECT paymentDate, sum(amount) as total_payment
FROM payments
GROUP BY paymentDate
ORDER BY paymentDate

SELECT paymentDate, ROUND(SUM(amount),1) as total_payments
FROM payments
GROUP BY paymentDate
ORDER BY paymentDate

SELECT paymentDate, SUM(amount) as total_payments
FROM classicmodels.payments
GROUP BY paymentDate
HAVING total_payments > 50000
ORDER BY total_payments DESC

-- Count, Max, Min, Avg
SELECT COUNT(ordernumber) as orders
FROM orders

SELECT productcode, count(ordernumber) AS orders
FROM orderdetails
GROUP BY productcode

SELECT paymentDate, MAX(amount) AS highest_payment, MIN(amount) AS lowest_payment
FROM payments
GROUP BY paymentDate
HAVING paymentDate = '2003=12-09'

SELECT  paymentDate, AVG(amount) as avg_payment_received
FROM payments
GROUP BY paymentDate
ORDER BY paymentDate

/*
Show the coutomer name of the company which made the most amount of orders.
*/
SELECT customerName, COUNT(orderNumber) AS orders
FROM orders t1
INNER JOIN customers t2
ON t1.customerNumber = t2.customerNumber
GROUP BY customerName
ORDER BY 2 DESC
LIMIT 5 ;

/*
Display each customers first and last order date.
*/
SELECT customerName, MIN(orderDate) AS first_orderdate, MAX(orderDate) AS latest_orderdate
FROM orders t1
INNER JOIN customers t2
ON t1.customerNumber = t2.customerNumber
GROUP BY customerName

-- Subquery
SELECT *
FROM
(SELECT orderDate, COUNT(orderNumber) AS orders
FROM orders
GROUP BY orderDate) AS t1
WHERE orderDate > '2005-05-01'

-- Common Table Expression(CTE)
WITH cte_orders AS 
(SELECT orderDate, COUNT(orderNumber) AS orders
FROM orders
GROUP BY orderDate) 
SELECT AVG(orders)
FROM cte_orders
WHERE orderDate > '2005-05-01'

WITH cte_orders AS 
(SELECT orderDate, COUNT(orderNumber) AS orders
FROM orders
GROUP BY orderDate) ,
cte_payments AS
(SELECT *
FROM payments)
SELECT AVG(orders)
FROM cte_orders
WHERE orderDate > '2005-05-01'

-- Case statement
SELECT
CASE WHEN creditLimit < 75000 THEN 'a: Less than $75k'
WHEN creditLimit BETWEEN 75000 AND 100000 THEN 'b: $75k - $100k'
WHEN creditLimit BETWEEN 100000 AND 150000 THEN 'c: $100k - $150k'
WHEN creditLimit > 150000 THEN 'd: Over $150k'
ELSE 'Other' END AS credit_limit_grp,
COUNT(DISTINCT c.customerNumber) AS customers
FROM customers AS c
GROUP BY 1

-- Create a Flag using Case Statement
SELECT 
t1.orderNumber,
t1.orderDate,
t2.quantityOrdered,
t3.productName,
t3.productLine,
CASE WHEN quantityordered > 40 AND productline = 'Motorcycles'
THEN 1 
ELSE 0 END AS ordered_over_40_motorcycles
FROM orders t1
JOIN orderdetails t2
ON t1.orderNumber = t2.orderNumber
JOIN products t3
ON t2.productcode = t3.productcode

WITH main_cte AS
(SELECT 
t1.orderNumber,
t1.orderDate,
t2.quantityOrdered,
t3.productName,
t3.productLine,
CASE WHEN quantityordered > 40 AND productline = 'Motorcycles'
THEN 1 
ELSE 0 END AS ordered_over_40_motorcycles
FROM orders t1
JOIN orderdetails t2
ON t1.orderNumber = t2.orderNumber
JOIN products t3
ON t2.productcode = t3.productcode)
SELECT orderDate, SUM(ordered_over_40_motorcycles) AS over_40_bike_sale
FROM main_cte
GROUP BY orderDate

SELECT
*, 
CASE WHEN comments LIKE '%dispute%' THEN 1 ELSE 0 END AS disputed,
CASE WHEN comments LIKE '%negotiate%' THEN 'Negotiated Order' 
WHEN comments LIKE '%dispute%' THEN 'Disputed Order' 
ELSE 'No Dispute or Negotiate' END AS status_1
FROM orders

-- Row Number
SELECT customerNumber, t1.orderNumber, ROW_NUMBER() OVER(PARTITION BY customerNumber ORDER BY orderDate) AS purchase_number
FROM orders t1
ORDER BY customerNumber, t1.orderNumber

SELECT DISTINCT t3.customerName, t1.customerNumber, t1.orderNumber, orderDate, productCode,
ROW_NUMBER() OVER(PARTITION BY t3.customerNumber ORDER BY orderDate) AS purchase_number
FROM orders t1
JOIN orderdetails t2 ON t1.orderNumber = t2.orderNumber
JOIN customers t3 ON t1.customerNumber = t3.customerNumber
ORDER BY t3.customerName

WITH main_cte AS
(SELECT DISTINCT t3.customerName, t1.customerNumber, t1.orderNumber, orderDate, productCode,
ROW_NUMBER() OVER(PARTITION BY t3.customerNumber ORDER BY orderDate) AS purchase_number
FROM orders t1
JOIN orderdetails t2 ON t1.orderNumber = t2.orderNumber
JOIN customers t3 ON t1.customerNumber = t3.customerNumber
ORDER BY t3.customerName)
SELECT *
FROM main_cte
WHERE purchase_number = 2

-- Lead & Lag
SELECT customerNumber, paymentDate, amount, LEAD(amount) OVER(PARTITION BY customerNumber ORDER BY paymentDate) AS next_payment
FROM payments

SELECT customerNumber, 
paymentDate, 
amount, 
LAG(amount) OVER(PARTITION BY customerNumber ORDER BY paymentDate) AS prev_payment
FROM payments

WITH cte_main AS
(SELECT customerNumber, 
paymentDate, 
amount, 
LAG(amount) OVER(PARTITION BY customerNumber ORDER BY paymentDate) AS prev_payment
FROM payments)
SELECT *, amount - prev_payment AS difference
FROM cte_main

/*
 Display the orderdate, ordernumber, salesrepemployeenumber for sales reps second order.
*/
SELECT orderDate, t1.orderNumber, salesRepEmployeeNumber,
ROW_NUMBER() OVER(PARTITION BY salesRepEmployeeNumber ORDER BY orderDate) AS repordernumber
FROM orders t1
INNER JOIN customers t2
on t1.customerNumber = t2.customerNumber
JOIN employees t3
ON t2.salesRepEmployeeNumber = t3.EmployeeNumber

WITH cte_main AS(
SELECT orderDate, t1.orderNumber, salesRepEmployeeNumber,
ROW_NUMBER() OVER(PARTITION BY salesRepEmployeeNumber ORDER BY orderDate) AS repordernumber
FROM orders t1
INNER JOIN customers t2
on t1.customerNumber = t2.customerNumber
JOIN employees t3
ON t2.salesRepEmployeeNumber = t3.EmployeeNumber)
SELECT *
FROM cte_main 
WHERE repordernumber = 2

-- Date Functions
SELECT orderNumber, orderDate, YEAR(orderDate) AS year, MONTH(orderDate) AS MONTH, DAY(orderDate) AS day
FROM orders

SELECT orderNumber, requiredDate, orderDate, DATEDIFF(NOW(), orderDate)/365 AS days_until_required
FROM orders

-- DATE ADD
SELECT orderNumber, orderDate, DATE_ADD(requiredDate, INTERVAL 1 YEAR) AS one_year_from_order
FROM orders

/*-- DATE SUB
SELECT *
FROM orders
WHERE orderDate >= ('20060101', INTERVAL 1 YEAR)*/

SELECT *, DATE_ADD(orderDate, INTERVAL 1 YEAR) AS one_year_after, DATE_SUB(orderDate, INTERVAL 2 MONTH) AS two_month_ago
FROM orders

-- String Function
SELECT *, CAST(paymentDate AS datetime) AS datetime_type
FROM payments

SELECT customerNumber, paymentDate, SUBSTRING(paymentDate, 1, 7) AS month_key
FROM payments

SELECT customerNumber, paymentDate, SUBSTRING(paymentDate, 6, 5) AS month_key
FROM payments

SELECT *, SUBSTRING(country, 1,2) AS code
FROM customers

-- concat
SELECT employeeNumber, lastname, firstname, CONCAT(firstname, ' ', lastname) AS full_name
FROM employees

SELECT customerName, CONCAT(city, '_', country) as city_country
FROM customers