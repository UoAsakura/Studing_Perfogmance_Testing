SELECT VERSION();

SELECT * FROM pg_settings;

SHOW block_size;

SELECT * FROM pg_stat_statements;

SELECT * FROM pg_settings WHERE name = 'shared_preload_libraries';


-- Сортировка по общему времени

SELECT queryid, query, calls, rows,
	round(total_exec_time::NUMERIC, 2) AS total_time,
	round(mean_exec_time::NUMERIC, 2) AS mean_time,
	round((shared_blks_hit/calls::NUMERIC), 1) AS hit_sql,
	round((shared_blks_read::NUMERIC/calls), 1) AS read_sql
FROM pg_stat_statements
ORDER BY total_time DESC;


-- Сортировка по времени выполнения запроса

SELECT queryid, query, calls, rows,
	round(total_exec_time::NUMERIC, 2) AS total_time,
	round(mean_exec_time::NUMERIC, 2) AS mean_time,
	round((shared_blks_hit/calls::NUMERIC), 1) AS hit_sql,
	round((shared_blks_read::NUMERIC/calls), 1) AS read_sql
FROM pg_stat_statements
ORDER BY mean_time DESC;


-- Сортировка по потребляемым ресурсам

SELECT queryid, query, calls, rows,
	round(total_exec_time::NUMERIC, 2) AS total_time,
	round(mean_exec_time::NUMERIC, 2) AS mean_time,
	round((shared_blks_hit/calls::NUMERIC), 1) AS hit_sql,
	round((shared_blks_read::NUMERIC/calls), 1) AS read_sql
FROM pg_stat_statements
ORDER BY hit_sql DESC;

BEGIN;
SELECT * FROM pg_stat_activity;
SELECT * FROM pg_stat_statements;
COMMIT;


SELECT pid, wait_event, wait_event_type, datname, now()-query_start AS duration, state, query FROM pg_stat_activity
WHERE state <> 'idle' AND query NOT LIKE '%pg_stat_activity%' AND now()-query_start > INTERVAL '5 second'
ORDER BY duration DESC;


SELECT state, count(*)
FROM pg_stat_activity
GROUP BY state;


SELECT datname,  usename, 
now() - xact_start AS TransactionDuration,
now() - query_start as QueryDuration
FROM pg_stat_activity
WHERE state = 'active';


SELECT * FROM employee.employee_data WHERE id = $1;

$1 = 71

SELECT * FROM pg_stats WHERE tablename = 'employee_data';

SELECT * FROM employee.employee_data WHERE client_id = $1;

$1 = 19191



{19191 ,32        ,214       ,7188,10254,13443,2543,4478,4657,5391,6375,7504,7689,8932,9308,11321,13742,16113,17119}
{0.0003,0.00026667,0.00026667,0.00026667,0.00026667,0.00026667,0.00023333,0.00023333,0.00023333,0.00023333,0.00023333,0.00023333,0.00023333,0.00023333,0.00023333,0.00023333,0.00023333,0.00023333,0.00023333}

-- client_id = -0.1847
SELECT count(client_id) FROM employee.employee_data; -- 100000
SELECT count(DISTINCT client_id) FROM employee.employee_data; -- 19875

SELECT 197875 / 100000::numeric;	-- 1.97875

SELECT count(DISTINCT evaluations) FROM employee.employee_data;



EXPLAIN
SELECT * FROM employee.employee_data WHERE client_id = $1;

Seq Scan on employee_data  (cost=0.00..2034.00 rows=30 width=33)
  Filter: (client_id = 19191)


EXPLAIN ANALYZE
SELECT * FROM employee.employee_data WHERE client_id = $1;

Seq Scan on employee_data  (cost=0.00..2034.00 rows=30 width=33) (actual time=0.942..6.041 rows=11 loops=1)
  Filter: (client_id = 19191)
  Rows Removed by Filter: 99989
Planning Time: 0.069 ms
Execution Time: 6.061 ms


EXPLAIN (ANALYSE, buffers)
SELECT * FROM employee.employee_data WHERE client_id = $1;

Seq Scan on employee_data  (cost=0.00..2034.00 rows=30 width=33) (actual time=0.924..5.975 rows=11 loops=1)
  Filter: (client_id = 19191)
  Rows Removed by Filter: 99989
  Buffers: shared hit=784
Planning Time: 0.068 ms
Execution Time: 6.000 ms

SELECT * FROM employee.employee_data WHERE id = 18;

BEGIN;
EXPLAIN (ANALYZE, buffers)
UPDATE employee.employee_data
SET client_id=4978
WHERE id=18;
ROLLBACK;


CREATE INDEX fix1_employee_data_client_id_idx ON employee.employee_data (client_id);
CREATE INDEX fix1_employee_data_client_id_idx ON employee.employee_data USING btree (client_id);
DROP INDEX fix1_employee_data_client_id_idx;

-- Первый раз
Bitmap Heap Scan on employee_data  (cost=4.53..107.31 rows=30 width=33) (actual time=0.041..0.051 rows=11 loops=1)
  Recheck Cond: (client_id = 19191)
  Heap Blocks: exact=11
  Buffers: shared hit=11 read=2
  ->  Bitmap Index Scan on fix1_employee_data_client_id_idx  (cost=0.00..4.52 rows=30 width=0) (actual time=0.036..0.036 rows=11 loops=1)
        Index Cond: (client_id = 19191)
        Buffers: shared read=2
Planning:
  Buffers: shared hit=16 read=1
Planning Time: 0.282 ms
Execution Time: 0.078 ms

-- Второй раз
Bitmap Heap Scan on employee_data  (cost=4.53..107.31 rows=30 width=33) (actual time=0.018..0.030 rows=11 loops=1)
  Recheck Cond: (client_id = 19191)
  Heap Blocks: exact=11
  Buffers: shared hit=13
  ->  Bitmap Index Scan on fix1_employee_data_client_id_idx  (cost=0.00..4.52 rows=30 width=0) (actual time=0.013..0.013 rows=11 loops=1)
        Index Cond: (client_id = 19191)
        Buffers: shared hit=2
Planning Time: 0.070 ms
Execution Time: 0.048 ms







