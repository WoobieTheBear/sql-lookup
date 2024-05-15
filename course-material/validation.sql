
DROP TABLE IF EXISTS products;

-- ________ create table statement ________

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(40),
    department VARCHAR(40),
    price INTEGER,
    weight INTEGER
);


-- ________ insert statement ________

INSERT INTO products (name, department, price, weight)
VALUES
    ('Shirt', 'Clothes', 20, 1);

INSERT INTO products (name, department, weight)
VALUES
    ('Pants', 'Clothes', 3);


-- ________ alter table [FAILS] ________

ALTER TABLE products
ALTER COLUMN price
SET NOT NULL;


-- ________ update NULL values ________

UPDATE products
SET price = 9999
WHERE price IS NULL;


-- ________ alter table [WORKS NOW] ________

ALTER TABLE products
ALTER COLUMN price
SET NOT NULL;


-- ________ insert statement [FAILS NOW] ________

INSERT INTO products (name, department, weight)
VALUES
    ('Pants', 'Clothes', 3);



-- ________ strictly constrained create statement ________

DROP TABLE IF EXISTS products;

-- ________ create table statement ________

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    department VARCHAR(40) NOT NULL,
    price INTEGER NOT NULL,
    weight INTEGER
);




-- ________ default value create statement ________

DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS orders;

-- ________ create table statement ________

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(40) UNIQUE NOT NULL,
    department VARCHAR(40) NOT NULL,
    price INTEGER NOT NULL DEFAULT 99999 CHECK (price > 0),
    weight INTEGER
);

INSERT INTO products (name, department, price, weight)
VALUES
    ('Red Shirt', 'Clothes', 20, 1),
    ('Shirt', 'Tools', 24, 1);

INSERT INTO products (name, department, weight)
VALUES
    ('Gloves', 'Clothes', 3);


-- ________ check date consistency ________

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    name VARCHAR(40) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    est_delivery TIMESTAMP NOT NULL,
    CHECK (created_at < est_delivery)
);

INSERT INTO orders (name, created_at, est_delivery)
VALUES
    ('Shirt', '2024-MAY-04 02:00 PM', '2024-MAY-05 02:00 PM');




