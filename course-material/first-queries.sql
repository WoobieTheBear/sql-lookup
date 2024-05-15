-- ___________________ CITIES __________________

-- drop table cities

DROP TABLE IF EXISTS cities;

-- create query

CREATE TABLE IF NOT EXISTS cities (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255),
  country VARCHAR(255),
  population BIGINT,
  area BIGINT
);

-- insert query

INSERT INTO cities (name, country, population, area)
VALUES
  ('Tokyo', 'Japan', 38505000, 8223),
  ('Dheli', 'India', 28125000, 2240),
  ('Shanghai', 'China', 22125000, 4015),
  ('Sao Paulo', 'Brazil', 20935000, 3043);

-- select query

SELECT name, population FROM cities WHERE population > 28000000;
SELECT CONCAT(UPPER(name), ' in ', UPPER(country)) AS location FROM cities;

-- nested queries

SELECT name, area, population
FROM cities 
WHERE name NOT IN 
  (SELECT name FROM cities WHERE population > 22000000);

-- update statement

UPDATE cities
SET population = 39505000
WHERE name = 'Tokyo';



-- ___________________ PHONES __________________

DROP TABLE IF EXISTS phones;

-- create query

CREATE TABLE IF NOT EXISTS phones (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255),
  manufacturer VARCHAR(255),
  price BIGINT,
  units_sold BIGINT
);

-- insert query

INSERT INTO phones (name, manufacturer, price, units_sold)
VALUES
  ('N1280', 'Nokia', 199, 1925),
  ('Iphone 4', 'Apple', 399, 9436),
  ('Galaxy S', 'Samsung', 299, 2359),
  ('S5620 Monte', 'Samsung', 250, 2385),
  ('N8', 'Nokia', 150, 7543),
  ('Droid', 'Motorola', 150, 8359),
  ('Wave S8500', 'Samsung', 175, 9259);

-- Write query here to update the 'units_sold' of the phone with name 'N8' to 8543
UPDATE phones SET units_sold = 8543 WHERE name = 'N8';

-- Write query here to select all rows and columns of the 'phones' table
SELECT * FROM phones;


