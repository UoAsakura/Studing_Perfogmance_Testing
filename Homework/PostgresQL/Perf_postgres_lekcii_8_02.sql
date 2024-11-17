DROP TABLE IF EXISTS attachment_users_import_doc;
DROP TABLE IF EXISTS attachment_users_property;
DROP TABLE IF EXISTS attachment_users_info;
DROP TABLE IF EXISTS attachment_users;

-- Создание таблицы
CREATE TABLE attachment_users (
	id int8 NOT NULL,
	attachment_id varchar(40) NULL,
	start_time_stamp timestamptz NOT NULL,
	end_time_stamp timestamptz NULL,
	external_system_id int8 NOT NULL,
	result_content text NULL,
	status varchar(25) NOT NULL,
	error_message text NULL,
	CONSTRAINT att_users_pk PRIMARY KEY (id)
);

-- DROP TABLE attachment_users;

-- Генерация  записей в таблицу attachment_users
INSERT
	INTO
	attachment_users
SELECT
	i,
	md5(random()::TEXT),
	timestamptz '2022-03-15 09:00:00.000' + i * INTERVAL '1 minutes',
	timestamptz '2022-07-15 09:00:00.000' + i * INTERVAL '1 second',
	i % 4,
	NULL,
	(ARRAY ['attachStatus.OK', 'attachStatus.ERROR', 'attachStatus.WAIT', 'attachStatus.IN_PROCCESS', 'attachStatus.DELETED'])[floor(random() * 5 + 1)],
	NULL
FROM
	pg_catalog.generate_series(1, 1000000) AS i;
	


-- Создание таблицы attachment_users_info
CREATE TABLE attachment_users_info (
	id int8 NOT NULL,
	user_id int8 NOT NULL,
	attachment_id int8 NOT NULL,
	name varchar(40) NOT NULL,
	last_name varchar(40) NOT NULL,
	birthday timestamptz NOT NULL,
	telephone int8 NOT NULL,
	CONSTRAINT attachment_users_info_pk PRIMARY KEY (id),
	CONSTRAINT attachment_users_info_fk FOREIGN KEY (attachment_id) REFERENCES attachment_users(id) ON DELETE CASCADE
);

-- DROP TABLE attachment_users_info;


-- Генерация  записей в таблицу attachment_users_info
INSERT
	INTO
	attachment_users_info
SELECT
	i,
	i,
	(random() * 1000000)::int,
	'name' || i,
	'last_name' || i,
	timestamptz '1975-03-15 09:00:00.000' + i * INTERVAL '1 day',
	7000000 - i
FROM
	pg_catalog.generate_series(1, 100000) AS i;

SHOW random_page_cost;
SET random_page_cost = 1.1;

SHOW enable_seqscan;
SET enable_seqscan = off;
SET enable_seqscan = on;













-- Необходимо оптимизировать запросы



EXPLAIN (ANALYZE, buffers)
SELECT id FROM attachment_users WHERE status NOT IN ('attachStatus.OK', 'attachStatus.DELETED');

Seq Scan on attachment_users  (cost=0.00..27797.00 rows=596433 width=8) (actual time=0.011..183.070 rows=600589 loops=1)
  Filter: ((status)::text <> ALL ('{attachStatus.OK,attachStatus.DELETED}'::text[]))
  Rows Removed by Filter: 399411
  Buffers: shared hit=15297
Planning Time: 0.075 ms
Execution Time: 199.971 ms

Index Scan using fix2_attachment_users_status_idx on attachment_users  (cost=0.42..26069.88 rows=596433 width=8) (actual time=0.029..127.902 rows=600589 loops=1)
  Buffers: shared hit=46412
Planning Time: 0.100 ms
Execution Time: 143.736 ms

SELECT DISTINCT status FROM attachment_users;

status                  |
------------------------+
attachStatus.DELETED    |
attachStatus.ERROR      |
attachStatus.IN_PROCCESS|
attachStatus.OK         |
attachStatus.WAIT       |


CREATE INDEX fix1_attachment_users_status_idx ON test_postg.attachment_users USING btree (status);
DROP INDEX fix1_attachment_users_status_idx;




EXPLAIN (ANALYZE, buffers)
SELECT id FROM attachment_users WHERE status IN ('attachStatus.WAIT', 'attachStatus.IN_PROCCESS', 'attachStatus.ERROR');

