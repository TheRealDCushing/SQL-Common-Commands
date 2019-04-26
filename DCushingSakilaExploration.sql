USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name 
FROM actor 
where last_name LIKE "%gen%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name 
FROM actor 
where last_name LIKE "%li%" 
ORDER BY last_name ASC, first_name ASC;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country 
FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor 
ADD COLUMN description BLOB AFTER last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor 
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) as "Counts" 
FROM actor 
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) as "Counts" 
FROM actor 
GROUP BY last_name 
HAVING Counts >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor 
set first_name = 'HARPO' 
WHERE actor_id = 172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor 
set first_name = 'GROUCHO' 
WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address 
FROM staff 
JOIN address ON staff.address_id=address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT  p.staff_id, concat(s.first_name, ' ', s.last_name) as Name, SUM(p.amount) as Total_Amount
FROM payment p
JOIN staff s ON p.staff_id = s.staff_id 
GROUP BY P.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT   fa.film_id, f.title, count(fa.actor_id) as actor_count
FROM   film_actor fa 
INNER JOIN film f
ON (fa.film_id = f.film_id)
GROUP BY fa.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT  I.film_id, F.title, count(I.inventory_id) as count_copies
FROM  inventory i, film f 
WHERE  i.film_id in 
(SELECT f.film_id FROM film f 
WHERE f.title like 'Hunchback%Impossible%')
AND i.film_id = f.film_id
GROUP BY 1
;

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, sum(p.amount)
FROM customer c
JOIN payment p 
ON c.customer_id = p.customer_id
GROUP BY c.last_name, c.first_name
ORDER BY c.last_name ASC
;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
Select title
FROM film 
WHERE (title LIKE "Q%" OR title LIKE "K%")
AND language_id = (
	SELECT language_id
	FROM language
	WHERE name = 'English')
;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select  a.first_name, a.last_name 
from  film_actor fa, actor a
WHERE  fa.film_id = (SELECT film_id FROM film f WHERE f.title = 'Alone Trip')
AND  fa.actor_id = a.actor_id
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will
-- need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer c
WHERE address_id in (SELECT a.address_id
	FROM address a, city ci, country cn
	where  a.city_id     = ci.city_id
	AND  ci.country_id = cn.country_id
	AND  cn.country = 'Canada')
;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT f.title
FROM film f
WHERE f.film_id in 
(SELECT  fc.film_id 
FROM  film_category fc, category c
WHERE  fc.category_id = c.category_id
AND  c.name = 'Family')
;

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, count(*) as 'rentals'
FROM rental r, inventory i, film f
WHERE r.inventory_id = i.inventory_id
AND i.film_id = f.film_id
GROUP BY f.title
ORDER BY rentals DESC
;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT c.store_id, SUM(p.amount) AS total_store
FROM  payment  p, customer c
WHERE  p.customer_id = c.customer_id 
GROUP BY c.store_id
;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT s.store_id, ci.city, cn.country
FROM  store s, address a, city ci, country cn
WHERE s.address_id = a.address_id
AND a.city_id = ci.city_id
AND ci.country_id = cn.country_id
;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT sum(pay.amount) as 'gross_revenue', cat.name as 'genre'
FROM category cat, film_category fcat, inventory inv, payment pay, rental rent
WHERE cat.category_id = fcat.category_id
AND rent.inventory_id = inv.inventory_id
AND pay.rental_id = rent.rental_id
AND inv.film_id = fcat.film_id
GROUP BY genre;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross
-- revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute 
-- another query to create a view.
CREATE VIEW Top5Genres3 AS
SELECT sum(pay.amount) as 'gross_revenue', cat.name as 'genre'
FROM category cat, film_category fcat, inventory inv, payment pay, rental rent
WHERE cat.category_id = fcat.category_id
AND rent.inventory_id = inv.inventory_id
AND pay.rental_id = rent.rental_id
AND inv.film_id = fcat.film_id
GROUP BY genre
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Top5Genres3;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top5Genres3;