use `sakila`;

##customers
select c.customer_id, CONCAT(c.first_name,' ',c.last_name), a.phone, city.city, country.country 
from customer c
inner join address a on a.address_id = c.address_id
inner join city on city.city_id = a.city_id
inner join country on country.country_id = city.country_id
INTO OUTFILE '/mysql_exp/customers.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

##rentals
select c.customer_id, IFNULL(r.rental_date,0), IFNULL(r.return_date,0), p.amount as price ,i.store_id, f.title, cat.name as category
from rental r
inner join customer c on c.customer_id = r.customer_id 
inner join inventory i on i.inventory_id = r.inventory_id
inner join film f on f.film_id = i.film_id
inner join film_category fc on fc.film_id = f.film_id
inner join category cat on cat.category_id = fc.category_id
inner join payment p on p.rental_id = r.rental_id
INTO OUTFILE '/mysql_exp/rentals.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

##actors
select f.film_id, CONCAT(a.first_name,' ',a.last_name)
from film f
inner join film_actor fa on fa.film_id = f.film_id
inner join actor a on a.actor_id = fa.actor_id
INTO OUTFILE '/mysql_exp/actors.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

##stores
select s.store_id, a.address, i.film_id, COUNT(*) as filmQuantity
from store s
inner join address a on a.address_id = s.address_id
inner join inventory i on i.store_id = s.store_id
group by s.store_id, a.address, i.film_id
INTO OUTFILE '/mysql_exp/stores.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

##films
select f.film_id, f.title, f.description, f.release_year, f.length, f.rating, c.name as category, l.name as language, f.rental_rate
from film f
inner join film_category fc on fc.film_id = f.film_id
inner join category c on c.category_id = fc.category_id
inner join language l on l.language_id = f.language_id
INTO OUTFILE '/mysql_exp/films.csv'
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';


