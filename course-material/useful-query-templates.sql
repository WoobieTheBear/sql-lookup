
-- _____ this is pure gold _____

SELECT (
  SELECT MAX(price) FROM products
) AS max, (
  SELECT AVG(price) FROM products
) AS avg, (
  SELECT MIN(price) FROM products
) AS min, (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY price) FROM products
) AS median, (
  SELECT SQRT( VARIANCE(price) ) FROM products
) AS sqrt_variance;


-- _____ always remember this _____

SELECT 
(-32767::SMALLINT) AS min_small,
(32767::SMALLINT) AS max_small,
(-2147483647::INTEGER) AS min_int,
(2147483647::INTEGER) AS max_int,
(-9223372036854775807::BIGINT) AS min_big,
(9223372036854775807::BIGINT) AS max_big;


-- _____ string types _____

SELECT
('biggybiggybiggycantyousee'::TEXT) AS biggy, -- 'biggybiggybiggycantyousee'
('biggybiggybiggycantyousee'::VARCHAR(5)) AS smalls, -- 'biggy'
('true'::BOOLEAN) AS big, -- true
('t'::BOOLEAN) AS smaller, -- true
(1::BOOLEAN) AS weird, -- true
('n'::BOOLEAN) AS nope, -- false
('Y'::BOOLEAN) AS yiss, -- true
('off'::BOOLEAN) AS boerek, --false
(NULL::BOOLEAN) AS no_idea; -- NULL


-- _____ date types _____

SELECT 
('2024-04-23T12:22:23.033+02:00'::DATE) AS date_only,
('10:30 PM PST'::TIME WITH TIME ZONE) AS with_zone,
('2024-04-23T12:22:23.033+02:00'::TIMESTAMP WITH TIME ZONE) AS timestamp,
('1 D 2 H 50 M'::INTERVAL) - ('2 H'::INTERVAL) as arithmetic_inerval;


-- _____ get count of distinct combinations product.department and product.name 

SELECT COUNT(*)
FROM (
  SELECT DISTINCT department, name
  FROM products
);


-- _____ chose greatest value of _____

SELECT name, weight, GREATEST(30, 3*weight)
FROM products;


-- _____ set price range with CASE keyword _____

SELECT
  name, 
  price,
  CASE
    WHEN price > 600 THEN 'high'
    WHEN price > 300 THEN 'medium'
    ELSE 'cheap'
  END AS price_range
FROM products
ORDER BY price ASC, price_range;


-- _____ get fourth and fifth highest unpaid amount per user in descending order with ascending name _____

SELECT full_name, spent
FROM (
  SELECT last_name || ' ' || first_name AS full_name, COUNT(price) AS spent
  FROM orders
  JOIN users ON users.id = orders.user_id
  JOIN products ON products.id = orders.product_id
  WHERE NOT paid
  GROUP BY last_name || ' ' || first_name
)
ORDER BY spent DESC, full_name ASC
LIMIT 2
OFFSET 3;


-- _____ find products by using sub query _____

SELECT name, price
FROM products
WHERE price > (
  SELECT MAX(price)
  FROM products
  WHERE department = 'Toys'
);


-- _____ find average of order count per user _____

SELECT AVG(order_count)
FROM (
  SELECT COUNT(*) as order_count
  FROM users
  JOIN orders ON users.id = orders.user_id
  GROUP BY users.id
);


-- _____ get all max price products for all departments _____

SELECT name, price, department
FROM products p_01
WHERE p_01.price = (
  SELECT MAX(price)
  FROM products p_02
  WHERE p_02.department = p_01.department
)
ORDER BY price DESC;


-- _____ random string from array _____
SELECT ('{"one","two","three","four"}'::text[])[(random()*3+1)] AS val


-- _____ finker dinker _____

SELECT name, price, delta_to_max
FROM (
  SELECT name, price, (SELECT MAX(price) FROM products) - price AS delta_to_max
  FROM products
)
ORDER BY price DESC;


-- _____ find unpaid orders by products _____

SELECT name, (
  SELECT COUNT(*) 
  FROM orders AS o_01
  WHERE p_01.id = o_01.product_id
  AND NOT o_01.paid
) AS placed_orders
FROM products AS p_01;
