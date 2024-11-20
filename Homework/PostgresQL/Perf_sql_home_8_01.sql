CREATE SCHEMA IF NOT EXISTS test_postg;

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














-- Необходимо оптимизировать запросы


BEGIN;
EXPLAIN (ANALYZE, buffers)
SELECT * FROM attachment_users WHERE status = $1 AND external_system_id = $2
LIMIT 1000;
ROLLBACK;


EXPLAIN (ANALYZE, buffers)
SELECT * FROM attachment_users WHERE start_time_stamp > $1 AND start_time_stamp < $2;

$1 = '2023-06-21'
$2 = '2023-06-22'