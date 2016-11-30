-- random mysql commands related to charsets
-- NOTE: mysql will happily stuff data into columns of the wrong charset
--       as long as the data is within the table's charset
--
-- more here: https://www.blueboxcloud.com/insight/blog-article/getting-out-of-mysql-character-set-hell

-- get default charset for mysql instance
SHOW VARIABLES WHERE VARIABLE_NAME LIKE '%char%';


-- get db-level info about the charsets in use
SELECT * FROM information_schema.schemata WHERE schema_name = 'SCHEMA_NAME';


-- find tables of a charset
SELECT table_name, table_collation
FROM information_schema.tables
WHERE table_schema = (select database())
AND table_collation != 'utf8_general_ci';


-- find fields with multibyte chars
SELECT *
FROM TABLE_NAME
WHERE LENGTH(FIELD_NAME) != CHAR_LENGTH(FIELD_NAME);


-- detect bad chars in your latin1 table
-- if found they need manual intervention before changing the table's charset
SELECT CONVERT(CONVERT(COLUMN_NAME USING BINARY) USING latin1) AS latin1,
       CONVERT(CONVERT(COLUMN_NAME USING BINARY) USING utf8) AS utf8
FROM TABLE_NAME
WHERE CONVERT(COLUMN_NAME USING BINARY) RLIKE CONCAT('[', NHEX('80'), '-', UNHEX('FF'), ']');


-- set db charset
ALTER DATABASE SCHEMA_NAME CHARACTER SET utf8 COLLATE utf8_general_ci;


-- set a table's charset
ALTER TABLE TABLE_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE TABLE_NAME CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