Index Scan using fix1_attachment_users_status_idx on attachment_users  (cost=0.42..27428.71 rows=596433 width=8) (actual time=0.033..129.579 rows=600589 loops=1)
  Index Cond: ((status)::text = ANY ('{attachStatus.WAIT,attachStatus.IN_PROCCESS,attachStatus.ERROR}'::text[]))
  Buffers: shared hit=46418
Planning Time: 0.079 ms
Execution Time: 145.637 ms

CREATE INDEX fix2_attachment_users_status_idx ON test_postg.attachment_users USING btree (status) WHERE ((status)::text <> ALL ((ARRAY['attachStatus.OK'::character varying, 'attachStatus.DELETED'::character varying])::text[]))
CREATE INDEX fix2_attachment_users_status_idx ON test_postg.attachment_users USING btree (status) WHERE status NOT IN ('attachStatus.OK', 'attachStatus.DELETED');
DROP INDEX fix2_attachment_users_status_idx;

CREATE INDEX fix3_attachment_users_status_idx ON test_postg.attachment_users USING btree (status) WHERE ((status)::text <> ALL ('{attachStatus.OK,attachStatus.DELETED}'::text[]));
DROP INDEX fix3_attachment_users_status_idx;

CREATE UNIQUE INDEX fix5_attachment_users_id_idx ON test_postg.attachment_users USING btree (id) WHERE ((status)::text <> ALL ('{attachStatus.OK,attachStatus.DELETED}'::text[]));
DROP INDEX fix5_attachment_users_id_idx;

CREATE UNIQUE INDEX fix4_attachment_users_id_idx ON test_postg.attachment_users USING btree (id) WHERE ((status)::text = ANY ('{attachStatus.WAIT,attachStatus.IN_PROCCESS,attachStatus.ERROR}'::text[]));
DROP INDEX fix4_attachment_users_id_idx;

-- запрос с NOT IN
Index Only Scan using fix5_attachment_users_id_idx on attachment_users  (cost=0.42..10748.72 rows=596433 width=8) (actual time=0.015..45.079 rows=600589 loops=1)
  Heap Fetches: 0
  Buffers: shared hit=1644
Planning Time: 0.120 ms
Execution Time: 62.466 ms

-- запрос с IN
Index Scan using fix5_attachment_users_id_idx on attachment_users  (cost=0.42..22109.44 rows=596433 width=8) (actual time=0.015..173.284 rows=600589 loops=1)
  Filter: ((status)::text = ANY ('{attachStatus.WAIT,attachStatus.IN_PROCCESS,attachStatus.ERROR}'::text[]))
  Buffers: shared hit=16940
Planning Time: 0.159 ms
Execution Time: 189.699 ms

Index Only Scan using fix4_attachment_users_id_idx on attachment_users  (cost=0.42..10748.72 rows=596433 width=8) (actual time=0.014..41.488 rows=600589 loops=1)
  Heap Fetches: 0
  Buffers: shared hit=1644
Planning Time: 0.188 ms
Execution Time: 57.468 ms



----------------------------------------------------------------------------------------------------------------------------
EXPLAIN (ANALYZE, buffers)
SELECT id FROM attachment_users WHERE status != 'attachStatus.OK' AND status != 'attachStatus.DELETED';

Index Only Scan using fix5_attachment_users_id_idx on attachment_users  (cost=0.42..10748.72 rows=637150 width=8) (actual time=0.025..46.027 rows=600589 loops=1)
  Heap Fetches: 0
  Buffers: shared hit=1644
Planning Time: 0.216 ms
Execution Time: 63.621 ms



EXPLAIN (ANALYZE, buffers)
SELECT id FROM attachment_users WHERE status != 'attachStatus.ERROR' AND status != 'attachStatus.DELETED';

Seq Scan on attachment_users  (cost=0.00..30297.00 rows=641620 width=8) (actual time=0.009..155.736 rows=600069 loops=1)
  Filter: (((status)::text <> 'attachStatus.ERROR'::text) AND ((status)::text <> 'attachStatus.DELETED'::text))
  Rows Removed by Filter: 399931
  Buffers: shared hit=15297
Planning Time: 0.097 ms
Execution Time: 172.360 ms

CREATE UNIQUE INDEX fix6_attachment_users_id_idx ON test_postg.attachment_users USING btree (id) WHERE (((status)::text <> 'attachStatus.ERROR'::text) AND ((status)::text <> 'attachStatus.DELETED'::text));
DROP INDEX fix6_attachment_users_id_idx;

Index Only Scan using fix6_attachment_users_id_idx on attachment_users  (cost=0.42..11229.77 rows=641620 width=8) (actual time=0.023..49.178 rows=600069 loops=1)
  Heap Fetches: 0
  Buffers: shared hit=1643
