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
-- CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" (data VARCHAR(5000));
-- -- Create pump to insert into output 
-- CREATE OR REPLACE PUMP "STREAM_PUMP" AS INSERT INTO "DESTINATION_SQL_STREAM"
-- -- Select all columns from source stream
-- SELECT STREAM data
-- FROM "SOURCE_SQL_STREAM_001";

-- HOME & LOGIN STREAM

-- CREATE OR REPLACE STREAM "LOGIN_STREAM" (ip VARCHAR(16), response_code integer, response_time real, endpoint varchar(32), 
--     COL_timestamp varchar(32));
    
-- CREATE OR REPLACE PUMP "LOGIN_PUMP" AS INSERT INTO "LOGIN_STREAM" 
--     SELECT STREAM "ip", "response_code", "response_time", "endpoint", "COL_timestamp"
--         FROM "SOURCE_SQL_STREAM_001"
--         WHERE "endpoint" LIKE 'login';
        
        
-- CREATE OR REPLACE STREAM "HOME_STREAM" (ip VARCHAR(16), response_code integer, response_time real, endpoint varchar(32), 
--     COL_timestamp varchar(32));
    
-- CREATE OR REPLACE PUMP "HOME_PUMP" AS INSERT INTO "HOME_STREAM" 
--     SELECT STREAM "ip", "response_code", "response_time", "endpoint", "COL_timestamp"
--         FROM "SOURCE_SQL_STREAM_001"
--         WHERE "endpoint" LIKE 'home';

CREATE OR REPLACE STREAM "LOGIN_STREAM" (logtime timestamp, ip VARCHAR(16), response_code integer, response_time real, endpoint varchar(32), 
    COL_timestamp varchar(32));
    
CREATE OR REPLACE PUMP "LOGIN_PUMP" AS INSERT INTO "LOGIN_STREAM" 
    SELECT STREAM "ROWTIME", "ip", "response_code", "response_time", "endpoint", "COL_timestamp"
        FROM "SOURCE_SQL_STREAM_001"
        WHERE "endpoint" LIKE 'login';
        
        
CREATE OR REPLACE STREAM "HOME_STREAM" (logtime timestamp, ip VARCHAR(16), response_code integer, response_time real, endpoint varchar(32), 
    COL_timestamp varchar(32));
    
CREATE OR REPLACE PUMP "HOME_PUMP" AS INSERT INTO "HOME_STREAM" 
    SELECT STREAM LOCALTIMESTAMP, "ip", "response_code", "response_time", "endpoint", "COL_timestamp"
        FROM "SOURCE_SQL_STREAM_001"
        WHERE "endpoint" LIKE 'home';

// Presetnation
CREATE OR REPLACE STREAM "HOME_STREAM" (logtime timestamp, ip VARCHAR(16), response_code integer, response_time real, endpoint varchar(32), 
    COL_timestamp varchar(32), APPROXIMATE_ARRIVAL_TIME timestamp);
    
CREATE OR REPLACE PUMP "HOME_PUMP" AS INSERT INTO "HOME_STREAM" 
    SELECT STREAM LOCALTIMESTAMP, "ip", "response_code", "response_time", "endpoint", "COL_timestamp", "APPROXIMATE_ARRIVAL_TIME"
        FROM "SOURCE_SQL_STREAM_001"
        WHERE (EXTRACT (  MINUTE FROM "APPROXIMATE_ARRIVAL_TIME"  ) - EXTRACT ( MINUTE FROM CURRENT_ROW_TIMESTAMP ) <= 15);