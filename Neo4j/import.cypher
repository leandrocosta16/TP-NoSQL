////////////////customerSchema////////////////
//customers
using periodic commit 100
LOAD CSV WITH HEADERS FROM "file:///customers.csv" AS csvLine
CREATE (c:Customer {id: toInteger(csvLine.customer_id), name: csvLine.name, phone: csvLine.phone, city: csvLine.city, country: csvLine.country})

//rentals
using periodic commit 100
LOAD CSV WITH HEADERS FROM "file:///rentals.csv" AS csvLine
CREATE (r:Rental {customer_id: toInteger(csvLine.customer_id), rental_date: toString(csvLine.rental_date), return_date: toString(csvLine.return_date), price: csvLine.price, store_id: csvLine.store_id, title: csvLine.title, category: csvLine.category})

// "customers" RENTED "rentals"
MATCH (a:Rental),
(b:Customer)
WHERE EXISTS (a.customer_id) AND EXISTS (b.id) AND a.customer_id=b.id
CREATE (b)-[:RENTED]->(a);


////////////////filmsSchema////////////////
//films
using periodic commit 100
LOAD CSV WITH HEADERS FROM "file:///films.csv" AS csvLine
CREATE (f:Film {film_id: toInteger(csvLine.film_id), title: csvLine.title, description: csvLine.description,release_year: csvLine.release_year,length: csvLine.length,rating: csvLine.rating,category: csvLine.category,language: csvLine.language,rental_rate: csvLine.rental_rate})

//stores
using periodic commit 100
LOAD CSV WITH HEADERS FROM "file:///stores.csv" AS csvLine
CREATE (s:Store {store_id: toInteger(csvLine.store_id), address: csvLine.address, film_id: csvLine.film_id, quantity: csvLine.quantity})

//actors
using periodic commit 100
LOAD CSV WITH HEADERS FROM "file:///actors.csv" AS csvLine
CREATE (a:Actor {film_id: toInteger(csvLine.film_id), name: csvLine.name})

//"actors" ACTED_IN "films"
MATCH (a:Film),(b:Actor)
WHERE EXISTS (a.film_id) AND EXISTS (b.film_id) AND a.film_id=b.film_id
CREATE (b)-[:ACTED_IN]->(a);

//"stores" HAS "films"
MATCH (a:Film),(b:Store)
WHERE EXISTS (a.film_id) AND EXISTS (b.film_id) AND a.film_id=toInt(b.film_id)
CREATE (b)-[:HAS]->(a);