import app from './src/app.mjs';
import pool from './src/pool.mjs';

import { config } from '../../config/local_config.mjs';

pool.connect(config)
.then(() => {
    app.init();
    app.start();
}).catch( error => {
    console.error(error);
});
