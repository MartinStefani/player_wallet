CREATE DATABASE player_wallet
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    CONNECTION LIMIT = -1;

CREATE SCHEMA public
    AUTHORIZATION postgres;

COMMENT ON SCHEMA public
    IS 'standard public schema';

GRANT ALL ON SCHEMA public TO PUBLIC;

GRANT ALL ON SCHEMA public TO postgres;

-- Type: session_status

-- DROP TYPE public.session_status;

CREATE TYPE public.session_status AS ENUM
    ('open', 'won', 'lost');

ALTER TYPE public.session_status
    OWNER TO postgres;

-- Table: public.player

-- DROP TABLE public.player;

CREATE TABLE public.player
(
    player_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    player_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    wallet_funds numeric(8,2) NOT NULL DEFAULT 0,
    created timestamp without time zone NOT NULL,
    CONSTRAINT player_pkey PRIMARY KEY (player_id)
)

TABLESPACE pg_default;

ALTER TABLE public.player
    OWNER to postgres;

-- Table: public.play_session

-- DROP TABLE public.play_session;

CREATE TABLE public.play_session
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
)

TABLESPACE pg_default;

ALTER TABLE public.play_session
    OWNER to postgres;

-- Play_session - End
-- ===========================================================================
-- wallet_transaction - Start

-- Table: public.wallet_transaction

-- DROP TABLE public.wallet_transaction;

CREATE TABLE public.wallet_transaction
(
    wallet_transaction_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    player_id integer NOT NULL,
    play_session_id integer NOT NULL,
    wallet_funds_before numeric(8,2) NOT NULL,
    transaction_amount numeric(8,2) NOT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT wallet_transaction_pkey PRIMARY KEY (wallet_transaction_id),
    CONSTRAINT fk_play_session_id FOREIGN KEY (play_session_id)
        REFERENCES public.play_session (play_session_id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT fk_player_id FOREIGN KEY (player_id)
        REFERENCES public.player (player_id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
)

TABLESPACE pg_default;

ALTER TABLE public.wallet_transaction
    OWNER to postgres;
-- Index: fki_fk_play_session_id

-- DROP INDEX public.fki_fk_play_session_id;

CREATE INDEX fki_fk_play_session_id
    ON public.wallet_transaction USING btree
    (play_session_id ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: fki_fk_player_id

-- DROP INDEX public.fki_fk_player_id;

CREATE INDEX fki_fk_player_id
    ON public.wallet_transaction USING btree
    (player_id ASC NULLS LAST)
    TABLESPACE pg_default;

-- wallet_transaction - end
-- ===========================================================================

-- Preexisting data
INSERT INTO player (player_name, wallet_funds)
     VALUES ('Aldo Baio', 0);


-- Procedures

CREATE OR REPLACE PROCEDURE public.play_session_close(
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
		   SET session_status = closingStatus
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
		
		-- No wallet_transactions
	END IF;
END;
$BODY$;
