
/*Question 1:

We want to understand more about the movies that families are watching.
The following categories are considered family movies:
Animation, Children, Classics, Comedy, Family and Music.
Create a query that lists each movie, the film category it is classified in, 
and the number of times it has been rented out.
*/
SELECT class_ta.name AS category_name, 
	SUM(count_ta.rental_count) AS rental_count_sum
FROM ( 
  SELECT c.name, f.title, f.film_id
  FROM film f
  JOIN film_category fc 
  ON fc.film_id = f.film_id
  JOIN category c
  ON c.category_id = fc.category_id
  WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family','Music')
) class_ta
JOIN (
  SELECT i.film_id, COUNT(*) AS rental_count
  FROM inventory i 
  JOIN rental r
  ON i.inventory_id = r.inventory_id
  GROUP BY 1
) count_ta
ON count_ta.film_id = class_ta.film_id
GROUP BY 1
ORDER BY 1;

--------------------------------------------------------------------------------------
/*Question 2:

We need to know how the length of rental duration of these family-friendly movies compares 
to the duration that all movies are rented for. Can you provide a table with the movie titles and divide 
them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) based on the quartiles 
(25%, 50%, 75%) of the rental duration for movies across all categories?
Make sure to also indicate the category that these family-friendly movies fall into.
*/
SELECT f.title, c.name, 
     f.rental_duration, 
     NTILE(4) OVER (ORDER BY rental_duration) AS standared_quartile
FROM film f
JOIN film_category fc
ON fc.film_id = f.film_id
JOIN category c
ON fc.category_id = c.category_id
WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family','Music');

----------------------------------------------------------------------------------------
/*Question 3:

We want to find out how the two stores compare in their count of rental orders during every month for all 
the years we have data for. Write a query that returns the store ID for the store, the year and month and 
the number of rental orders each store has fulfilled for that month. Your table should include a column for 
each of the following: year, month, 
store ID and count of rental orders fulfilled during that month.
*/
SELECT DATE_PART('MONTH', r.rental_date) AS rental_month,
     DATE_PART('YEAR', r.rental_date) AS rental_year, 
     s.store_id, 
     COUNT(r.rental_id)
FROM rental r
JOIN staff sf
ON r.staff_id = sf.staff_id
JOIN store s
ON s.store_id = sf.store_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

------------------------------------------------------------------------------------------
/*Question 4:

We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis 
during 2007, and what was the amount of the monthly payments. Can you write a query to capture the customer 
name, month and year of payment, and total payment amount for each month by these top 10 paying customers?
*/
WITH sum_ta AS(
SELECT CONCAT(c.first_name,' ', c.last_name) full_name, 
     sum(p.amount) payment_sum
FROM payment p
JOIN customer c
ON  c.customer_id = p.customer_id
group by 1
order by 2 desc
limit 10 
)

SELECT DATE_TRUNC('MONTH', p.payment_date) pay_month, 
     CONCAT(c.first_name,' ', c.last_name) full_name, 
     COUNT(p.AMOUNT) pay_count_per_month, 
     SUM(p.amount) pay_amount
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
WHERE CONCAT(c.first_name,' ', c.last_name) 
IN (SELECT full_name
     FROM sum_ta)
GROUP BY 1, 2 
ORDER BY 2, 1;