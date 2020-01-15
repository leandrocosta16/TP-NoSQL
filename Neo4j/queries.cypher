//Top 5 clientes que mais alugou filmes
match (c:Customer)-[:RENTED]->(r:Rental)
return c as Client, count(r) as TotalRented
order by count(r) desc
limit 5;

//Top 5 clientes que mais gastaram dinheiro 
match (c:Customer)-[:RENTED]->(r:Rental)
return c as Client, sum(toInt(r.price)) as MoneySpent
order by sum(toInt(r.price)) desc
limit 5;

//Top 5 filmes com mais atores
match (f:Film)<-[r:ACTED_IN]-(a:Actor)
return f as Film, count(a) as Actors
order by count(a) desc
limit 5;

//Para cada ator listar a lista de filmes em que participou
match (f:Film)<-[r:ACTED_IN]-(a:Actor)
return a as Actor,collect(f) as Films;

//Para cada categoria listar a lista de filmes pertencente
match (f:Film)
return f.category as Category, collect(f.title) as Films

//Indicar qts filmes tem cada loja
match (s:Store)
return s.address as Store, sum(toInt(s.quantity)) as Quantity