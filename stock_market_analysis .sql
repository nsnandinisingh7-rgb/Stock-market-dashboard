/* =====================================================================
   STOCK MARKET ANALYSIS IN SQL  -  MySQL 8 submission file
   Six NSE stocks, 2015-01-01 to 2018-07-31 (889 trading days each)
   Runs top to bottom on a fresh database. Every created table/function
   is dropped first, so the file can be re-run.
   BEFORE RUNNING: set the CSV folder path in SECTION 0 and enable
   local_infile (SET GLOBAL local_infile = 1; and OPT_LOCAL_INFILE=1
   in Workbench -> connection -> Advanced).
   ===================================================================== */

DROP DATABASE IF EXISTS stock_analysis;
CREATE DATABASE stock_analysis;
USE stock_analysis;

/* ---------------------------------------------------------------------
   SECTION 0: LOAD THE DATA (Appendix A)
   Converts 31-July-2018 to a real DATE and empty cells to NULL.
   --------------------------------------------------------------------- */
CREATE TABLE bajaj_auto (
  `date` DATE PRIMARY KEY,
  open_price DECIMAL(12,2), high_price DECIMAL(12,2), low_price DECIMAL(12,2),
  close_price DECIMAL(12,2), wap DECIMAL(16,4),
  no_of_shares BIGINT, no_of_trades BIGINT, total_turnover DECIMAL(20,2),
  deliverable_qty BIGINT, pct_deli_qty DECIMAL(6,2),
  spread_high_low DECIMAL(12,2), spread_close_open DECIMAL(12,2)
);
LOAD DATA LOCAL INFILE '/path/to/Bajaj_Auto.csv' INTO TABLE bajaj_auto
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES
(@d,@o,@h,@l,@c,@w,@s,@tr,@to,@dq,@pd,@shl,@sco)
SET `date` = STR_TO_DATE(@d, '%d-%M-%Y'),
  open_price = NULLIF(@o,''), high_price = NULLIF(@h,''), low_price = NULLIF(@l,''),
  close_price = NULLIF(@c,''), wap = NULLIF(@w,''), no_of_shares = NULLIF(@s,''),
  no_of_trades = NULLIF(@tr,''), total_turnover = NULLIF(@to,''),
  deliverable_qty = NULLIF(@dq,''), pct_deli_qty = NULLIF(@pd,''),
  spread_high_low = NULLIF(@shl,''), spread_close_open = NULLIF(TRIM(@sco),'');
CREATE TABLE eicher_motors (
  `date` DATE PRIMARY KEY,
  open_price DECIMAL(12,2), high_price DECIMAL(12,2), low_price DECIMAL(12,2),
  close_price DECIMAL(12,2), wap DECIMAL(16,4),
  no_of_shares BIGINT, no_of_trades BIGINT, total_turnover DECIMAL(20,2),
  deliverable_qty BIGINT, pct_deli_qty DECIMAL(6,2),
  spread_high_low DECIMAL(12,2), spread_close_open DECIMAL(12,2)
);
LOAD DATA LOCAL INFILE '/path/to/Eicher_Motors.csv' INTO TABLE eicher_motors
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES
(@d,@o,@h,@l,@c,@w,@s,@tr,@to,@dq,@pd,@shl,@sco)
SET `date` = STR_TO_DATE(@d, '%d-%M-%Y'),
  open_price = NULLIF(@o,''), high_price = NULLIF(@h,''), low_price = NULLIF(@l,''),
  close_price = NULLIF(@c,''), wap = NULLIF(@w,''), no_of_shares = NULLIF(@s,''),
  no_of_trades = NULLIF(@tr,''), total_turnover = NULLIF(@to,''),
  deliverable_qty = NULLIF(@dq,''), pct_deli_qty = NULLIF(@pd,''),
  spread_high_low = NULLIF(@shl,''), spread_close_open = NULLIF(TRIM(@sco),'');
