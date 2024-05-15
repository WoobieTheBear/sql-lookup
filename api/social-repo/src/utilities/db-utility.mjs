import pool from "../pool.mjs";
import { testConfig, testDB, testUser, psqlPort, host } from '../../../../config/local_config.mjs';
import { randomBytes } from 'crypto';
import { default as migrate } from 'node-pg-migrate';
import format from 'pg-format';


// snake case to camel case
export const rowsToCamelCase = rows => {
    const camelCaseRows = rows.map(row => {
        const camelCaseRow = {};
        for (let key in row) {
            const camelCaseKey = key.replace(/([-_][a-z])/gi, ($1) => $1.toUpperCase().replace('_', ''));
            camelCaseRow[camelCaseKey] = row[key];
        }
        return camelCaseRow;
    });
    return camelCaseRows;
}

// context for testing
export class Context {
    constructor(roleName, password) {
        this.roleName = roleName;
        this.password = password;
    }
    static async setUp() {
        // generate random role
        const roleName = `tester_${randomBytes(6).toString('hex')}`;
        const password = `pw_${randomBytes(14).toString('hex')}`;
        const tempConfig = {
            host: host,
            port: psqlPort,
            database: testDB,
            user: roleName,
            password: password,
        };

        // connect as test_user to postgres
        await pool.connect(testConfig);

        // create new role with %I (identifier) and %L (literal)
        await pool.query(format(`CREATE ROLE %I WITH LOGIN PASSWORD %L;`, roleName, password));

        // grant user role to test_user
        await pool.query(format(`GRANT %I TO %I;`, roleName, testUser));

        // create schema with same name %I (identifier) and auth %I (identifier) => default schema for roleName
        await pool.query(format(`CREATE SCHEMA %I AUTHORIZATION %I;`, roleName, roleName));

        // disconnect from postgres
        await pool.close();

        // run migrations inside schema
        await migrate({
            schema: roleName,
            direction: 'up',
            log: () => {/* this mutes all logs! */},
            noLock: true,
            dir: 'migrations',
            databaseUrl: tempConfig,
        });

        // connect to postgres
        await pool.connect(tempConfig);

        return new Context(roleName, password);
    }
    async cleanUp() {
        // disconnect from test session
        await pool.close();

        // connect as test_user
        await pool.connect(testConfig);

        // delete the test schema
        await pool.query(format('DROP SCHEMA %I CASCADE;', this.roleName));

        // delete the test role
        await pool.query(format('DROP ROLE %I;', this.roleName));

        // disconnect from postgres
        await pool.close();
    }
}