import * as express from 'express';
import pgPromise from 'pg-promise';

export const register = (app: express.Application) => {
    const port = parseInt(process.env.PGPORT || '5432', 10);
    const config = {
        database: process.env.PGDATABASE,
        host: process.env.PGHOST,
        port,
        user: process.env.PGUSER
    }

    const pgp = pgPromise();
    const db = pgp(config);

    app.put('/api/wallet', async (req: any, res) => {
        try {
            const playerId = parseInt(req.body.playerId, 10);
            const funds = parseFloat(req.body.funds);

            const pid = await db.one(`
                UPDATE player
                   SET wallet_funds = $[funds]
                 WHERE player_id = $[playerId]
             RETURNING player_id
                ;`, { playerId, funds });
            return res.json({ pid });
        } catch (err) {
            res.json({ error: err.message || err });
        }
    });


    app.get('/api/history/:playerId', async (req: any, res) => {
        try {
            const playerId = parseInt(req.params.playerId, 10);
            const history = await db.any(`
                SELECT player_id
                  FROM player
                 WHERE player_id = $[playerId]
                ORDER BY player_id`, { playerId });

            return res.json(history);
        } catch (err) {
            res.json({ code: err.message || err });
        }
    });
}