CREATE DATABASE IF NOT EXISTS BATCH_EXECUTE_DB;

USE BATCH_EXECUTE_DB;

DROP TABLE IF EXISTS DataTable;

CREATE TABLE DataTable(
  id INT AUTO_INCREMENT,
  int_type     INTEGER UNIQUE,
  long_type    BIGINT,
  float_type   FLOAT,
  PRIMARY KEY (id)
);

INSERT INTO DataTable (int_type, long_type, float_type)
  VALUES(1, 9223372036854774807, 123.34);


INSERT INTO DataTable (int_type, long_type, float_type)
  VALUES(2, 9372036854774807, 124.34);
