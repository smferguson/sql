CREATE PROCEDURE add_partitions()
BEGIN
  DECLARE v_new_partition_name VARCHAR(1000);
  DECLARE v_new_partition_date VARCHAR(1000);

  DECLARE v_no_rows INT;

  DECLARE v_days INT;
  DECLARE v_date DATE;

  DECLARE v_lookahead CURSOR FOR
    SELECT 30 UNION SELECT 60 UNION SELECT 90;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_no_rows = 1;

  OPEN v_lookahead;

  REPEAT
    FETCH v_lookahead INTO v_days;

    SET v_date := DATE_ADD(CURRENT_DATE(), INTERVAL v_days DAY);

    SET v_new_partition_name := CONCAT('p', DATE_FORMAT(v_date, '%Y%m'), '01');
    SET v_new_partition_date := CONCAT(DATE_FORMAT(v_date, '%Y-%m'), '-01');

    -- variables used for prepared statements must be session-local, not
    -- procedure-local, and so must use the '@' syntax
    SET @v_new_part := CONCAT('ALTER TABLE TABLE_NAME ADD PARTITION (PARTITION ', v_new_partition_name, ' VALUES LESS THAN (TO_DAYS(''', v_new_partition_date, ''')));');

    PREPARE v_new_partition FROM @v_new_part;
    PREPARE v_drop_partition FROM 'ALTER TABLE TABLE_NAME DROP PARTITION p21130101';
    PREPARE v_create_partition FROM 'ALTER TABLE TABLE_NAME ADD PARTITION (PARTITION p21130101 VALUES LESS THAN (TO_DAYS(''2113-01-01'')))';

    IF NOT EXISTS(
      SELECT *
      FROM information_schema.partitions
      WHERE table_schema = (SELECT database())
      AND table_name = 'TABLE_NAME'
      AND partition_name = v_new_partition_name
      )
    THEN
      SELECT CONCAT('Adding partition ', v_new_partition_name) AS '';

      -- TODO: check for data
      EXECUTE v_drop_partition;
      EXECUTE v_new_partition;
      EXECUTE v_create_partition;

      DEALLOCATE PREPARE v_drop_partition;
      DEALLOCATE PREPARE v_new_partition;
      DEALLOCATE PREPARE v_create_partition;
    END IF;
  UNTIL v_no_rows END REPEAT;

  CLOSE v_lookahead;
END;
