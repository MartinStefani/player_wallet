import * as express from 'express';
import pgPromise from 'pg-promise';
import Joi from '@hapi/joi';

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
            const schema = Joi.object().keys({
                playerId: Joi.number().integer().min(1).required(),
                funds: Joi.number().min(1).max(100).required()
            });

            const {error, value} = schema.validate(req.body);

            if (error) {
                return res.status(400).json({ code: 'ERROR', msg: error.details[0].message });
            }

            const playerId = parseInt(req.body.playerId, 10);
            const funds = parseFloat(req.body.funds);

            const pid = await db.one(`
                UPDATE player
                   SET wallet_funds = $[funds]
                 WHERE player_id = $[playerId]
             RETURNING player_id
                ;`, { playerId, funds });

            return res.json({ code: 'OK' });
        } catch (err) {
            res.json({ error: err.message || err });
        }
    });

    app.post('/api/play-session', async (req: any, res) => {
        try {
            const playerId = parseInt(req.body.playerId, 10);
            const playSessionName = req.body.betAmount || '';
            const betFactor = parseFloat(req.body.betFactor);

            const playSessionId = await db.one(`
                INSERT INTO play_session (player_id, play_session_name, bet_factor)
                     VALUES ($[playerId], $[playSessionName], $[betFactor])
                  RETURNING play_session_id;
            `, { playerId, playSessionName, betFactor });

            return res.json({ playSessionId });
        } catch (err) {
            res.json({ error: err.message || err });
        }
    });

    app.post('/api/bet', async (req: any, res) => {
        try {
            const playSessionId = parseInt(req.body.playSessionId, 10);
            const betAmount = parseFloat(req.body.amount);

            const betId = await db.one(`
                UPDATE play_session
                   SET bet_amount = $[betAmount]
                 WHERE play_session_id = $[playSessionId]
            `, { playSessionId, betAmount });

            return res.json({ playSessionId });
        } catch (err) {
            res.json({ error: err.message || err });
        }
    });

    // Win a bet, a transaction is created and the amount is added to the player.wallet_fund = wallet_fund + betAmount * betFactor
    app.post('/api/win', async (req: any, res) => {
        try {
            const playSessionId = parseInt(req.body.playSessionId, 10);
            const sessionClosingType = 'won';
            const resultCode = 'out';
            const procOutput = await db.proc('play_session_close', { playSessionId, sessionClosingType, resultCode });

            return res.json({ code: procOutput.resultcode });
        } catch (err) {
            res.json({ error: err.message || err });
        }
    });

    // Lose a bet, no transaction is created, just the session is closed
    app.post('/api/lose', async (req: any, res) => {
        try {
            const playSessionId = parseInt(req.body.playSessionId, 10);
            const sessionClosingType = 'lost';
            const resultCode = 'out';
            const procOutput = await db.proc('play_session_close', { playSessionId, sessionClosingType, resultCode });

            return res.json({ code: procOutput.resultcode });
        } catch (err) {
            res.json({ error: err.message || err });
        }
    });

    app.get('/api/history/:playerId', async (req: any, res) => {
        try {
            const playerId = parseInt(req.params.playerId, 10);
            const playerHistory = await db.any(`
                SELECT p.player_id, p.player_name, p.wallet_funds, p.created
                  FROM player AS p
                 WHERE p.player_id = $[playerId];`, { playerId });

            const walletTransactionHistory = await db.any(`
                SELECT wt.wallet_transaction_id,
                       wt.play_session_id,
                       wt.wallet_funds_before,
                       wt.transaction_amount,
                       wt.created
                  FROM wallet_transaction AS wt
                 WHERE wt.player_id = $[playerId]
                 ORDER BY wt.created ASC;`, { playerId });

            const playSessionHistory = await db.any(`
                SELECT ps.play_session_id,
                       ps.play_session_name,
                       ps.session_status,
                       ps.bet_amount,
                       ps.bet_factor,
                       ps.created,
                       ps.last_updated
                  FROM play_session AS ps
                 WHERE ps.player_id = $[playerId];`, { playerId });

            return res.json({ player: playerHistory, wallet_transactions: walletTransactionHistory, play_sessions: playSessionHistory });
        } catch (err) {
            res.json({ code: err.message || err });
        }
    });
}