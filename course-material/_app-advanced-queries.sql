-- __________ FILTER OUTSIDE __________
EXPLAIN ANALYZE
SELECT users.username, tags.created_at
FROM users
JOIN (
	SELECT user_id, created_at FROM caption_tags
	UNION
	SELECT user_id, created_at FROM photo_tags
) AS tags ON tags.user_id = users.id
WHERE tags.created_at < '2010-01-07';
-- ^ this query has "Execution Time: 2.363 ms" and "Planning Time: 13.293 ms"



-- __________ FILTER INSIDE __________
EXPLAIN ANALYZE
SELECT users.username, tags.created_at
FROM users
JOIN (
	SELECT user_id, created_at FROM caption_tags
	WHERE created_at < '2010-01-07'
	UNION
	SELECT user_id, created_at FROM photo_tags
	WHERE created_at < '2010-01-07'
) AS tags ON tags.user_id = users.id;
-- ^ this query has "Execution Time: 2.528 ms" and "Planning Time: 0.239 ms"



-- __________ CTE (WITH statement non recursive) __________
WITH tags AS (
	SELECT user_id, created_at FROM caption_tags
	WHERE created_at < '2010-01-07'
	UNION
	SELECT user_id, created_at FROM photo_tags
	WHERE created_at < '2010-01-07'
)
SELECT users.username, tags.created_at
FROM users
JOIN tags ON tags.user_id = users.id;
-- ^ this query has "Execution Time: 3.459 ms" and "Planning Time: 0.376 ms"



-- __________ RECURSIVE CTE __________
WITH RECURSIVE countdown(val) AS (
    SELECT 9 AS val
    UNION -- every recursive CTE must have a UNION statement
    SELECT val - 1 FROM countdown WHERE val > 0
)
SELECT * FROM countdown;
/*
NOTE: ^ this query prints all digits using following steps:
1. initialize 'working table' and 'results table' with the columns 'val'
2. read the first query and put the result of the first query into the first row on both tables
3. execute the second query and put the result of the updated value
   into the next row of the 'results table' and the only row in the 'working table'
4. repeat step 3 until the WHERE condition is not met by the rows of the 'working table'
5. return the 'results table' as results to the 'countdown' descriptor
*/


-- following query finds leaders of people that user with id 1000 is following
-- this recursion goes down 3 levels
WITH RECURSIVE suggestions(leader_id, follower_id, depth) AS (
        SELECT leader_id, follower_id, 1 AS depth
        FROM followers
        WHERE follower_id = 1000
    UNION
        SELECT followers.leader_id, followers.follower_id, depth + 1
        FROM followers
        JOIN suggestions ON suggestions.leader_id = followers.follower_id
        WHERE depth < 3
)
SELECT DISTINCT users.id, users.username
FROM suggestions
JOIN users ON users.id = suggestions.leader_id
WHERE depth > 1
LIMIT 30;


-- order users by times they appear in tags
SELECT username, COUNT(*)
FROM users
JOIN (
	SELECT user_id FROM photo_tags
	UNION ALL -- keep all duplicates
	SELECT user_id FROM caption_tags
) AS tags ON tags.user_id = users.id
GROUP BY username
ORDER BY COUNT(*) DESC;



-- __________ VIEWS __________

-- create a view for all tags
CREATE VIEW tags AS (
	SELECT id, created_at, user_id, post_id, 'photo_tag' AS type FROM photo_tags
	UNION ALL -- keep all duplicates
	SELECT id, created_at, user_id, post_id, 'caption_tag' AS type FROM caption_tags
);


-- create a view for recent posts
CREATE VIEW recent_posts AS (
	SELECT *
	FROM posts
	ORDER BY created_at DESC
	LIMIT 10
);

-- update a view for recent posts
CREATE OR REPLACE VIEW recent_posts AS (
	SELECT *
	FROM posts
	ORDER BY created_at DESC
	LIMIT 15
);

-- delete the view for recent posts
DROP VIEW recent_posts;



-- __________ MATERIALIZED VIEWS __________

-- original query
SELECT 
	date_trunc('week', COALESCE(posts.created_at, comments.created_at)) AS week,
	COUNT(posts.id) AS num_post_likes,
	COUNT(comments.id) AS num_comment_likes
FROM likes
LEFT JOIN posts ON posts.id = likes.post_id
LEFT JOIN comments ON comments.id = likes.comment_id
GROUP BY week
ORDER BY week;
-- ^ takes 'Planning Time: 0.258 ms' and 'Execution Time: 1935.987 ms'

-- turn query into materialized view
CREATE MATERIALIZED VIEW weekly_likes AS (
	SELECT 
		date_trunc('week', COALESCE(posts.created_at, comments.created_at)) AS week,
		COUNT(posts.id) AS num_post_likes,
		COUNT(comments.id) AS num_comment_likes
	FROM likes
	LEFT JOIN posts ON posts.id = likes.post_id
	LEFT JOIN comments ON comments.id = likes.comment_id
	GROUP BY week
	ORDER BY week
) WITH DATA;

SELECT * FROM weekly_likes;
-- ^ takes 'Planning Time: 0.030 ms' and 'Execution Time: 0.042 ms'

-- NOTE: be very cautious, a materialized view will not automatically update!
DELETE FROM posts
WHERE created_at < '2010-02-01';
-- ^ this will turn the view data invalid

REFRESH MATERIALIZED VIEW weekly_likes;
-- ^ this will refresh the data in the materialized view



-- __________ TRANSACTIONS __________

-- reset existing table
DROP TABLE IF EXISTS accounts;

-- setup table
CREATE TABLE accounts (
	id SERIAL PRIMARY KEY,
	name VARCHAR(31) NOT NULL,
	balance INTEGER NOT NULL DEFAULT 0
);

-- insert two rows
INSERT INTO accounts (name, balance)
VALUES 
('Gia', 100),
('Alyson', 100);

-- start transaction or workspace with BEGIN
BEGIN;

-- update row one
UPDATE accounts
SET balance = balance - 50
WHERE name = 'Alyson';

-- locally shows the updates [all updates still volatile]
SELECT * FROM accounts;

-- update row two
UPDATE accounts
SET balance = balance + 50
WHERE name = 'Gia';

-- locally shows the updates [all updates still volatile]
SELECT * FROM accounts;

-- commit updates with COMMIT
COMMIT;

-- updates are persisted
SELECT * FROM accounts;

-- start another transaction with BEGIN
BEGIN;

-- update row one
UPDATE accounts
SET balance = balance - 50
WHERE name = 'Alyson';

-- make a faulty query
SELECT * FROM nocando;

-- whenever you get into an 'aborted' state you can rollback your transactions
ROLLBACK;


