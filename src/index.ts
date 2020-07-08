import dotenv from 'dotenv'
import express from 'express';
import path from 'path';
import * as routes from './routes';

// init config
dotenv.config();

const port = process.env.SERVER_PORT;
const app = express();

app.use(express.json());

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

// define a route handler for the default home page
routes.register(app);
/*
app.get("/", (req, res) => {
    res.render('index');
});
*/

// start the Express server
app.listen(port, () => {
    console.log(`server started at http://localhost:${port}`);
});