CREATE TABLE hero_motocorp (
  `date` DATE PRIMARY KEY,
  open_price DECIMAL(12,2), high_price DECIMAL(12,2), low_price DECIMAL(12,2),
  close_price DECIMAL(12,2), wap DECIMAL(16,4),
  no_of_shares BIGINT, no_of_trades BIGINT, total_turnover DECIMAL(20,2),
  deliverable_qty BIGINT, pct_deli_qty DECIMAL(6,2),
  spread_high_low DECIMAL(12,2), spread_close_open DECIMAL(12,2)
);
LOAD DATA LOCAL INFILE '/path/to/Hero_Motocorp.csv' INTO TABLE hero_motocorp
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES
(@d,@o,@h,@l,@c,@w,@s,@tr,@to,@dq,@pd,@shl,@sco)
SET `date` = STR_TO_DATE(@d, '%d-%M-%Y'),
  open_price = NULLIF(@o,''), high_price = NULLIF(@h,''), low_price = NULLIF(@l,''),
  close_price = NULLIF(@c,''), wap = NULLIF(@w,''), no_of_shares = NULLIF(@s,''),
  no_of_trades = NULLIF(@tr,''), total_turnover = NULLIF(@to,''),
  deliverable_qty = NULLIF(@dq,''), pct_deli_qty = NULLIF(@pd,''),
  spread_high_low = NULLIF(@shl,''), spread_close_open = NULLIF(TRIM(@sco),'');
CREATE TABLE infosys (
  `date` DATE PRIMARY KEY,
  open_price DECIMAL(12,2), high_price DECIMAL(12,2), low_price DECIMAL(12,2),
  close_price DECIMAL(12,2), wap DECIMAL(16,4),
  no_of_shares BIGINT, no_of_trades BIGINT, total_turnover DECIMAL(20,2),
  deliverable_qty BIGINT, pct_deli_qty DECIMAL(6,2),
  spread_high_low DECIMAL(12,2), spread_close_open DECIMAL(12,2)
);
LOAD DATA LOCAL INFILE '/path/to/Infosys.csv' INTO TABLE infosys
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES
(@d,@o,@h,@l,@c,@w,@s,@tr,@to,@dq,@pd,@shl,@sco)
SET `date` = STR_TO_DATE(@d, '%d-%M-%Y'),
  open_price = NULLIF(@o,''), high_price = NULLIF(@h,''), low_price = NULLIF(@l,''),
  close_price = NULLIF(@c,''), wap = NULLIF(@w,''), no_of_shares = NULLIF(@s,''),
  no_of_trades = NULLIF(@tr,''), total_turnover = NULLIF(@to,''),
  deliverable_qty = NULLIF(@dq,''), pct_deli_qty = NULLIF(@pd,''),
  spread_high_low = NULLIF(@shl,''), spread_close_open = NULLIF(TRIM(@sco),'');
CREATE TABLE tcs (
  `date` DATE PRIMARY KEY,
  open_price DECIMAL(12,2), high_price DECIMAL(12,2), low_price DECIMAL(12,2),
  close_price DECIMAL(12,2), wap DECIMAL(16,4),
  no_of_shares BIGINT, no_of_trades BIGINT, total_turnover DECIMAL(20,2),
  deliverable_qty BIGINT, pct_deli_qty DECIMAL(6,2),
  spread_high_low DECIMAL(12,2), spread_close_open DECIMAL(12,2)
);
LOAD DATA LOCAL INFILE '/path/to/TCS.csv' INTO TABLE tcs
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES
(@d,@o,@h,@l,@c,@w,@s,@tr,@to,@dq,@pd,@shl,@sco)
SET `date` = STR_TO_DATE(@d, '%d-%M-%Y'),
  open_price = NULLIF(@o,''), high_price = NULLIF(@h,''), low_price = NULLIF(@l,''),
  close_price = NULLIF(@c,''), wap = NULLIF(@w,''), no_of_shares = NULLIF(@s,''),
  no_of_trades = NULLIF(@tr,''), total_turnover = NULLIF(@to,''),
  deliverable_qty = NULLIF(@dq,''), pct_deli_qty = NULLIF(@pd,''),
  spread_high_low = NULLIF(@shl,''), spread_close_open = NULLIF(TRIM(@sco),'');
