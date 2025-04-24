/*********************************************************************************************
PURPOSE:    If not exists, create an extended event to track CPU for each sp, statement,
	and bactch. Then aggregate and analyze
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name				Change Description                                    
----------			--------------				------------------
12/18/2018			Jared Karney				Original Version
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

IF NOT EXISTS (SELECT name FROM sys.server_event_sessions WHERE name = 'all_sql_statements_cpu')
BEGIN
CREATE EVENT SESSION all_sql_statements_cpu
ON SERVER
    ADD EVENT sqlserver.sp_statement_completed
    (ACTION
     (
         sqlserver.sql_text,
         sqlserver.tsql_frame
     )
    ),
    ADD EVENT sqlserver.sql_batch_completed
    (ACTION
     (
         sqlserver.sql_text,
         sqlserver.tsql_frame
     )
    ),
    ADD EVENT sqlserver.sql_statement_completed
    (ACTION
     (
         sqlserver.sql_text,
         sqlserver.tsql_frame
     )
    )
    ADD TARGET package0.event_file
    (SET filename = N'all_sql_statements_cpu')
WITH
(
    MAX_MEMORY = 4096KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 30 SECONDS,
    MAX_EVENT_SIZE = 0KB,
    MEMORY_PARTITION_MODE = NONE,
    TRACK_CAUSALITY = OFF,
    STARTUP_STATE = OFF
)
END
GO

DECLARE @start_time DATETIME2 = GETDATE();

ALTER EVENT SESSION all_sql_statements_cpu ON SERVER STATE = START;

WAITFOR DELAY '00:01:00.000';

ALTER EVENT SESSION all_sql_statements_cpu ON SERVER STATE = STOP;

--Query all_sql_statements_cpu
SET NOCOUNT ON;

-- declare local variables
DECLARE @FileName NVARCHAR(255);
DECLARE @EventSession NVARCHAR(255);
DECLARE @ErrorMessage NVARCHAR(MAX);

-- initialize local variables
SET @EventSession = N'all_sql_statements_cpu';
--SET @ErrorMessage = 'Procedure or function ''spLocation_InsertLocationPostalCode'' expects parameter ''@PostalCode'', which was not supplied.'

-- find events that include the error message
SELECT @FileName = CASE
                       WHEN PATINDEX('%.xel%', CAST(esf.value AS NVARCHAR(255))) = 0 THEN
                           CAST(esf.value AS NVARCHAR(255)) + '*xel'
                       ELSE
                           REPLACE(CAST(esf.value AS NVARCHAR(255)), '.xel', '*xel')
                   END
FROM sys.server_event_sessions es
    INNER JOIN sys.server_event_session_fields esf
        ON es.event_session_id = esf.event_session_id
WHERE es.name = @EventSession
      AND esf.name = 'filename';

--SELECT CAST(event_data AS XML) AS event_Data
--FROM sys.fn_xe_file_target_read_file(@FileName, NULL, NULL, NULL);

WITH events_cte
AS (SELECT DATEADD(
                      mi,
                      DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP),
                      event_data.value('(event/@timestamp)[1]', 'datetime2')
                  ) AS [event_time],
           event_data.value('(event/@name)[1]', 'varchar(255)') AS [event_name],
           event_data.value('(event/data[@name="cpu_time"]/value)[1]', 'bigint') AS [cpu_time],
           event_data.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS [sql_text],
           event_data
    FROM
    (
        SELECT CAST(event_data AS XML) AS event_Data
        FROM sys.fn_xe_file_target_read_file(@FileName, NULL, NULL, NULL)
    ) AS tab(event_data) )
SELECT event_name,
       SUM(cpu_time) total_cpu_time,
       COUNT(1) AS executions,
       sql_text --,
--event_data
FROM events_cte
WHERE event_time > @start_time
GROUP BY event_name,
         sql_text
ORDER BY total_cpu_time DESC;



