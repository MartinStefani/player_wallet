# Player wallet

## About

This is a study application with the following technologies:
- node.js
- espress
- typescript
- PostgreSQL

How it works:
- there is no GUI, just API endpoints
- there is a Postman collection of tests in the `./tests` directory
- a simple log file is located in `./bin/www/log/`
- *Basic authentication* is used with a hardcoded username and password.

Notes:
- Git: the project is small there are not many commits. To better show how I use Git (Git Flow) I committed all the
  branches and keept them.
- PostgreSQL: there are two procedures in the project. PostgreSQL 12 was used (the current Stable version).
- There is a more technical documentation in `./documentation/Technical_documentation.md`

## Setup

1. Create the database 
```sql
CREATE DATABASE player_wallet
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    CONNECTION LIMIT = -1;
```

2. Set the environment config file `.env` with the DB values an Node port.

3. Update the modules: `$ node install`.

4. Import the DB schema, procedure and data: `$ npm run initdb`.

5. Run the application: `$ npm run dev`

6. Open Postman and import the collection `./tests/Player wallet.postman_collection.json`.


## How it works

The main point was to connect all the functionalities into a working example.

All the functionalities are prepared in the test cases in Postman. It's only a matter
of going through the and click "Send" on each of them.


### Starting point:

There are some preexisting "Players" (records in the *player* table)


### Players' wallets

In the *Wallet* collection in Postman there are PUT requests that set the value in the players' wallets. For 
simplicity, since each Player can have only one Wallet, they are both in the same table - a player record has a wallet
column - `player.wallet_funds`. This doesn't get recorded as a transaction in the app.

The funds amount must be a number > 1.


### Play session

I think of a *play session* like a Game. By posting to `api/play-session` a new session is created with a bet factor.

While the session is "open" a player can place bets.


### Betting

While a session is "open", the *betAmount* can be changed, but not the *betFactor*. This is done by posting to 
`api/bet`. This creates a transaction in the *wallet_transaction* table.


### Winning

By posting to `api/win` the bet is won. The winning amount is calculated by the formula: 
`winningAmount = betAmount * betFactor`.

This event closes the Session (*session_satus=won*), creates a transaction in the *wallet_transaction* table and adds
the winningAmount to the *player.wallet_funds*. The three steps are done in the DB with a procedure named 
*play_session_close*.


### Losing

By posting to `api/lose` the the bet is marked a lost. The session is closed and no transaction is created, for there
are no funds to transfer.


### History

To view all the player's data, the transactions and open *play sessions*, the `api/history` GET request is used which
returns all the mentioned data.


## Known issues

- The data validation is in place but is not include all possible cases.
- The authentication should be at least read from a config.
- The *.env* file should not be put in version control, but a sample `.env.sample` should be.
- The endpoints could be split in separate files.
- There is no handling for invalid requests, to inexistent endpoints or method types.
- The technical documentation is very rudimentary (`./documentation/Technical_documentation.md`) and not complete.
- The store procedures should use transactions because they are modifying multiple tables.
- The logging is very basic, but it works. A package named *Winston* could be used to improve that.