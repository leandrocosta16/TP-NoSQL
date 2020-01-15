var mongoose = require('mongoose');
var Schema = mongoose.Schema;

mongoose.connect('mongodb://localhost/sakilaMongo2', { useUnifiedTopology: true, useNewUrlParser: true });

const mysql = require('mysql2/promise');
const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: "1234root",
    database: 'sakila',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});



var customerSchema = new Schema({
    name: String,
    address: {
        phone: String,
        city: String,
        country: String
    },
    rentals: [
        {
            rental_date: Date,
            return_date: Date,
            store_id: Number,
            price: Number,
            title: String,
            category: String
        }
    ]
});

var filmSchema = new Schema({
    title: String,
    description: String,
    release_year: String,
    length: String,
    rating: String,
    category: String,
    language: String,
    price: Number,
    actors: [
        {
            full_name: String
        }
    ],
    stores: [
        {
            store_id: String,
            address: String,
            filmQuantity: Number
        }
    ]
});

var Customer = mongoose.model('Customer', customerSchema, 'customers');

var Film = mongoose.model('Film', filmSchema, 'films');



async function fillCustomer() {

    var array = [];
    var c1 = null;
    const r1 = await pool.query("SELECT * FROM customer");

    for (var i = 1; i <= r1[0].length; i++) {
        array = []
        var sql = "SELECT id, name, address, phone, city, country FROM customer_list WHERE ID =" + i;
        const r2 = await pool.query(sql);

        var sql = "SELECT inventory_id, rental_date, return_date FROM rental WHERE customer_id = " + i;
        const r3 = await pool.query(sql);

        for (var j = 0; j < r3[0].length; j++) {
            var sql = "SELECT store_id, film_id FROM inventory WHERE inventory_id =" + r3[0][j].inventory_id;
            const r4 = await pool.query(sql);

            var sql = "SELECT title, category, price FROM film_list WHERE fid =" + r4[0][0].film_id;
            const r5 = await pool.query(sql);

            if (r5[0].length > 0) {
                var rental = {
                    rental_date: r3[0][j].rental_date,
                    return_date: r3[0][j].return_date,
                    store_id: r4[0][0].store_id,
                    price: r5[0][0].price,
                    category: r5[0][0].category,
                    title: r5[0][0].title,
                }
                array.push(rental)
            }
        }

        var c1 = new Customer({
            name: r2[0][0].name,
            address: {
                phone: r2[0][0].phone,
                city: r2[0][0].city,
                country: r2[0][0].country
            },
            rentals: array
        })


        c1.save(function (err) {
            if (err) return console.error(err);
            console.log("#" + i + " " + c1.name + " inserted into MongoDB!")
        });
    }
}





async function fillFilm() {

    var array = [];

    var f1 = null;


    const r1 = await pool.query("SELECT * FROM film_list");

    const highestID = await pool.query("SELECT fid FROM film_list ORDER BY fid DESC LIMIT 0, 1");
    

    for (var i = 1; i <= highestID[0][0].fid; i++) {
        
        array = []
        var sql = "SELECT fid, title, description, category, length, rating, actors, price FROM film_list WHERE fid = " + i;
        const r2 = await pool.query(sql);
        if(r2[0].length === 0){
            continue;
        }

        var sql = "SELECT language_id, release_year FROM film WHERE film_id = " + i;
        const r3 = await pool.query(sql);
        //console.log(r3[0]);
        //console.log(r3[0]);

        var sql = "SELECT name FROM language WHERE language_id = " + r3[0][0].language_id;
        const r4 = await pool.query(sql);


        var sql = "select store_id, count(film_id) as quantity from inventory where film_id = " + i + " group by store_id";
        const r5 = await pool.query(sql);

    

        for (var j = 1; j <= r5[0].length; j++) {
            //console.log(j);
            var sql = "select address_id from store where store_id = " + j ;
            const r6 = await pool.query(sql);

            var sql = "select address from address where address_id = " + r6[0][0].address_id;
            const r7 = await pool.query(sql);



            if (r7[0].length > 0) {

                var store = {
                    store_id: r5[0][j-1].store_id,
                    address: r7[0][0].address,
                    filmQuantity: r5[0][j-1].quantity
                }

                array.push(store)
            }


        }

        


        

        var actors = r2[0][0].actors;

        var array_actors = actors.split(",");
        var actors = []


        for (let a = 0; a < array_actors.length; a++) {
            var actor = {
                full_name: array_actors[a]
            }

            actors.push(actor)
        }







        var f1 = new Film({
            title: r2[0][0].title,
            description: r2[0][0].description,
            release_year: r3[0][0].release_year,
            length: r2[0][0].length,
            rating: r2[0][0].rating,
            category: r2[0][0].category,
            language: r4[0][0].name,
            price: r2[0][0].price,
            actors: actors,
            stores: array
        })

        //console.log(j);


        f1.save(function (err) {
            if (err) return console.error(err);
            console.log("#" + i + " " + f1.title + " inserted into MongoDB!")
        });


    }

}


//fillCustomer();
fillFilm();


