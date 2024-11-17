DROP TABLE IF EXISTS attachment_users_import_doc;
DROP TABLE IF EXISTS attachment_users_property;
DROP TABLE IF EXISTS attachment_users_info;
DROP TABLE IF EXISTS attachment_users;

-- Создание таблицы attachment_users
CREATE TABLE attachment_users (
	attachment_id int8 NULL,
	start_time_stamp timestamptz NOT NULL,
	end_time_stamp timestamptz NULL,
	external_system_id int8 NOT NULL,
	result_content text NULL,
	status varchar(25) NOT NULL,
	error_message text NULL,
	CONSTRAINT att_users_pk PRIMARY KEY (attachment_id)
);

-- DROP TABLE attachment_users;

-- Генерация  записей в таблицу attachment_users
INSERT
	INTO
	attachment_users
SELECT
	i,
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
	attachment_id int8 NOT NULL,
	name varchar(40) NOT NULL,
	last_name varchar(40) NOT NULL,
	birthday timestamptz NOT NULL,
	telephone int8 NOT NULL,
	CONSTRAINT attachment_users_info_pk PRIMARY KEY (id),
	CONSTRAINT attachment_users_info_fk FOREIGN KEY (attachment_id) REFERENCES attachment_users(attachment_id) ON DELETE CASCADE
);

-- DROP TABLE attachment_users_info;

-- Генерация  записей в таблицу attachment_users_info
INSERT
	INTO
	attachment_users_info
SELECT
	i,
	(random() * 1000000)::int,
	'name' || i,
	'last_name' || i,
	timestamptz '1975-03-15 09:00:00.000' + i * INTERVAL '1 day',
	7000000 - i
FROM
	pg_catalog.generate_series(1, 100000) AS i;
	

-- Создание таблицы attachment_users_property
CREATE TABLE attachment_users_property (
	id int8 NOT NULL,
	attachment_id int8 NOT NULL,
	property_value varchar(40) NOT NULL,
	property_role varchar(40) NOT NULL,
	CONSTRAINT attachment_users_property_pk PRIMARY KEY (id),
	CONSTRAINT attachment_users_property_fk FOREIGN KEY (attachment_id) REFERENCES attachment_users(attachment_id) ON DELETE CASCADE
);

-- DROP TABLE attachment_users_property;


-- Генерация  записей в таблицу attachment_users_property
INSERT
	INTO
	attachment_users_property
SELECT
	i,
	(random() * 1000000)::int,
	'value:' || (i % 20),
	'role:' || (i % 100)
FROM
	pg_catalog.generate_series(1, 10000) AS i;
	



-- Создание таблицы attachment_users_import_doc
CREATE TABLE attachment_users_import_doc (
	id int8 NOT NULL,
	attachment_id int8 NOT NULL,
	import_doc int8 NOT NULL,
	doc varchar(40) NOT NULL,
	CONSTRAINT attachment_users_import_doc_pk PRIMARY KEY (id),
	CONSTRAINT attachment_users_import_doc_fk FOREIGN KEY (attachment_id) REFERENCES attachment_users(attachment_id) ON DELETE CASCADE
);

-- DROP TABLE attachment_users_import_doc;


-- Генерация  записей в таблицу attachment_users_import_doc
INSERT
	INTO
	attachment_users_import_doc
SELECT
	i,
	(random() * 1000000)::int,
	random() * 4 + 3,
	'doc' || (i % 4)
FROM
	pg_catalog.generate_series(1, 20000) AS i;







-- Оптимизировать запросы

-- Запрос №1
BEGIN;
EXPLAIN (ANALYZE, buffers)
DELETE FROM attachment_users WHERE attachment_id = $1;
ROLLBACK;


-- Запрос №2
EXPLAIN (ANALYZE, buffers)
SELECT
	substring(status, POSITION('.' IN status) + 1)
FROM
	attachment_users
WHERE
	substring(status, POSITION('.' IN status) + 1) NOT IN ('attachStatus.ERROR', 'attachStatus.DELETED');



-- Запрос №3
EXPLAIN (ANALYZE, buffers)
SELECT
	*
FROM
	attachment_users au
JOIN attachment_users_property aup ON
	au.attachment_id = aup.attachment_id
WHERE
	aup.property_role IN ($1, $2);

$1 = 'role:21'
$2 = 'role:32'


