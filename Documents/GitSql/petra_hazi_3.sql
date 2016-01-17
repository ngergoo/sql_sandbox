/*Petra hausaufgabe*/

/*Melyik filmből van a legtöbb példány az XXXXX boltban?*/
SELECT COUNT(inventory_id) AS quantity, film_id, store_id
FROM inventory
WHERE store_id = 1
GROUP BY film_id
HAVING quantity = 
    (
    SELECT MAX(a.quantity1)
    FROM 
        (
        SELECT COUNT(inventory_id) AS quantity1, film_id, store_id
        FROM inventory
        WHERE store_id = 1
        GROUP BY film_id
        ) AS a
    )

/*Melyik aktív vendég vette ki a legtöbb filmet és mennyit?*/

SELECT rental.customer_id, COUNT(inventory_id) quantity,
    customer.first_name, customer.last_name, customer.active
FROM rental JOIN customer ON rental.customer_id = customer.customer_id
GROUP BY rental.customer_id
HAVING quantity = 
    (
    SELECT MAX(b.quantity2)
    FROM
        (
        SELECT rental.customer_id, COUNT(inventory_id) quantity2
        FROM rental JOIN customer ON rental.customer_id = customer.customer_id
        WHERE customer.active = 1
        GROUP BY rental.customer_id
        ) AS b
    )

-- ez jó megoldásnak tűnik	

/*Melyik filmet kölcsönözték ki a legtöbben? */

SELECT count(*) quantity,
   inventory.film_id, film.title
FROM rental
    JOIN inventory ON rental.inventory_id = inventory.inventory_id
    JOIN film ON inventory.film_id = film.film_id
GROUP BY film.film_id
HAVING quantity = 

(
SELECT MAX(a.quantity1)
FROM
    ( 
    SELECT count(*) quantity1,
        inventory.film_id, film.title
    FROM rental
        JOIN inventory ON rental.inventory_id = inventory.inventory_id
        JOIN film ON inventory.film_id = film.film_id
    GROUP BY film.film_id
    ) AS a
);

	
/*Melyik filmkategória a legnépszerűbb (amit a legtöbben kikölcsönöztek)?*/
SELECT COUNT(rental.rental_id) quantity, category.name
FROM rental 
    JOIN inventory 
        ON rental.inventory_id = inventory.inventory_id
    JOIN film_category 
        ON inventory.film_id = film_category.category_id
    JOIN category 
        ON film_category.category_id = category.category_id
GROUP BY category.name
HAVING quantity = 
    (
    SELECT MAX(a.quantity1)
    FROM
        (
        SELECT COUNT(rental.rental_id) quantity1, category.name
        FROM rental 
            JOIN inventory 
                ON rental.inventory_id = inventory.inventory_id
            JOIN film_category 
                ON inventory.film_id = film_category.category_id
            JOIN category 
                ON film_category.category_id = category.category_id
        GROUP BY category.name
        ) AS a
    );


/*Melyik boltnak volt a legnagyobb bevétele yyyymmdd1 és yyyymmdd2 között 
(mondjuk legyen egy hét)?*/
SELECT SUM(amount) revenue, staff.store_id
FROM payment JOIN staff ON payment.staff_id = staff.staff_id
WHERE payment.payment_date >= DATE('2005-05-25') 
    AND payment.payment_date<= DATE('2005-07-29')
GROUP by staff.store_id
HAVING revenue = 
    (
    SELECT MAX(a.revenue1)
    FROM
        (
        SELECT SUM(amount) revenue1, staff.store_id
        FROM payment JOIN staff ON payment.staff_id = staff.staff_id
        WHERE payment.payment_date >= DATE('2005-05-25') 
            AND payment.payment_date<= DATE('2005-07-29')
        GROUP by staff.store_id
        ) AS a
    )

/*Kik azok az emberek, akik legalább 5 filmet kölcsönöztek, 
de nem kölcsönöztek ki soha horror filmet?*/
SELECT rental.customer_id, COUNT(rental_id) quantity
FROM rental
LEFT OUTER JOIN 
    (
    SELECT rental.customer_id cust_with_horror
    FROM rental
        JOIN inventory 
            ON rental.inventory_id = inventory.inventory_id
        JOIN film_category 
            ON inventory.film_id = film_category.film_id
        JOIN category
            ON film_category.category_id = category.category_id
    WHERE category.name = 'Horror'
    GROUP BY category.name, rental.customer_id
    ) a ON rental.customer_id = a.cust_with_horror
WHERE a.cust_with_horror IS NULL
GROUP BY rental.customer_id
HAVING quantity > 5


/*TO check the results: 148 people have not rented a horror movie*/
    select category.name, film_category.film_id, customer.customer_id
    FROM customer
    JOIN rental on customer.customer_id = rental.customer_id
    JOIN inventory on rental.inventory_id = inventory.inventory_id
    JOIN film_category ON inventory.film_id = film_category.film_id 
    JOIN category ON film_category.category_id = category.category_id
    WHERE rental.customer_id = 20
/**/


/*Ki az, aki a legtöbbet filmet kölcsönözte ki abból a filmkategóriából, ami 
legkevésbé népszerűbb kikölcsönzés szempontjából?*/


SELECT COUNT(rental_id), film_category.category_id, rental.customer_id
FROM rental 
JOIN inventory 
    ON rental.inventory_id = inventory.inventory_id
JOIN film_category 
    ON inventory.film_id = film_category.film_id
GROUP BY rental.customer_id, film_category.category_id
HAVING category_id = 
    (
    SELECT film_category.category_id
    FROM rental
    JOIN inventory 
        ON rental.inventory_id = inventory.inventory_id
    JOIN film_category 
        ON inventory.film_id = film_category.film_id
    GROUP BY film_category.category_id
    HAVING COUNT(rental_id) = 
        (
        SELECT MIN(a.quant_per_cat1)
        FROM 
            (
            SELECT COUNT(rental_id) quant_per_cat1, film_category.category_id
            FROM rental
            JOIN inventory 
                ON rental.inventory_id = inventory.inventory_id
            JOIN film_category 
                ON inventory.film_id = film_category.film_id
            GROUP BY film_category.category_id
            ) AS a
        )
    ) 
ORDER BY COUNT(rental_id) DESC
LIMIT 2 
/* 
Nem akartam tovább bonyolítani.... 
Igy is szopoka mire kigobozod mi van :) 
*/
		
/*Listázd ki minden filmkategóriához azt a filmet, amit a legtöbbet 
kikölcsönöztek!*/
SELECT MAX(a.rents), a.category_id, a.film_id, a.title
FROM
    (
    SELECT COUNT(rental.rental_id) rents, 
        film_category.category_id,
        film_category.film_id,
        film.title
    FROM rental
    JOIN inventory 
        ON rental.inventory_id = inventory.inventory_id
    JOIN film_category
        ON inventory.film_id = film_category.film_id
    JOIN film
        ON film_category.film_id = film.film_id
    GROUP BY film.film_id, film_category.category_id
    ) AS a
GROUP BY category_id


/*Ha lehetséges, hogy egy film több kategóriába is be van sorolva, akkor még 
ezek a kérdéseim
Melyek azok a filmek, amelyek gyerekfilmek, de nem animációsak?
Melyik a leggyakoribb filmkategóriapár a filmeknél (pl. horror-thriller)? 
(Hmm ezt még nem tudom, hogy megoldható-e)*/







