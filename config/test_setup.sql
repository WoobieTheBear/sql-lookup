-- <START DATABASE CREATION AND SCHEMA SETUP>
DROP DATABASE IF EXISTS socialtest;
CREATE DATABASE socialtest;
\connect socialtest;

-- set up the role for test client called "test_user"
DROP ROLE IF EXISTS test_user;

-- [INFO]: this user and password is referenced in $DATABASE_URL
CREATE ROLE test_user WITH CREATEROLE PASSWORD 'Changeme-123';
ALTER ROLE test_user WITH LOGIN;
GRANT CREATE, CONNECT, TEMPORARY ON DATABASE socialtest TO test_user;

-- then run following command in "cmd" from npm project root directory $>
-- set DATABASE_URL=postgresql://test_user:Changeme-123@localhost:5432/socialtest&& npm run migrate up
