-- <START DATABASE CREATION AND SCHEMA SETUP>
DROP DATABASE IF EXISTS socialnetwork;
CREATE DATABASE socialnetwork;
\connect socialnetwork;

-- drop privileges
REASSIGN OWNED BY migration_user TO postgres;
DROP OWNED BY migration_user;

-- set up the role for migration client called "migration_user"
DROP ROLE IF EXISTS migration_user;

-- [INFO]: this user and password is referenced in $DATABASE_URL
CREATE ROLE migration_user WITH PASSWORD 'Changeme-123';
ALTER ROLE migration_user WITH LOGIN;
GRANT CREATE, CONNECT, TEMPORARY ON DATABASE socialnetwork TO migration_user;

-- then run following command in "cmd" from npm project root directory $>
-- set DATABASE_URL=postgresql://migration_user:Changeme-123@localhost:5432/socialnetwork&& npm run migrate up