CREATE TABLE tvs_motors (
  `date` DATE PRIMARY KEY,
  open_price DECIMAL(12,2), high_price DECIMAL(12,2), low_price DECIMAL(12,2),
  close_price DECIMAL(12,2), wap DECIMAL(16,4),
  no_of_shares BIGINT, no_of_trades BIGINT, total_turnover DECIMAL(20,2),
  deliverable_qty BIGINT, pct_deli_qty DECIMAL(6,2),
  spread_high_low DECIMAL(12,2), spread_close_open DECIMAL(12,2)
);
LOAD DATA LOCAL INFILE '/path/to/TVS_Motors.csv' INTO TABLE tvs_motors
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES
(@d,@o,@h,@l,@c,@w,@s,@tr,@to,@dq,@pd,@shl,@sco)
SET `date` = STR_TO_DATE(@d, '%d-%M-%Y'),
  open_price = NULLIF(@o,''), high_price = NULLIF(@h,''), low_price = NULLIF(@l,''),
  close_price = NULLIF(@c,''), wap = NULLIF(@w,''), no_of_shares = NULLIF(@s,''),
  no_of_trades = NULLIF(@tr,''), total_turnover = NULLIF(@to,''),
  deliverable_qty = NULLIF(@dq,''), pct_deli_qty = NULLIF(@pd,''),
  spread_high_low = NULLIF(@shl,''), spread_close_open = NULLIF(TRIM(@sco),'');

/* Sanity check: 889 rows in every table */
SELECT 'bajaj_auto' AS tbl, COUNT(*) AS n FROM bajaj_auto
UNION ALL SELECT 'eicher_motors', COUNT(*) FROM eicher_motors
UNION ALL SELECT 'hero_motocorp', COUNT(*) FROM hero_motocorp
UNION ALL SELECT 'infosys', COUNT(*) FROM infosys
UNION ALL SELECT 'tcs', COUNT(*) FROM tcs
UNION ALL SELECT 'tvs_motors', COUNT(*) FROM tvs_motors;

/* =====================================================================
   PART 1: GET TO KNOW THE DATA
   ===================================================================== */

/* Task 1: history available in bajaj_auto
   Expect: 889 | 2015-01-01 | 2018-07-31 */
SELECT COUNT(*)  AS trading_days,
       MIN(`date`) AS first_day,
       MAX(`date`) AS last_day
FROM bajaj_auto;

/* Task 2: Eicher's five best closes (all in September 2017, top > 32,000) */
SELECT `date`, close_price
FROM eicher_motors
ORDER BY close_price DESC
LIMIT 5;

/* Task 3: TCS average close by year (2016 must be 2419.00; 2018 = 7 months only) */
SELECT YEAR(`date`) AS year,
       ROUND(AVG(close_price), 2) AS avg_close
FROM tcs
GROUP BY YEAR(`date`)
ORDER BY year;

/* Task 4: rows with missing deliverable_qty across all six tables (6 rows, 2 dates) */
SELECT 'bajaj_auto' AS stock, `date` FROM bajaj_auto WHERE deliverable_qty IS NULL
UNION ALL
SELECT 'eicher_motors', `date` FROM eicher_motors WHERE deliverable_qty IS NULL
UNION ALL
SELECT 'hero_motocorp', `date` FROM hero_motocorp WHERE deliverable_qty IS NULL
UNION ALL
SELECT 'infosys', `date` FROM infosys WHERE deliverable_qty IS NULL
UNION ALL
SELECT 'tcs', `date` FROM tcs WHERE deliverable_qty IS NULL
UNION ALL
SELECT 'tvs_motors', `date` FROM tvs_motors WHERE deliverable_qty IS NULL;

/* =====================================================================
   PART 2: THE ASSIGNMENT
   ===================================================================== */

/* Task 5: bajaj1 = 20-day and 50-day moving averages.
   A 20-row window is 19 PRECEDING + CURRENT ROW. The CASE blanks out the
   first 19 / 49 rows, where a full window does not exist yet.
   Checks: first ma20 = 2015-01-29 (2415.53); first ma50 = 2015-03-13 (2283.80);
           2018-07-31 ma20 = 2918.51 */
DROP TABLE IF EXISTS bajaj1;
CREATE TABLE bajaj1 AS
SELECT
  `date`,
  close_price,
  CASE WHEN ROW_NUMBER() OVER (ORDER BY `date`) >= 20
       THEN ROUND(AVG(close_price) OVER (ORDER BY `date` ROWS BETWEEN 19 PRECEDING AND CURRENT ROW), 2)
  END AS ma20,
  CASE WHEN ROW_NUMBER() OVER (ORDER BY `date`) >= 50
       THEN ROUND(AVG(close_price) OVER (ORDER BY `date` ROWS BETWEEN 49 PRECEDING AND CURRENT ROW), 2)
  END AS ma50
