-- ________ MAINTENANCE ________

-- shows the psql base directory
SHOW data_directory;

-- shows the ids of all databases
-- these ids relate to folders in the base directory
SELECT oid, datname
FROM pg_database;

-- shows the names of the files representing the tables
SELECT * FROM pg_class;

-- shows the stats postgres has gathered about the table
SELECT *
FROM pg_stats
WHERE tablename = 'users';



-- ________ PERFORMANCE ________
CREATE INDEX ON users (username);

-- 'EXPLAIN' => tell what you want to do
-- 'EXPLAIN ANALYZE' => tell me what you want to do and do it
EXPLAIN ANALYZE SELECT * FROM users WHERE username = 'Emil30';
-- with index it took about 0.05 ms

DROP INDEX users_username_idx;

EXPLAIN ANALYZE SELECT * FROM users WHERE username = 'Emil30';
-- without index it took about 0.5 ms

-- upside: an index will speed up the specific query with a where statement
-- downside: per field and per relation considered the index will store data and use up memory
--           in this case users = 872 kB and index = 184 kB
--           to check that use following query
SELECT pg_size_pretty(pg_relation_size('users'));
SELECT pg_size_pretty(pg_relation_size('users_username_idx'));

-- list all existing index relations
SELECT relname, relkind
FROM pg_class
WHERE relkind = 'i';

-- creates an extension
CREATE EXTENSION pageinspect;

-- get the information about bt = b-tree from the metap = metapage
-- among this information you find the 'root' node
SELECT * FROM bt_metap('users_username_idx');

-- in this case 'root' node is page 3 so we
-- get items of page = 3 from the b-tree
SELECT * FROM bt_page_items('users_username_idx', 3);
-- the hex values in the 'data' column will enable comparison
-- this comparison will make it possible to find records faster
-- the tuple in the 'ctid' column represents the (page, index)
-- information that points to the record containing the 'data'
-- every row has a 'ctid' column implicitly created

/*
the cost function looks as follows:
COST = 
    (# pages read sequencially) * seq_page_cost +
    (# pages read at random) * random_page_cost +
    (# rows scanned) * cpu_tuple_cost +
    (# index entries scanned) * cpu_index_tuple_cost +
    (# times function/operator evaluated) * cpu_operator_cost

*/


-- _________ IN PRACTICE ___________

EXPLAIN ANALYZE SELECT username, contents
FROM users
JOIN comments ON comments.user_id = users.id
WHERE username = 'Alyson14';
-- ^ this query will execute in around 5ms

EXPLAIN ANALYZE SELECT username, contents
FROM users
JOIN comments ON comments.user_id = users.id
WHERE users.id = (SELECT id FROM users WHERE username = 'Alyson14');
-- ^ this query will execute in around 3ms
-- this percormance gain is due to the fact
-- that the join can reduce the read operations