Planning Time: 0.185 ms
Execution Time: 67.974 ms

EXPLAIN (ANALYZE, buffers)
SELECT id FROM attachment_users WHERE status != 'attachStatus.ERROR' AND status != 'attachStatus.DELETED'
LIMIT 100;

Limit  (cost=0.42..2.18 rows=100 width=8) (actual time=0.015..0.026 rows=100 loops=1)
  Buffers: shared hit=4
  ->  Index Only Scan using fix6_attachment_users_id_idx on attachment_users  (cost=0.42..11229.77 rows=641620 width=8) (actual time=0.015..0.020 rows=100 loops=1)
        Heap Fetches: 0
        Buffers: shared hit=4
Planning Time: 0.123 ms
Execution Time: 0.038 ms


------------------------------------------------------------------------------------------------------------------------------------------------


EXPLAIN (ANALYZE, buffers)
SELECT
	*
FROM
	attachment_users au
JOIN attachment_users_info aui ON
	au.id = aui.attachment_id
	AND au.start_time_stamp < $1;

EXPLAIN (ANALYZE, buffers)
SELECT
	*
FROM
	attachment_users au
JOIN attachment_users_info aui ON
	au.id = aui.attachment_id
WHERE au.start_time_stamp >= $1
AND au.start_time_stamp < ($1::timestamptz + INTERVAL '1 day');


SELECT '2022-03-22'::timestamptz + INTERVAL '1 day';

$1 = '2022-04-15'
$1 = '2022-03-22'

Gather  (cost=21735.90..24146.24 rows=4427 width=211) (actual time=71.191..92.014 rows=4421 loops=1)
  Workers Planned: 1
  Workers Launched: 1
  Buffers: shared hit=16622
  ->  Parallel Hash Join  (cost=20735.90..22703.54 rows=2604 width=211) (actual time=56.884..69.646 rows=2211 loops=2)
        Hash Cond: (aui.attachment_id = au.id)
        Buffers: shared hit=16622
        ->  Parallel Seq Scan on attachment_users_info aui  (cost=0.00..1813.24 rows=58824 width=63) (actual time=0.002..2.882 rows=50000 loops=2)
              Buffers: shared hit=1225
        ->  Parallel Hash  (cost=20505.33..20505.33 rows=18445 width=148) (actual time=56.600..56.601 rows=22050 loops=2)
              Buckets: 65536  Batches: 1  Memory Usage: 6048kB
              Buffers: shared hit=15297
              ->  Parallel Seq Scan on attachment_users au  (cost=0.00..20505.33 rows=18445 width=148) (actual time=21.257..53.353 rows=22050 loops=2)
                    Filter: (start_time_stamp < '2022-04-15 00:00:00+03'::timestamp with time zone)
                    Rows Removed by Filter: 477951
                    Buffers: shared hit=15297
Planning:
  Buffers: shared hit=8
Planning Time: 0.204 ms
Execution Time: 92.176 ms



CREATE INDEX fix1_attachment_users_info_attachment_id_idx ON test_postg.attachment_users_info USING btree (attachment_id);
DROP INDEX fix1_attachment_users_info_attachment_id_idx;

CREATE INDEX fix7_attachment_users_start_time_stamp_idx ON test_postg.attachment_users USING btree (start_time_stamp);
DROP INDEX fix7_attachment_users_start_time_stamp_idx;

CREATE INDEX fix2_attachment_users_info_attachment_id_idx ON test_postg.attachment_users_info USING hash (attachment_id);
DROP INDEX fix2_attachment_users_info_attachment_id_idx;

CREATE INDEX fix8_attachment_users_start_time_stamp_idx ON test_postg.attachment_users USING hash (start_time_stamp);
DROP INDEX fix8_attachment_users_start_time_stamp_idx;

Hash Join  (cost=2140.77..4628.27 rows=4427 width=211) (actual time=12.166..34.824 rows=4421 loops=1)
  Hash Cond: (aui.attachment_id = au.id)
  Buffers: shared hit=2023
  ->  Seq Scan on attachment_users_info aui  (cost=0.00..2225.00 rows=100000 width=63) (actual time=0.007..6.337 rows=100000 loops=1)
        Buffers: shared hit=1225
  ->  Hash  (cost=1587.42..1587.42 rows=44268 width=148) (actual time=11.986..11.987 rows=44099 loops=1)
        Buckets: 65536  Batches: 1  Memory Usage: 5844kB
        Buffers: shared hit=798
        ->  Index Scan using fix7_attachment_users_start_time_stamp_idx on attachment_users au  (cost=0.42..1587.42 rows=44268 width=148) (actual time=0.010..5.794 rows=44099 loops=1)
              Index Cond: (start_time_stamp < '2022-04-15 00:00:00+03'::timestamp with time zone)
              Buffers: shared hit=798
