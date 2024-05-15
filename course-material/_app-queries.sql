


SELECT * FROM users
ORDER BY id DESC
LIMIT 3;



SELECT users.id, users.username, posts.caption
FROM users
JOIN posts ON posts.user_id = users.id
WHERE users.id = 200;



SELECT username, COUNT(likes.post_id) post_id, COUNT(likes.comment_id) comment_id
FROM users
JOIN likes ON likes.user_id = users.id
GROUP BY username;


