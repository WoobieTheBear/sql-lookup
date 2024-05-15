import express from 'express';
import { router } from './routes/users.mjs';
import { frontendPort } from '../../../config/local_config.mjs';

class AppFacade {
    _app = null;
    _runner = null;
    init() {
        this._app = express();
        this._app.use(express.json());
        this._app.use(router);
        return this._app;
    }
    start() {
        this._runner = this._app.listen(frontendPort, () => {
            console.log(`app is running on port: ${frontendPort}`);
        });
    }
}

const app = new AppFacade();

export default app;