FROM bajaj_auto;

SELECT * FROM bajaj1 ORDER BY `date`;

/* Task 6: master_table, one row per date, closing price of each stock.
   Checks: 889 rows, no NULLs; 2018-07-31 bajaj 2700.70, tvs 517.45 */
DROP TABLE IF EXISTS master_table;
CREATE TABLE master_table AS
SELECT b.`date`,
       b.close_price AS bajaj,
       t.close_price AS tcs,
       v.close_price AS tvs,
       i.close_price AS infosys,
       e.close_price AS eicher,
       h.close_price AS hero
FROM bajaj_auto b
JOIN tcs t            ON t.`date` = b.`date`
JOIN tvs_motors v     ON v.`date` = b.`date`
JOIN infosys i        ON i.`date` = b.`date`
JOIN eicher_motors e  ON e.`date` = b.`date`
JOIN hero_motocorp h  ON h.`date` = b.`date`;

SELECT * FROM master_table ORDER BY `date`;

/* Task 7: bajaj2 = Buy / Sell / Hold golden-cross signals.
   A cross happens on the one day the relationship CHANGES, so we compare
   today with yesterday (LAG). NULL guard first. `signal` is a reserved word
   in MySQL, so it needs backticks.
   Checks: first Buy 2015-05-18, first Sell 2015-08-24 */
DROP TABLE IF EXISTS bajaj2;
CREATE TABLE bajaj2 AS
WITH t AS (
  SELECT `date`, close_price, ma20, ma50,
         LAG(ma20) OVER (ORDER BY `date`) AS prev_ma20,
         LAG(ma50) OVER (ORDER BY `date`) AS prev_ma50
  FROM bajaj1
)
SELECT `date`, close_price,
  CASE
    WHEN ma20 IS NULL OR ma50 IS NULL OR prev_ma20 IS NULL OR prev_ma50 IS NULL THEN 'Hold'
    WHEN ma20 > ma50 AND prev_ma20 <= prev_ma50 THEN 'Buy'
    WHEN ma20 < ma50 AND prev_ma20 >= prev_ma50 THEN 'Sell'
    ELSE 'Hold'
  END AS `signal`
FROM t;

SELECT * FROM bajaj2 ORDER BY `date`;

/* Task 8: how often did each signal trigger? Expect Buy 12, Hold 866, Sell 11 (= 889) */
SELECT `signal`, COUNT(*) AS days
FROM bajaj2
GROUP BY `signal`
ORDER BY `signal`;

/* Task 9: signal on a given date, as a function.
   Returns NULL for a date with no row (weekend / holiday). */
DROP FUNCTION IF EXISTS bajaj_signal;
DELIMITER $$
CREATE FUNCTION bajaj_signal(d DATE)
RETURNS VARCHAR(4) DETERMINISTIC READS SQL DATA
BEGIN
  DECLARE s VARCHAR(4);
  SELECT `signal` INTO s FROM bajaj2 WHERE `date` = d;
  RETURN s;
END $$
DELIMITER ;

SELECT bajaj_signal('2018-06-21') AS signal_on_2018_06_21;   -- Buy
SELECT bajaj_signal('2015-05-18') AS check_buy,              -- Buy
       bajaj_signal('2016-01-04') AS check_hold;             -- Hold

/* Task 10: all six stocks in ONE query (no twelve tables).
   PARTITION BY stock in every window so stocks never bleed into each other.
   Unrounded averages. Expect totals: 56 Buys, 57 Sells. */
