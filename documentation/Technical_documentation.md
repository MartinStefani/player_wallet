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
- *session_funds* which is actually the "bet_amount" (TODO: rename the column to
*bet_amount*).
- *bet_factor* the factor/multiplyer of the bet. A factor of 2 means if the
player wins, will get back double the bet_amount.
- *bet_outcome* is an enum, "open" | "won" | "lost". Updates to the record are
allowed only if "open". If "won" a transaction with the bet is added and the
amount is transferred back to the *wallet_funds* (bef_factor * bet_amount).
If "lost" no second transaction is made.


### Wallet transaction

The *wallet_transaction* table contains the transactions from the wallet to the
plays/sessions.

Non-trivial fields:
- *wallet_funds_before* - the funds in the *player.wallet_funds* before the
transaction. It must be (>= 0).
