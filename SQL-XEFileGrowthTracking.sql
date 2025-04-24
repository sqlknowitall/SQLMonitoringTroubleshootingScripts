/*********************************************************************************************
PURPOSE:    Demo script for tracking File Growth
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name				Change Description                                    
----------			--------------				------------------
07/18/2018			Jared Karney				Original Version
----------------------------------------------------------------------------------------------


This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
**********************************************************************************************/


IF EXISTS
(
    SELECT *
    FROM sys.server_event_sessions
    WHERE name = 'Data_Log_FileGrowth'
)
    DROP EVENT SESSION Data_Log_FileGrowth ON SERVER;
CREATE EVENT SESSION Data_Log_FileGrowth
ON SERVER
    ADD EVENT sqlserver.databases_data_file_size_changed
    (ACTION
     (
         sqlserver.sql_text,            --	1
         sqlserver.database_id,         --	2
         sqlserver.client_app_name,     --	3
         sqlserver.client_hostname,     --	4
         sqlserver.session_nt_username, --	5
         sqlserver.username,            --	6
         sqlserver.is_system,           --	7
         sqlserver.session_id
     ) --8
    ),
    ADD EVENT sqlserver.databases_log_file_size_changed
    (ACTION
     (
         sqlserver.sql_text,            --	1
         sqlserver.database_id,         --	2
         sqlserver.client_app_name,     --	3
         sqlserver.client_hostname,     --	4
         sqlserver.session_nt_username, --	5
         sqlserver.username,            --	6
         sqlserver.is_system,           --	7
         sqlserver.session_id
     ) --8
    )
    ADD TARGET package0.asynchronous_file_target
    (SET filename = 'Data_Log_FileGrowth', max_file_size = 5, max_rollover_files = 5)
WITH
(
    MAX_DISPATCH_LATENCY = 1 SECONDS,
    STARTUP_STATE = ON
);

ALTER EVENT SESSION Data_Log_FileGrowth ON SERVER STATE = START;


----Query the Event data from the Target.
---- Create intermediate temp table for raw event data
--CREATE TABLE #RawEventData
--(
--    Rowid INT IDENTITY PRIMARY KEY,
--    event_data XML
--);

--DECLARE @filename sysname;

--SELECT @filename = REPLACE(CAST(esf.value AS VARCHAR(255)), '.xel', '*xel')
--FROM sys.server_event_sessions es
--    INNER JOIN sys.server_event_session_fields esf
--        ON es.event_session_id = esf.event_session_id
--WHERE es.name = 'Data_Log_FileGrowth'
--      AND esf.name = 'filename';

---- Read the file data into intermediate temp table
--INSERT INTO #RawEventData
--(
--    event_data
--)
--SELECT CAST(event_data AS XML) AS event_data
--FROM sys.fn_xe_file_target_read_file(@filename, NULL, NULL, NULL);

--SELECT event_data.value('(/event/@timestamp)[1]', 'DATETIME') event_time,
--       event_data.value('(/event/data/value)[2]', 'INT') database_id,
--       DB_NAME(event_data.value('(/event/action/value)[2]', 'INT')) database_name,
--       event_data.value('(/event/data/value)[1]', 'BIGINT') size_KB,
--       event_data.value('(/event/action/value)[1]', 'VARCHAR(MAX)') sql_text,
--       event_data.value('(/event/action/value)[3]', 'VARCHAR(128)') client_app_name,
--       event_data.value('(/event/action/value)[4]', 'VARCHAR(128)') client_hostname,
--       event_data.value('(/event/action/value)[5]', 'VARCHAR(128)') session_nt_username,
--       event_data.value('(/event/action/value)[6]', 'VARCHAR(128)') username,
--       event_data.value('(/event/action/value)[7]', 'VARCHAR(10)') is_system,
--       event_data.value('(/event/action/value)[8]', 'INT') session_id
--FROM #RawEventData;

--DROP TABLE #RawEventData;