WITH prices AS (
  SELECT 'Bajaj Auto' AS stock, `date`, close_price FROM bajaj_auto
  UNION ALL SELECT 'Eicher Motors', `date`, close_price FROM eicher_motors
  UNION ALL SELECT 'Hero Motocorp', `date`, close_price FROM hero_motocorp
  UNION ALL SELECT 'Infosys',       `date`, close_price FROM infosys
  UNION ALL SELECT 'TCS',           `date`, close_price FROM tcs
  UNION ALL SELECT 'TVS Motors',    `date`, close_price FROM tvs_motors
),
ma AS (
  SELECT stock, `date`, close_price,
    CASE WHEN ROW_NUMBER() OVER (PARTITION BY stock ORDER BY `date`) >= 20
         THEN AVG(close_price) OVER (PARTITION BY stock ORDER BY `date` ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) END AS ma20,
    CASE WHEN ROW_NUMBER() OVER (PARTITION BY stock ORDER BY `date`) >= 50
         THEN AVG(close_price) OVER (PARTITION BY stock ORDER BY `date` ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) END AS ma50
  FROM prices
),
lagged AS (
  SELECT stock, `date`, ma20, ma50,
    LAG(ma20) OVER (PARTITION BY stock ORDER BY `date`) AS prev_ma20,
    LAG(ma50) OVER (PARTITION BY stock ORDER BY `date`) AS prev_ma50
  FROM ma
),
sig AS (
  SELECT stock, `date`,
    CASE
      WHEN ma20 IS NULL OR ma50 IS NULL OR prev_ma20 IS NULL OR prev_ma50 IS NULL THEN 'Hold'
      WHEN ma20 > ma50 AND prev_ma20 <= prev_ma50 THEN 'Buy'
      WHEN ma20 < ma50 AND prev_ma20 >= prev_ma50 THEN 'Sell'
      ELSE 'Hold'
    END AS `signal`
  FROM lagged
),
latest AS (
  SELECT stock, `date`, `signal`,
         ROW_NUMBER() OVER (PARTITION BY stock ORDER BY `date` DESC) AS rn
  FROM sig
  WHERE `signal` <> 'Hold'
)
SELECT s.stock,
       SUM(s.`signal` = 'Buy')  AS buys,
       SUM(s.`signal` = 'Sell') AS sells,
       l.`date`   AS last_signal_date,
       l.`signal` AS last_signal
FROM sig s
JOIN latest l ON l.stock = s.stock AND l.rn = 1
GROUP BY s.stock, l.`date`, l.`signal`
ORDER BY s.stock;

/* =====================================================================
   PART 3: QUESTION THE RESULT
   ===================================================================== */

/* Task 11: who went up? First vs last close.
   100.0 * forces decimal maths. Expect TVS 86.9, Eicher 82.6, Bajaj 10.0,
   Hero 6.0, TCS -23.8, Infosys -30.9 (unadjusted: see Task 13). */
WITH prices AS (
  SELECT 'Bajaj Auto' AS stock, `date`, close_price FROM bajaj_auto
  UNION ALL SELECT 'Eicher Motors', `date`, close_price FROM eicher_motors
  UNION ALL SELECT 'Hero Motocorp', `date`, close_price FROM hero_motocorp
  UNION ALL SELECT 'Infosys',       `date`, close_price FROM infosys
  UNION ALL SELECT 'TCS',           `date`, close_price FROM tcs
  UNION ALL SELECT 'TVS Motors',    `date`, close_price FROM tvs_motors
),
ends AS (
  SELECT stock, MIN(`date`) AS first_date, MAX(`date`) AS last_date
  FROM prices GROUP BY stock
)
SELECT e.stock,
       f.close_price AS first_close,
       l.close_price AS last_close,
       ROUND(100.0 * (l.close_price - f.close_price) / f.close_price, 1) AS pct_change
FROM ends e
JOIN prices f ON f.stock = e.stock AND f.`date` = e.first_date
JOIN prices l ON l.stock = e.stock AND l.`date` = e.last_date
ORDER BY pct_change DESC;

/* Task 12: the data trap. Each stock's single worst day (day-over-day % change).
   Two rows are about -50%: TCS 2018-05-31 and Infosys 2015-06-15.
   Both are 1:1 bonus issues (price halves, no real loss), not crashes. */
