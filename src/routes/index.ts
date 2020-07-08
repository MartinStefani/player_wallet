import * as express from 'express';
import * as api from './api';

export const register = (app: express.Application) => {
    // default route handler
    app.get('/', (req: any, res) => {
        res.render('index');
    });

    api.register(app);
};