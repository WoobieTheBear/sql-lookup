import pg from 'pg';

class PoolFacade {
    _pool = null;

    connect(config) {
        this._pool = new pg.Pool(config);
        return this._pool.query(`SELECT TRUE::BOOLEAN AS connected;`);
    }

    close() {
        return this._pool.end();
    }

    query(statement, parameters) {
        return this._pool.query(statement, parameters);
    }
}

const pool = new PoolFacade();
export default pool;