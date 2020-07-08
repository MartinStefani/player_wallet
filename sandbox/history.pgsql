SELECT p.player_id, p.player_name, p.wallet_funds, p.created
  FROM player AS p
 WHERE p.player_id = 2;

SELECT wt.wallet_transaction_id,
       wt.play_session_id,
       wt.wallet_funds_before,
       wt.transaction_amount,
       wt.created
  FROM wallet_transaction AS wt
 WHERE wt.player_id = 2
 ORDER BY wt.created ASC
 ;

 SELECT ps.play_session_id,
        ps.play_session_name,
        ps.session_status,
        ps.bet_amount,
        ps.bet_factor,
        ps.created,
        ps.last_updated
   FROM play_session AS ps
  WHERE ps.player_id = 2;


