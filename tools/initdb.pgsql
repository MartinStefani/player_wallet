-- IMPORTANT NOTICE: The database must be already created and set in the .env file
-- -----------------------------------------------------------------------
-- DROP DATABASE IF EXISTS player_wallet_3;
/*
CREATE DATABASE player_wallet_3
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    CONNECTION LIMIT = -1;
*/

-- ===========================================================================
-- player
CREATE TABLE player
(
    player_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    player_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    wallet_funds numeric(8,2) NOT NULL DEFAULT 0,
    created timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT player_pkey PRIMARY KEY (player_id)
);

-- -----------------------------------------------------------------------
-- play_session
CREATE TABLE play_session
(
    play_session_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    player_id integer NOT NULL,
    bet_amount numeric(8,2) NOT NULL DEFAULT 0,
    bet_factor numeric(8,2) NOT NULL DEFAULT 1,
    created timestamp without time zone NOT NULL DEFAULT now(),
    last_updated timestamp without time zone NOT NULL DEFAULT now(),
    play_session_name character varying(50) COLLATE pg_catalog."default",
    session_status character varying(10) COLLATE pg_catalog."default" NOT NULL DEFAULT 'open'::character varying,
    CONSTRAINT play_session_pkey PRIMARY KEY (play_session_id)
);
-- Play_session - End
-- ===========================================================================
-- wallet_transaction - Start
CREATE TABLE wallet_transaction
(
    wallet_transaction_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    player_id integer NOT NULL,
    play_session_id integer NOT NULL,
    wallet_funds_before numeric(8,2) NOT NULL,
    transaction_amount numeric(8,2) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT wallet_transaction_pkey PRIMARY KEY (wallet_transaction_id),
    CONSTRAINT fk_play_session_id FOREIGN KEY (play_session_id)
        REFERENCES play_session (play_session_id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_player_id FOREIGN KEY (player_id)
        REFERENCES player (player_id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE INDEX fki_fk_play_session_id
    ON wallet_transaction USING btree
    (play_session_id ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE INDEX fki_fk_player_id
    ON wallet_transaction USING btree
    (player_id ASC NULLS LAST)
    TABLESPACE pg_default;

-- wallet_transaction - end
-- ===========================================================================
-- Preexisting data
INSERT INTO player (player_name, wallet_funds) VALUES ('Aldo', 0);
INSERT INTO player (player_name, wallet_funds) VALUES ('Boris', 0);
INSERT INTO player (player_name, wallet_funds) VALUES ('Carlos', 0);
INSERT INTO player (player_name, wallet_funds) VALUES ('Dolores', 0);
INSERT INTO player (player_name, wallet_funds) VALUES ('Elmer', 0);
INSERT INTO player (player_name, wallet_funds) VALUES ('Fjodor', 0);
INSERT INTO player (player_name, wallet_funds) VALUES ('Gina', 0);
INSERT INTO player (player_name, wallet_funds) VALUES ('Helen', 0);
INSERT INTO player (player_name, wallet_funds) VALUES ('Izidor', 0);
-- ===========================================================================
-- Procedures
CREATE OR REPLACE PROCEDURE play_session_close(
	playsessionid integer,
	closingstatus character varying,
	INOUT resultcode character varying)
LANGUAGE 'plpgsql'
AS $BODY$
	DECLARE 
		currentSessionStatus VARCHAR(50);
		betAmount NUMERIC(8,2);
		betFactor NUMERIC(8,2);
		walletFundsBefore NUMERIC(8,2);
		transactionAmount NUMERIC(8,2);
		playerId INT;
BEGIN 
	resultCode := 'UNDEFINED';

	SELECT ps.session_status, ps.bet_amount, ps.bet_factor, p.wallet_funds, p.player_id
	  INTO currentSessionStatus, betAmount, betFactor, walletFundsBefore, playerId
	  FROM player AS p
	 INNER JOIN play_session AS ps
			 ON p.player_id = ps.player_id
	 WHERE ps.play_session_id = playSessionId;

	IF (currentSessionStatus <> 'open') THEN
	    resultCode := 'BET_NOT_OPEN';
		RETURN;
	END IF;

	IF (closingStatus = 'won') THEN
	    transactionAmount := betAmount * betFactor;
	
		-- Transaction: begin //TODO
		
		UPDATE play_session
		   SET session_status = closingStatus,
               last_updated = now()
		 WHERE play_session_id = playSessionId;
		 
		INSERT INTO wallet_transaction(player_id, play_session_id, wallet_funds_before, transaction_amount)
		     VALUES (playerId, playSessionId, walletFundsBefore, transactionAmount);
			 
	    UPDATE player
		   SET wallet_funds = wallet_funds + transactionAmount
		 WHERE player_id = playerId;
		 
		 -- Transaction: commit //TODO
		 
		resultCode := 'BET_WON';
	ELSEIF (closingStatus = 'lost') THEN
		UPDATE play_session
		   SET session_status = closingStatus,
               last_updated = now()
		 WHERE play_session_id = playSessionId;
		
        resultCode := 'BET_LOST';
		-- No wallet_transactions
	END IF;
END;
$BODY$;

CREATE OR REPLACE PROCEDURE place_bet(
	playsessionid integer,
	betAmount Numeric(8,2),
	INOUT resultcode character varying)
LANGUAGE 'plpgsql'
AS $BODY$
	DECLARE 
		currentSessionStatus VARCHAR(50);
		betFactor NUMERIC(8,2);
		walletFundsBefore NUMERIC(8,2);
		playerId INT;
BEGIN 
	resultCode := 'UNDEFINED';

	SELECT ps.session_status, p.wallet_funds, p.player_id
	  INTO currentSessionStatus, walletFundsBefore, playerId
	  FROM player AS p
	 INNER JOIN play_session AS ps
			 ON p.player_id = ps.player_id
	 WHERE ps.play_session_id = playSessionId;

	IF (currentSessionStatus <> 'open') THEN
	    resultCode := 'BET_NOT_OPEN';
		RETURN;
	END IF;

	IF (walletFundsBefore >= betAmount) THEN
		-- Transaction: begin //TODO
		
		UPDATE play_session
		   SET bet_amount = bet_amount + betAmount,
		       last_updated = now()
		 WHERE play_session_id = playSessionId;
		 
		INSERT INTO wallet_transaction(player_id, play_session_id, wallet_funds_before, transaction_amount)
		     VALUES (playerId, playSessionId, walletFundsBefore, betAmount);
			 
	    UPDATE player
		   SET wallet_funds = wallet_funds - betAmount
		 WHERE player_id = playerId;
		 
		 -- Transaction: commit //TODO
		 
		resultCode := 'BET_PLACED';
	ELSE
        resultCode := CONCAT('ERROR_INSUFFICIENT_FUNDS (', walletFundsBefore, '; ', betAmount, ')');
		-- No wallet_transactions
	END IF;
END;
$BODY$;