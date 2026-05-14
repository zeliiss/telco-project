-- 1.1 List the customers who are subscribed to the 'Kobiye Destek' tariff.
/*
I joined the customers and tariffs tables for this query. 
I used the TARIFF_ID column to connect these two tables. 
Then, I filtered the results to only show customers where the tariff name is 'Kobiye Destek'.
*/
SELECT c.CUSTOMER_ID, c.NAME, c.CITY, t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek';



-- 1.2 Find the newest customer who subscribed to this tariff.
/*
First, I joined the customers and tariffs tables just like the previous question.
Then, I sorted the signup dates in descending order (DESC) to find the newest one.
Finally, I used FETCH FIRST 1 ROWS ONLY to get the single most recent customer.
*/
SELECT c.CUSTOMER_ID, c.NAME, c.SIGNUP_DATE
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.SIGNUP_DATE DESC
FETCH FIRST 1 ROWS ONLY;



-- 2.1 Find the distribution of tariffs among the customers.
/*
I used GROUP BY to count how many customers are using each tariff.
I joined the customers and tariffs tables to see the actual tariff names.
The COUNT function calculates the total number of customers for every tariff group.
*/
SELECT t.NAME AS TARIFF_NAME, COUNT(c.CUSTOMER_ID) AS TOTAL_CUSTOMERS
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME;



-- 3.1 Identify the earliest customers to sign up.
/*
I needed to look at the signup date instead of customer IDs to find the earliest ones.
I wrote a subquery to find the absolute minimum (oldest) signup date in the table.
Then, I selected all customers whose signup date exactly matches this minimum date.
*/
SELECT CUSTOMER_ID, NAME, CITY, SIGNUP_DATE
FROM CUSTOMERS
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS);



-- 3.2 Find the distribution of these earliest customers across different cities.
/*
I used the exact same logic from question 3.1 to filter the earliest customers.
After finding them, I grouped the results by the city column.
Finally, I used COUNT to see how many of these early customers live in each city.
*/
SELECT CITY, COUNT(CUSTOMER_ID) AS CUSTOMER_COUNT
FROM CUSTOMERS
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS)
GROUP BY CITY;



-- 4.1 Identify the IDs of these missing customers (who don't have monthly records).
/*
I used a LEFT JOIN from the customers table to the monthly stats table.
If a customer does not have any monthly record, their stats row will be NULL.
So, I filtered the query with 'IS NULL' to find the missing customers easily.
*/
SELECT c.CUSTOMER_ID, c.NAME
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL;



-- 4.2 Find the distribution of these missing customers across different cities.
/*
I started with the same LEFT JOIN logic to find the missing customers.
Instead of showing their names, I grouped the results by their cities.
Then, I counted how many missing customer records exist in each city.
*/
SELECT c.CITY, COUNT(c.CUSTOMER_ID) AS MISSING_COUNT
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS ms ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.CUSTOMER_ID IS NULL
GROUP BY c.CITY;



-- 5.1 Find the customers who have used at least 75% of their data limit.
/*
I joined all three tables to compare customer usage and tariff limits.
I calculated the 75 percent of the data limit by multiplying it with 0.75.
Then, I checked if the customer's data usage is greater than or equal to this calculated number.
*/
SELECT c.CUSTOMER_ID, c.NAME, ms.DATA_USAGE, t.DATA_LIMIT
FROM CUSTOMERS c
JOIN MONTHLY_STATS ms ON c.CUSTOMER_ID = ms.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE ms.DATA_USAGE >= (t.DATA_LIMIT * 0.75);



-- 5.2 Identify the customers who have completely exhausted all of their package limits.
/*
I needed to check three different limits together for this requirement.
I compared data usage, minute usage, and SMS usage with their maximum limits from the tariff.
If all three usage values are greater than or equal to their limits, the customer exhausted the package.
*/
SELECT c.CUSTOMER_ID, c.NAME
FROM CUSTOMERS c
JOIN MONTHLY_STATS ms ON c.CUSTOMER_ID = ms.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE ms.DATA_USAGE >= t.DATA_LIMIT 
  AND ms.MINUTE_USAGE >= t.MINUTE_LIMIT 
  AND ms.SMS_USAGE >= t.SMS_LIMIT;



-- 6.1 Find the customers who have unpaid fees.
/*
I joined the customers and monthly stats tables using the customer ID.
I looked at the payment status column in the stats table.
I wrote a WHERE condition to only select customers whose status is 'UNPAID'.
*/
SELECT c.CUSTOMER_ID, c.NAME, ms.PAYMENT_STATUS
FROM CUSTOMERS c
JOIN MONTHLY_STATS ms ON c.CUSTOMER_ID = ms.CUSTOMER_ID
WHERE ms.PAYMENT_STATUS = 'UNPAID';



-- 6.2 Find the distribution of all payment statuses across the different tariffs.
/*
I joined the customers, monthly stats, and tariffs tables all together.
I grouped the final table by both tariff name and payment status.
This way, I can see the count of paid, unpaid, or late customers for every single tariff.
*/
SELECT t.NAME AS TARIFF_NAME, ms.PAYMENT_STATUS, COUNT(c.CUSTOMER_ID) AS STATUS_COUNT
FROM CUSTOMERS c
JOIN MONTHLY_STATS ms ON c.CUSTOMER_ID = ms.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME, ms.PAYMENT_STATUS
ORDER BY t.NAME;