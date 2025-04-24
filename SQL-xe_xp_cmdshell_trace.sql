/**************************************************************************************************************
Author: Jared Karney

Original Date: 2018/04/14

Revisions:

Comments: This is an extended event script itended to capture all executions of xp_cmdshell. Be sure to 
	change the file path for the event file to an appropriate location


This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
***************************************************************************************************************/

CREATE EVENT SESSION [xe_xp_cmdshell_execution]
ON SERVER
    ADD EVENT sqlserver.rpc_starting
    (SET collect_statement = (1)
     ACTION
     (
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.sql_text,
         sqlserver.username
     )
     WHERE ([sqlserver].[like_i_sql_unicode_string]([statement], N'%xp_cmdshell%'))
    ),
    ADD EVENT sqlserver.sp_statement_starting
    (SET collect_object_name = (1)
     ACTION
     (
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.sql_text,
         sqlserver.username
     )
     WHERE ([sqlserver].[like_i_sql_unicode_string]([statement], N'%xp_cmdshell%'))
    ),
    ADD EVENT sqlserver.sql_batch_starting
    (SET collect_batch_text = (1)
     ACTION
     (
         sqlserver.client_app_name,
         sqlserver.client_hostname,
         sqlserver.database_id,
         sqlserver.database_name,
         sqlserver.sql_text,
         sqlserver.username
     )
     WHERE ([sqlserver].[like_i_sql_unicode_string]([batch_text], N'%xp_cmdshell%'))
    )
    ADD TARGET package0.event_file
    (SET filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log\xe_xp_cmdshell_execution.xel')
WITH
(
    MAX_MEMORY = 4096KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 30 SECONDS,
    MAX_EVENT_SIZE = 0KB,
    MEMORY_PARTITION_MODE = NONE,
    TRACK_CAUSALITY = OFF,
    STARTUP_STATE = ON
);
GO


