Question Set 1 - Easy

Q1. Who is the senior most employee based on job title,return employee id,
    full name as full_name,title,levels?

SELECT employee_id,concat(first_name,last_name) AS full_name,
title,levels FROM employee
ORDER BY levels DESC
LIMIT 1;

Q2. Show all the invoice_id, billing_address,billing_city of all invoice which 
	are not from 'Canada', 'Poland', 'France'.
	
SELECT invoice_id,billing_address,
billing_city FROM invoice 
WHERE billing_country NOT IN('Canada','Poland','France')
	
Q3.Show all the even numbered invoice_id from the invoice table

SELECT invoice_id AS even_invoice_id 
FROM invoice
WHERE  invoice_id %2 = 0;

Q4.Show first name of customer that start with the letter 'L' and last name of customer
   that contains 'o' in their last name;	
   
SELECT first_name,last_name
FROM customer 
WHERE first_name LIKE 'L%' AND
last_name LIKE '%o%';
   
Q5. Which countries have the most Invoices?

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;

Q6. Who is the best customer? The customer who has spent the most money will be 
    declared the best customer. Write a query that returns the person who has spent 
	the most money,round the total.
	
SELECT c.customer_id, c.first_name, c.last_name, round(SUM(i.total)) AS total_spend
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spend DESC
LIMIT 1;

Question Set 2 - Medium

Q1. Display every employee first_name who are from 'Calgary' .
	Order the list by the length of each name and then by alphabetically.
	
SELECT first_name 
FROM employee
WHERE city = 'Calgary'
ORDER BY LENGTH(first_name),
first_name ASC;

Q2. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
    Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT c.email,c.first_name,c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track t
	JOIN genre g ON t.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
)
ORDER BY email;

Q3.Show all of the days of the month (1-31) and how many invoice_dates occurred on that day. 
   Sort by the day with most invoice to least invoice.
   
SELECT EXTRACT(DAY from invoice_date) as day_number, COUNT(*) as number_of_invoices
FROM invoice
GROUP BY day_number
ORDER BY number_of_invoices DESC;

Q4.Show first name, last name and role of every person that is either customer or employee.
The roles are either "Customer" or "Patient".

SELECT first_name,last_name,'Customer' AS role FROM customer
UNION ALL
SELECT first_name,last_name,'Employee' AS role FROM employee

Q5.Return all the track names that have a song length longer than the average song length. 
   Return the Name and Milliseconds for each track. Order by the song length with the 
   longest songs listed first.

SELECT name as track_names,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

Question Set 3 - Hard

Q1. Sort the billing_country in ascending order in such a way that the 
    country 'USA' is always on top.
	
SELECT billing_country
FROM invoice
GROUP by billing_country
ORDER BY
(CASE WHEN billing_country='USA' THEN 0 ELSE 1 END),
billing_country;

Q2. Write a query that determines the customer that has spent the most on music for each country. 
    Write a query that returns the country along with the top customer and how much they spent. 
    For countries where the top amount spent is shared, provide all customers who spent this amount. 

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,
	    SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;

Q3. We want to find out the most popular music Genre for each country. We determine the 
    most popular genre as the genre with the highest amount of purchases. Write a query 
	that returns each country along with the top Genre. For countries where the maximum 
	number of purchases is shared return all Genres.

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) 
	AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;
