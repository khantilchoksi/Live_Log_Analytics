/**
 * Welcome to the SQL editor
 * =========================
 * 
 * The SQL code you write here will continuously transform your streaming data
 * when your application is running.
 *
 * Get started by clicking "Add SQL from templates" or pull up the
 * documentation and start writing your own custom queries.
 */

--  create or replace stream "TEMP_STREAM" (
--  "DATA" varchar(5000)
--  );
 
--  create or replace stream "DESTINATION_SQL_STREAM" (
--  "DATA" varchar(5000)
--  );
 
--  create or replace stream "STREAM_PUMP_1" as insert into "TEMP_STREAM"
--  select stream "DATA" from (select stream * from "SOURCE_SQL_STREAM_001");
 
--  create or replace pump "OUTPUT_PUMP" as insert into "DESTINATION_SQL_STREAM"
--  select stream "DATA" from "TEMP_STREAM";

      
-- STREAM (in-application): a continuously updated entity that you can SELECT from and INSERT into like a TABLE
-- PUMP: an entity used to continuously 'SELECT ... FROM' a source STREAM, and INSERT SQL results into an output STREAM
-- Create output stream, which can be used to send to a destination
CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" (data VARCHAR(5000));
-- Create pump to insert into output 
CREATE OR REPLACE PUMP "STREAM_PUMP" AS INSERT INTO "DESTINATION_SQL_STREAM"
-- Select all columns from source stream
SELECT STREAM data
FROM "SOURCE_SQL_STREAM_001";