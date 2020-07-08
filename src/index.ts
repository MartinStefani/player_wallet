import dotenv from 'dotenv'
import express from 'express';
import path from 'path';
import * as routes from './routes';
import morgan from 'morgan';
import fs from 'fs';
import basicAuth from 'express-basic-auth';

// init config
dotenv.config();

const port = process.env.SERVER_PORT;
const app = express();

// Logging
const logger = morgan('combined');
const accessLogStream = fs.createWriteStream(path.join(__dirname, '../log/access.log'), { flags: 'a' });
app.use(morgan('combined', { stream: accessLogStream }));

app.use(express.json());

app.use(basicAuth({
    users: { 'backend': 'tellno1' }
}));

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

routes.register(app);

// start the Express server
app.listen(port, () => {
    console.log(`server started at http://localhost:${port}`);
});