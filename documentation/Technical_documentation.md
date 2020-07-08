# Technical documentation

**IMPORTANT NOTICE - THE API ENDPOINTS BELOW ARE NOT UP-TO-DATE**

There are better tools to show the API documentation. I personally like [Slate](https://github.com/slatedocs/slate).


## Database

The database consists of 3 tables:
- *player*
- *play_session*
- *wallet_transaction*

Notes: 
- Although there are foreign keys, their behaviour should be further enhanced by e.g. restricting updates.


### Player

The *player* table contains all the players. Each player has only one *wallet* and for simplicity there is a column 
named *wallet_funds*.


### Play session

The *play_session* table contains all the sessions/bets.

Non-trivial fields:
- *bet_amount* the amount transferred from the wallet and used for the bet.
- *bet_factor* the factor/multiplayer of the bet. A factor of 2 means if the
player wins, will get back double the bet_amount.
- *bet_outcome* is an enum, "open" | "won" | "lost". Updates to the record are
allowed only if "open". If "won" a transaction with the bet is added and the
amount is transferred back to the *wallet_funds* (bet_factor * bet_amount).
If "lost" no second transaction is made.


### Wallet transaction

The *wallet_transaction* table contains the transactions from the wallet to the
plays/sessions. These transactions are:
- transferring funcs from the wallet to a play_session (a bet),
- a won bet to transfer the won amount to the wallet.

Non-trivial fields:
- *wallet_funds_before* - the funds in the *player.wallet_funds* before the
transaction. It must be (>= 0).


### Procedures

The reasons I used procedures are performance (one request instead of many) and transactions. However I didn't have
time to implement the transactions in PostgreSQL, as they are different than MySQL, MSSQL and the are out of scope 
of the project.


## API

### Authentication

*Basic authentication* is used and the credentials are hardcoded to 'backend/tellno1'. This if for demonstration 
purposes.

The credentials should be read from a config or DB.


### wallet/POST

Creates or updates the wallet by adding funds.


#### Successful examples:

Request for an nonexistent wallet:
```json
{
  "playerId": 1,
  "funds": 12.89
}
```

Response code: *200*

```json
{
  "code": "CREATED",
  "funds": 12.89
}
```

In case the wallet already exists and has funds, the funds are added and the
*code* is set to "UPDATED".

```json
{
  "code": "UPDATED",
  "funds": 15.99
}
```

#### Error examples:

Invalid player:

Response code: *500*

```json
{
  "code": "ERROR_INVALID_PLAYER"
}
```

#### Response codes

codes        | Descriptions
---------------------|--------------
CREATED              | The wallet was created.
UPDATED              | The posted amount was added to an. existing amount
ERROR_INVALID_PLAYER | The player does not exist.
ERROR_INVALID_FUNDS  | The funds amount must be greater than 0.


### playSession/POST

Creates a new play session.

#### Successful example

Request example:
```json
{
  "playerId": 1,
  "sessionName": "Horse: Scooby Doo",
  "betFactor": 2.5
}
```

Response code: *200*

```json
{
  "code": "CREATED",
  "playSessionId": 111
}
```

#### Error examples:

Invalid player:

Response code: *500*

```json
{
  "code": "ERROR_INVALID_PLAYER"
}
```

#### Response codes

codes            | Descriptions
-------------------------|--------------
CREATED                  | The play session was successfully created
ERROR_INVALID_PLAYER     | Invalid playerId provided
ERROR_INVALID_BET_FACTOR | The bet factor must be > 1.


### bet/POST

Request for an nonexistent wallet:
```json
{
  "playerId": 1,
  "funds": 12.89
}
```

Response code: *200*

```json
{
  "code": "CREATED",
  "funds": 12.89
}
```

#### Error examples:

Invalid player:

Response code: *500*

```json
{
  "code": "ERROR_"
}
```

#### Response codes

codes        | Descriptions
---------------------|--------------


### win/POST


Request for an nonexistent wallet:
```json
{
  "playerId": 1,
  "funds": 12.89
}
```

Response code: *200*

```json
{
  "code": "CREATED",
  "funds": 12.89
}
```

#### Error examples:

Invalid player:

Response code: *500*

```json
{
  "code": "ERROR_"
}
```

#### Response codes

codes        | Descriptions
---------------------|--------------


### lose/POST

Request for an nonexistent wallet:
```json
{
  "playerId": 1,
  "funds": 12.89
}
```

Response code: *200*

```json
{
  "code": "CREATED",
  "funds": 12.89
}
```

#### Error examples:

Invalid player:

Response code: *500*

```json
{
  "code": "ERROR_"
}
```

#### Response codes

codes        | Descriptions
---------------------|--------------


#### Successful examples:

Request for an nonexistent wallet:
```json
{
  "playerId": 1,
  "funds": 12.89
}
```

Response code: *200*

```json
{
  "code": "CREATED",
  "funds": 12.89
}
```

#### Error examples:

Invalid player:

Response code: *500*

```json
{
  "code": "ERROR_"
}
```

#### Response codes

codes        | Descriptions
---------------------|--------------


### history/GET

Parameter | Data type | Descriptions
----------|-----------|--------------
playerId  | integer   | Existing player id

Request example: `/api/history/{playerId}`

Response example:
```json

    "player": [
        {
            "player_id": 1,
            "player_name": "Aldo",
            "wallet_funds": "10.97",
            "created": "2020-07-08T14:06:03.628Z"
        }
    ],
    "wallet_transactions": [
        {
            "wallet_transaction_id": 1,
            "play_session_id": 1,
            "wallet_funds_before": "12.34",
            "transaction_amount": "2.75",
            "created": "2020-07-08T15:42:15.884Z"
        },
        {
            "wallet_transaction_id": 2,
            "play_session_id": 1,
            "wallet_funds_before": "9.59",
            "transaction_amount": "2.75",
            "created": "2020-07-08T15:43:02.100Z"
        },
        {
            "wallet_transaction_id": 3,
            "play_session_id": 1,
            "wallet_funds_before": "6.84",
            "transaction_amount": "4.13",
            "created": "2020-07-08T15:50:04.970Z"
        }
    ],
    "play_sessions": [
        {
            "play_session_id": 1,
            "play_session_name": "",
            "session_status": "won",
            "bet_amount": "2.75",
            "bet_factor": "1.50",
            "created": "2020-07-08T15:09:35.985Z",
            "last_updated": "2020-07-08T15:43:02.100Z"
        },
        {
            "play_session_id": 2,
            "play_session_name": "",
            "session_status": "open",
            "bet_amount": "0.00",
            "bet_factor": "1.50",
            "created": "2020-07-08T15:50:39.422Z",
            "last_updated": "2020-07-08T15:50:39.422Z"
        },
        {
            "play_session_id": 3,
            "play_session_name": "Beta",
            "session_status": "open",
            "bet_amount": "0.00",
            "bet_factor": "2.10",
            "created": "2020-07-08T15:52:03.242Z",
            "last_updated": "2020-07-08T15:52:03.242Z"
        }
    ]
}
```
