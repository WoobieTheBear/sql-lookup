import pool from '../pool.mjs';
import { rowsToCamelCase } from '../utilities/db-utility.mjs';

export default class UserRepo {
    static async find() {
        const { rows } = await pool.query(`SELECT * FROM users;`);
        return rowsToCamelCase(rows);
    }
    static async findById(id) {
        // [NOTE]: inserting a user input into a query as string will enable SQL injection
        //         following query will demonstrate SQL injection.
        // const { rows } = await pool.query(`SELECT * FROM users WHERE id = ${id};`);
        const { rows } = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
        return rowsToCamelCase(rows)[0];
    }
    static async insert(entry) {
        const { username, bio } = entry;
        const { rows } = await pool.query('INSERT INTO users (username, bio) VALUES ($1, $2) RETURNING *;', [username, bio]);
        return rowsToCamelCase(rows)[0];
    }
    static async update(id, entry) {
        const { username, bio } = entry;
        const { rows } = await pool.query('UPDATE users SET username = $1, bio = $2 WHERE id = $3 RETURNING *;', [username, bio, id]);
        return rowsToCamelCase(rows)[0];
    }
    static async delete(id) {
        const { rows } = await pool.query('DELETE FROM users WHERE id = $1 RETURNING *;', [id]);
        return rowsToCamelCase(rows)[0];
    }
    static async count() {
        const { rows } = await pool.query('SELECT COUNT(*) FROM users;');
        return parseInt(rows[0].count);
    }
    // this function is relevant for tests please do not use for an endpoint
    static async deleteAll() {
        const { rows } = await pool.query('DELETE FROM users RETURNING *;');
        return rowsToCamelCase(rows);
    }
}
