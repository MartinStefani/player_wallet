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
    play_session_id integer NOT NULL,
    player_id integer NOT NULL,
    session_funds numeric(8,2) NOT NULL DEFAULT 0,
    bet_factor numeric(8,2) NOT NULL DEFAULT 1,
    created timestamp without time zone NOT NULL,
    last_updated timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT play_session_pkey PRIMARY KEY (play_session_id)
)

TABLESPACE pg_default;

ALTER TABLE public.play_session
    OWNER to postgres;

-- Table: public.wallet_transaction

-- DROP TABLE public.wallet_transaction;

CREATE TABLE public.wallet_transaction
(
    wallet_transaction_id integer NOT NULL,
    player_id integer NOT NULL,
    play_session_id integer NOT NULL,
    wallet_funds_before numeric(8,2) NOT NULL,
    transaction_amount numeric(8,2) NOT NULL,
    created timestamp without time zone NOT NULL,
    CONSTRAINT wallet_transaction_pkey PRIMARY KEY (wallet_transaction_id),
    CONSTRAINT fk_play_session_id FOREIGN KEY (play_session_id)
        REFERENCES public.play_session (play_session_id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
        NOT VALID,
    CONSTRAINT fk_player_id FOREIGN KEY (player_id)
        REFERENCES public.player (player_id) MATCH SIMPLE
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
        NOT VALID
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