Planning:
  Buffers: shared hit=14
Planning Time: 0.225 ms
Execution Time: 35.748 ms


Nested Loop  (cost=0.42..4717.69 rows=4427 width=211) (actual time=0.040..38.072 rows=4421 loops=1)
  Buffers: shared hit=49320
  ->  Index Scan using fix7_attachment_users_start_time_stamp_idx on attachment_users au  (cost=0.42..1587.42 rows=44268 width=148) (actual time=0.011..7.015 rows=44099 loops=1)
        Index Cond: (start_time_stamp < '2022-04-15 00:00:00+03'::timestamp with time zone)
        Buffers: shared hit=798
  ->  Index Scan using fix2_attachment_users_info_attachment_id_idx on attachment_users_info aui  (cost=0.00..0.06 rows=1 width=63) (actual time=0.000..0.000 rows=0 loops=44099)
        Index Cond: (attachment_id = au.id)
        Rows Removed by Index Recheck: 0
        Buffers: shared hit=48522
Planning:
  Buffers: shared hit=14
Planning Time: 0.231 ms
Execution Time: 38.226 ms


EXPLAIN (ANALYZE, buffers)
SELECT
	*
FROM
	attachment_users au 
WHERE au.start_time_stamp < $1;

SELECT * FROM pg_stats WHERE tablename IN ('attachment_users_info', 'attachment_users') AND schemaname = 'test_postg';



EXPLAIN (ANALYZE, buffers)
SELECT
	*
FROM
	attachment_users au
JOIN attachment_users_info aui ON
	au.id = aui.attachment_id
WHERE  au.start_time_stamp < $1
LIMIT 1000;


EXPLAIN (ANALYZE, buffers)
SELECT
	*
FROM
	attachment_users au
JOIN attachment_users_info aui ON
	au.id = aui.attachment_id
WHERE au.start_time_stamp >= $1
AND au.start_time_stamp < ($1::timestamptz + INTERVAL '1 day');



Nested Loop  (cost=0.43..1703.06 rows=153 width=211) (actual time=0.040..2.436 rows=159 loops=1)
  Buffers: shared hit=1628
  ->  Index Scan using fix7_attachment_users_start_time_stamp_idx on attachment_users au  (cost=0.43..60.57 rows=1527 width=148) (actual time=0.023..0.323 rows=1440 loops=1)
        Index Cond: ((start_time_stamp >= '2022-03-22 00:00:00+03'::timestamp with time zone) AND (start_time_stamp < ('2022-03-22 00:00:00+03'::timestamp with time zone + '1 day'::interval)))
        Buffers: shared hit=29
  ->  Index Scan using fix2_attachment_users_info_attachment_id_idx on attachment_users_info aui  (cost=0.00..1.07 rows=1 width=63) (actual time=0.001..0.001 rows=0 loops=1440)
        Index Cond: (attachment_id = au.id)
        Buffers: shared hit=1599
Planning:
  Buffers: shared hit=18
Planning Time: 0.337 ms
Execution Time: 2.466 ms


Nested Loop  (cost=0.72..1884.61 rows=153 width=211) (actual time=0.023..1.612 rows=159 loops=1)
  Buffers: shared hit=3068
  ->  Index Scan using fix7_attachment_users_start_time_stamp_idx on attachment_users au  (cost=0.43..60.57 rows=1527 width=148) (actual time=0.014..0.224 rows=1440 loops=1)
        Index Cond: ((start_time_stamp >= '2022-03-22 00:00:00+03'::timestamp with time zone) AND (start_time_stamp < ('2022-03-22 00:00:00+03'::timestamp with time zone + '1 day'::interval)))
        Buffers: shared hit=29
  ->  Index Scan using fix1_attachment_users_info_attachment_id_idx on attachment_users_info aui  (cost=0.29..1.18 rows=1 width=63) (actual time=0.001..0.001 rows=0 loops=1440)
        Index Cond: (attachment_id = au.id)
        Buffers: shared hit=3039
Planning:
  Buffers: shared hit=18
Planning Time: 0.261 ms
Execution Time: 1.651 ms
