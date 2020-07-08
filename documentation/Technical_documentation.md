# Technical documentation


## Database

The database consists of 3 tables:
- *player*
- *play_session*
- *wallet_transaction*

Note: The constraints on the DB should be further enhanced to prevent
inconsistencies. (TODO)


### Player

The *player* table contains all the players. Each player has only one *wallet*
and for simplicity there is a column named *wallet_funds*.


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
plays/sessions.

Non-trivial fields:
- *wallet_funds_before* - the funds in the *player.wallet_funds* before the
transaction. It must be (>= 0).


## API

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
  "responseCode": "CREATED",
  "funds": 12.89
}
```

In case the wallet already exists and has funds, the funds are added and the
*responseCode* is set to "UPDATED".

```json
{
  "responseCode": "UPDATED",
  "funds": 15.99
}
```

#### Error examples:

Invalid player:

Response code: *500*

```json
{
  "responseCode": "ERROR_INVALID_PLAYER"
}
```

#### Response codes

responseCodes        | Descriptions
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
  "responseCode": "CREATED",
  "playSessionId": 111
}
```

#### Error examples:

Invalid player:

Response code: *500*

```json
{
  "responseCode": "ERROR_INVALID_PLAYER"
}
```

#### Response codes

responseCodes            | Descriptions
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
  "responseCode": "CREATED",
  "funds": 12.89
}
```

#### Error examples:

Invalid player:

Response code: *500*

```json
{
  "responseCode": "ERROR_"
}
```

#### Response codes

responseCodes        | Descriptions
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
  "responseCode": "CREATED",
  "funds": 12.89
}
```

#### Error examples:

Invalid player:

Response code: *500*

```json
{
  "responseCode": "ERROR_"
}
```

#### Response codes

responseCodes        | Descriptions
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
  "responseCode": "CREATED",
  "funds": 12.89
}
```

#### Error examples:

Invalid player:

Response code: *500*

```json
{
  "responseCode": "ERROR_"
}
```

#### Response codes

responseCodes        | Descriptions
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
  "responseCode": "CREATED",
  "funds": 12.89
}
```

#### Error examples:

Invalid player:

Response code: *500*

```json
{
  "responseCode": "ERROR_"
}
```

#### Response codes

responseCodes        | Descriptions
---------------------|--------------


### history/GET

Parameter | Data type | Descriptions
----------|-----------|--------------
playerId  | integer   | Existing player id

Request example: `/api/history/{playerId}`
