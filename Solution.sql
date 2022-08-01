-- How many copies of the film Hunchback Impossible exist in the inventory system?

USE sakila;

SELECT COUNT(inventory_id) AS "Copies"
FROM inventory
WHERE film_id IN (
	SELECT film_id
	FROM (
		SELECT film_id, title FROM film
		WHERE title = "Hunchback Impossible"
	) AS sub
);

-- List all films whose length is longer than the average of all the films.

SELECT title, length FROM film
WHERE length > (
	SELECT AVG(length) AS AVG_Length FROM film
)
ORDER BY length DESC;

-- Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name FROM actor
WHERE actor_id IN (
	SELECT actor_id FROM film_actor
	WHERE film_id IN (
		SELECT film_id FROM film
		WHERE title = "Alone Trip"
	)
);

/* Sales have been lagging among young families,
and you wish to target all family movies for a promotion.
Identify all movies categorized as family films.
*/

SELECT title FROM film
WHERE film_id IN (
	SELECT film_id FROM film_category
	WHERE category_id IN (
		SELECT category_id FROM category
		WHERE name = "Family"
        )
);

/* Get name and email from customers from Canada using subqueries.
Do the same with joins. Note that to create a join,
you will have to identify the correct tables with their primary keys and foreign keys,
that will help you get the relevant information.
*/

SELECT first_name, last_name, email FROM customer
WHERE address_id IN (
	SELECT address_id FROM address
	WHERE city_id IN (
		SELECT city_id FROM city
		WHERE country_id IN (
			SELECT country_id FROM country
			WHERE country = "Canada"
		)
	)
);

SELECT cu.first_name, cu.last_name, cu.email
FROM customer AS cu
INNER JOIN address AS a
ON cu.address_id = a.address_id
INNER JOIN city AS ci
ON a.city_id = ci.city_id
INNER JOIN country AS co
ON ci.country_id = co.country_id
WHERE co.country = "Canada";

/* Which are films starred by the most prolific actor?
Most prolific actor is defined as the actor that has acted in the most number of films.
First you will have to find the most prolific actor
and then use that actor_id to find the different films that he/she starred.
*/

SELECT title FROM film
WHERE film_id IN (
	SELECT film_id FROM film_actor
	WHERE actor_id IN (
		SELECT actor_id
		FROM (
			SELECT actor_id, Films, ROW_NUMBER() OVER () AS "Ranking"
			FROM (
				SELECT actor_id, COUNT(film_id) AS "Films" FROM film_actor 
				GROUP BY actor_id
				ORDER BY Films DESC
			) AS sub1
		) AS sub2
		WHERE Ranking = 1
	)
);
-- I used the ROW_NUMBER() function to get a ranking and then select the first ranked actor

/* Films rented by the most profitable customer.
You can use the customer table and payment table to find the most profitable customer.
I.e.: the customer that has made the largest sum of payments
*/

SELECT title FROM film
WHERE film_id IN (
	SELECT film_id FROM inventory
	WHERE inventory_id IN (
		SELECT inventory_id FROM rental
		WHERE customer_id IN (
			SELECT customer_id
			FROM (
				SELECT customer_id, Payments, ROW_NUMBER() OVER () AS "Ranking"
				FROM (
					SELECT customer_id, SUM(amount) AS "Payments"
					FROM payment
					GROUP BY customer_id
					ORDER BY Payments DESC
				) AS sub1
			) AS sub2
			WHERE Ranking = 1
		)
	)
);

-- Customers who spent more than the average payments.

SELECT customer_id, SUM(Amount) AS "Payments" FROM payment
GROUP BY customer_id
HAVING Payments > (
	SELECT AVG(AVG_Amount) AS "Payments"
	FROM (
		SELECT SUM(Amount) AS "AVG_Amount" FROM payment
		GROUP BY customer_id
	) AS sub1
)
ORDER BY Payments DESC;