WITH prices AS (
  SELECT 'Bajaj Auto' AS stock, `date`, close_price FROM bajaj_auto
  UNION ALL SELECT 'Eicher Motors', `date`, close_price FROM eicher_motors
  UNION ALL SELECT 'Hero Motocorp', `date`, close_price FROM hero_motocorp
  UNION ALL SELECT 'Infosys',       `date`, close_price FROM infosys
  UNION ALL SELECT 'TCS',           `date`, close_price FROM tcs
  UNION ALL SELECT 'TVS Motors',    `date`, close_price FROM tvs_motors
),
moves AS (
  SELECT stock, `date`, close_price,
         100.0 * (close_price / LAG(close_price) OVER (PARTITION BY stock ORDER BY `date`) - 1) AS pct_move
  FROM prices
),
ranked AS (
  SELECT stock, `date`, close_price,
         ROUND(pct_move, 1) AS pct_move,
         ROW_NUMBER() OVER (PARTITION BY stock ORDER BY pct_move ASC) AS rn
  FROM moves
  WHERE pct_move IS NOT NULL            -- drops each stock's first day
)
SELECT stock, `date`, close_price, pct_move
FROM ranked
WHERE rn = 1
ORDER BY pct_move;

/* Task 13: fix it. Divide every price BEFORE the event date by 2.
   Event date = first day at the new price level.
     TCS     2018-05-31  (3517.75 -> 1744.80)
     Infosys 2015-06-15  (1976.65 ->  991.10)
   Expect TCS +52.4, Infosys +38.2. */
WITH adjusted AS (
  SELECT 'TCS' AS stock, `date`,
         CASE WHEN `date` < '2018-05-31' THEN close_price / 2 ELSE close_price END AS adj_close
  FROM tcs
  UNION ALL
  SELECT 'Infosys', `date`,
         CASE WHEN `date` < '2015-06-15' THEN close_price / 2 ELSE close_price END
  FROM infosys
)
SELECT stock,
       ROUND(100.0 * (MAX(CASE WHEN `date` = '2018-07-31' THEN adj_close END) /
                      MAX(CASE WHEN `date` = '2015-01-01' THEN adj_close END) - 1), 1) AS adjusted_pct_change
FROM adjusted
GROUP BY stock
ORDER BY stock;

/* ---------------------------------------------------------------------
   STRETCH: signals rebuilt on ADJUSTED prices for TCS and Infosys.
   Shows which original signals were artefacts of the price cliff.
   --------------------------------------------------------------------- */
WITH adjusted AS (
  SELECT 'TCS' AS stock, `date`,
         CASE WHEN `date` < '2018-05-31' THEN close_price / 2 ELSE close_price END AS adj_close
  FROM tcs
  UNION ALL
  SELECT 'Infosys', `date`,
         CASE WHEN `date` < '2015-06-15' THEN close_price / 2 ELSE close_price END
  FROM infosys
),
ma AS (
  SELECT stock, `date`,
    CASE WHEN ROW_NUMBER() OVER (PARTITION BY stock ORDER BY `date`) >= 20
         THEN AVG(adj_close) OVER (PARTITION BY stock ORDER BY `date` ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) END AS ma20,
    CASE WHEN ROW_NUMBER() OVER (PARTITION BY stock ORDER BY `date`) >= 50
         THEN AVG(adj_close) OVER (PARTITION BY stock ORDER BY `date` ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) END AS ma50
  FROM adjusted
),
lagged AS (
  SELECT stock, `date`, ma20, ma50,
    LAG(ma20) OVER (PARTITION BY stock ORDER BY `date`) AS prev_ma20,
    LAG(ma50) OVER (PARTITION BY stock ORDER BY `date`) AS prev_ma50
  FROM ma
),
sig AS (
  SELECT stock, `date`,
    CASE
      WHEN ma20 IS NULL OR ma50 IS NULL OR prev_ma20 IS NULL OR prev_ma50 IS NULL THEN 'Hold'
      WHEN ma20 > ma50 AND prev_ma20 <= prev_ma50 THEN 'Buy'
      WHEN ma20 < ma50 AND prev_ma20 >= prev_ma50 THEN 'Sell'
      ELSE 'Hold'
    END AS `signal`
  FROM lagged
),
latest AS (
  SELECT stock, `date`, `signal`,
         ROW_NUMBER() OVER (PARTITION BY stock ORDER BY `date` DESC) AS rn
  FROM sig WHERE `signal` <> 'Hold'
)
SELECT s.stock,
       SUM(s.`signal` = 'Buy')  AS adj_buys,
       SUM(s.`signal` = 'Sell') AS adj_sells,
       l.`date`   AS last_signal_date,
       l.`signal` AS last_signal
FROM sig s
JOIN latest l ON l.stock = s.stock AND l.rn = 1
GROUP BY s.stock, l.`date`, l.`signal`
ORDER BY s.stock;
