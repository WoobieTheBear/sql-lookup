import express from 'express';
import pg from 'pg';
import { config } from '../config/local_config.mjs';
import { frontendPort } from '../config/local_config.mjs';

const pool = new pg.Pool(config);

// to test the connection use following statement
// pool.query('SELECT TRUE::BOOLEAN AS connected;').then(result => console.log(result));

/* 
NOTE: before starting the server again run $>

psql -U postgres -f .\config\user_setup.sql

from the project root directory
*/

const app = express();
app.use(express.urlencoded({ extended: true }));

app.get('/posts', async (req, res) => {
    const { rows } = await pool.query(`
        SELECT * FROM posts;
    `);

    console.log('GET /posts ', rows);

    // following page is vulnerable to XSS
    res.send(`
    <!DOCTYPE html>
    <html lang="en-US" dir="ltr">
        <head>
            <meta charset="utf-8" />
            <title>The App</title>
            <style>html, body {font-family: monospace; font-size: 20px;}</style>
        </head>
        <body>
            <table>
                <thead>
                    <th>id</th>
                    <th>lng</th>
                    <th>lat</th>
                </thead>
                <tbody>
                    ${rows.map(row => {
                        // this way of creating html enables attackers to use XSS
                        const { id, url, loc: {x, y} } = row;
                        // TODO: clean all values here
                        return `
                            <tr>
                                <td>${id}</td>
                                <td>${url}</td>
                                <td>${x}</td>
                                <td>${y}</td>
                            </tr>
                        `;
                    })}
                </tbody>
            </table>
            <form method="POST">
                <h3>Create Post</h3>
                <div>
                    <label>URL</label>
                    <input type="text" name="url" placeholder="url" />
                </div>
                <div>
                    <label>LNG</label>
                    <input type="number" step="0.01" name="lng" />
                </div>
                <div>
                    <label>LAT</label>
                    <input type="number" step="0.01" name="lat" />
                </div>
                <button>send</button>
            </form>
        </body>
    </html>
    `);
});

app.post('/posts', async (req, res) => {
    const { body: { url, lat, lng } } = req;
    await pool.query(
        'INSERT INTO posts (url, loc) VALUES ($1, $2);',
        [url, `(${lng}, ${lat})`]
    );
    res.redirect('/posts');
})


const runner = app.listen(frontendPort, () => {
    console.log(`PoC is running on port: ${frontendPort}`);
});
let connections = [];
runner.on('connection', connection => {
    connections.push(connection);
    connection.on('close', () => connections = connections.filter(curr => curr !== connection));
});
const onShutDown = () => {
    console.log('Kill signal recieved, shutting down gracefully');
    console.log('Closing psql pool');
    pool.end();
    runner.close(() => {
        console.log('Closed out remaining connections');
        process.exit(0);
    });

    setTimeout(() => {
        console.error('Could not close connections in time, forcefully shutting down');
        process.exit(1);
    }, 10000);

    connections.forEach(curr => curr.end());
    setTimeout(() => connections.forEach(curr => curr.destroy()), 5000);
}
process.on('SIGTERM', onShutDown);
process.on('SIGINT', onShutDown);

