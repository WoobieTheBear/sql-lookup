# SQL Lookup

A lookup for SQL queries and how to set up migration workflow in this specific case with node-pg-migrate for nodejs but generally as an idea on how to make parallel testing work with a psql database.

# Setup

1. Install postgres
2. Install nodejs
3. Navigate to folder `./api/social-repo` or `./migration`
4. Run `npm install`
5. Navigate to folder `./config`
6. Run all necessary setup scripts for databases `socialnetwork` and for `socialtest`
7. Navigate to folder `./api/social-repo` or `./migration`
8. Run `npm start`
9. Optionally run the test requests from `test-request.http` using VS-Code HTTP-Client