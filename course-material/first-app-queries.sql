-- drop tables

DROP TABLE IF EXISTS photos;
DROP TABLE IF EXISTS users;

-- ___________________ USERS __________________

-- create query

CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  username VARCHAR(255) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE
);

-- insert query

INSERT INTO users (username, email)
VALUES
  ('monahan93', 'emery.becker@yahoo.com'),
  ('pfeffer', 'lesly88@hotmail.com'),
  ('99stroman', 'blaze68@hotmail.com'),
  ('sim3onis', 'nedra1@yahoo.com');


-- ___________________ PHOTOS __________________

-- create query

CREATE TABLE IF NOT EXISTS photos (
  id BIGSERIAL PRIMARY KEY,
  url VARCHAR(255) NOT NULL UNIQUE,
  user_id BIGINT REFERENCES users(id) ON DELETE SET NULL
);

-- insert query

INSERT INTO photos (url, user_id)
VALUES
  ('/flowers.png', 1),
  ('/sunrise.gif', 1),
  ('/dog.png', 4),
  ('/girl.gif', 1),
  ('/nice-man.png', 2),
  ('/smileyface.gif', 1),
  ('/rich-man.png', 2),
  ('/big-chicken.gif', 1),
  ('/birb.png', 4),
  ('/cat.png', 3);


-- join query 01

SELECT photos.id, url, username, email FROM photos
INNER JOIN users ON photos.user_id = users.id
WHERE users.id = 4;


-- join query 02

SELECT MAX(p.id) max_photo_id
FROM photos p
LEFT JOIN comments c ON p.id = c.photo_id
LEFT JOIN users u ON u.id = c.user_id AND u.id = p.user_id
GROUP BY u.id;


-- aggregate query

SELECT user_id, STRING_AGG(contents, ':|:') all_comments
FROM comments
GROUP BY user_id;
