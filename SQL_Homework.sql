use sakila;
/*1a. Display the first and last names of all actors from the table `actor`.*/

select first_name, last_name from actor;
/*1b. Display the first and last name of each actor in a single column in upper case letters. 
Name the column `Actor Name`.*/

select concat(first_name,' ',last_name) as 'Actor Name' from actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, 
of whom you know only the first name, "Joe." What is one query would you use to obtain this information?*/
select actor_id, first_name, last_name from actor where first_name like ('JOE%');

-- 2b. Find all actors whose last name contain the letters `GEN`:
select actor_id, first_name, last_name from actor where last_name like ('%GEN%');

-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
select actor_id, first_name, last_name from actor where last_name like ('%LI%')
order by last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
select country_id, country 
from country 
where country IN ('Afghanistan', 'Bangladesh', 'China');


-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` -- 
-- and use the data type `BLOB` (Make sure to research the type `BLOB`, 
-- as the difference between it and `VARCHAR` are significant).

alter table actor
	add description blob;



-- 3b. Very quickly you realize that entering descriptions for each 
-- actor is too much effort. Delete the `description` column.
alter table actor
	drop column description;
    

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*)
from actor
group by last_name;



-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select last_name, count(*)
from actor
group by last_name
having count(*) >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` 
-- table as `GROUCHO WILLIAMS`. Write a query to fix the record.

select first_name, last_name
from actor
where upper(first_name) = 'GROUCHO';

update actor 
set first_name = 'HARPO'
where last_name = 'WILLIAMS' and first_name = 'GROUCHO';



-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor 
set first_name = 'GROUCHO'
where last_name = 'WILLIAMS' and first_name = 'HARPO';



-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
CREATE schema IF NOT EXISTS sakila;


-- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`:
    
select s.first_name, s.last_name, a.address, a.address2
  from staff s join address a on s.address_id = a.address_id;
 
 select first_name, last_name, address, address2
  from staff inner join address on (address_id);
  



-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select * from payment;
select * from staff;
select s.first_name, s.last_name, sum(p.amount)
	from staff s join payment p on s.staff_id = p.staff_id
    where p.payment_date >= STR_TO_DATE("August 1 2005","%M %d %Y") and  p.payment_date < STR_TO_DATE("September 1 2005","%M %d %Y")
	group by s.first_name, s.last_name;
    
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select * from film;
select * from film_actor;
select f.title, count(a.actor_id)
	from film f join film_actor a on f.film_id = a.film_id
    group by f.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select * from inventory;
select * from film;
select f.title, count(i.film_id)
	from film f join inventory i on f.film_id = i.film_id
    where f.title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
select * from payment p;
select * from customer c;
select c.first_name, c.last_name, sum(p.amount)
	from customer c join payment p on c.customer_id = p.customer_id
    group by c.first_name, c.last_name
    order by c.last_name;
    

  

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select * from film f;
select * from language l;
select f.title, f.language_id
from film f
	where (f.title like "K%" or f.title like "Q%")
    and f.language_id = (select l.language_id from language l where name = 'English');
    
    
    
    


-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
Select * from film f;
select * from film_actor f_a;
select * from actor a;

select a.first_name, a.last_name
 from actor a
 where a.actor_id in (select fa.actor_id
 from film_actor fa
 where fa.film_id = (select f.film_id from film f
 where f.title = 'Alone Trip')
 );
 


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all 
-- Canadian customers. Use joins to retrieve this information.
select * from customer;
select * from address;
select * from country;
select * from city;
select c.first_name, c.last_name, c.email 
	from customer c join address a on c.address_id = a.address_id
					join city ci on a.city_id = ci.city_id
                    join country co on ci.country_id = co.country_id
				where co.country = 'Canada';
    

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
Select * from film_category;
Select * from category;
Select * from film;
select f.title
	from film f
    join film_category fc on fc.film_id = f.film_id
	join category c on c.category_id = fc.category_id
Where c.name = 'family';
        
	

-- 7e. Display the most frequently rented movies in descending order.
select * from film;
select * from inventory;
select * from rental;

SELECT f.title, count(*)
FROM film f
	join inventory i ON f.film_id = i.film_id
	join rental r ON r.inventory_id = i.inventory_id
    group by f.title
    order by count(*) desc;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from store;
select * from rental;
select * from payment;
select s.store_id, sum(p.amount)
	from store s
		join staff sf on sf.store_id = s.store_id
        join payment p on p.staff_id = sf.staff_id
        group by s.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.

select * from store;
select s.store_id, ci.city, co.country
 from store s 
	join address a on s.address_id = a.address_id
    join city ci on a.city_id = ci.city_id
    join country co on ci.country_id = co.country_id;


-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name, sum(p.amount)
 from category c
	join film_category fc on c.category_id = fc.category_id
    join inventory i on fc.film_id = i.film_id
    join rental r on i.inventory_id = r.inventory_id
    join payment p on r.rental_id = p.rental_id
group by c.name
order by sum(p.amount) desc limit 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create or replace view Top_Categories as 
select c.name, sum(p.amount)
 from category c
	join film_category fc on c.category_id = fc.category_id
    join inventory i on fc.film_id = i.film_id
    join rental r on i.inventory_id = r.inventory_id
    join payment p on r.rental_id = p.rental_id
group by c.name
order by sum(p.amount) desc limit 5;





-- 8b. How would you display the view that you created in 8a?
select * from Top_Categories;
-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view Top_Categories;

