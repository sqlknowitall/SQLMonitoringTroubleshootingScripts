/**********************************************************************************************
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
**********************************************************************************************/


-- Find cursor(s) that may be causing issues. Replace 0 in sys.dm_exec_cursors with the session_id if you want to filter
SELECT c.session_id, es.program_name, es.login_name, es.host_name, DB_NAME(es.database_id) AS DatabaseName, c.properties, c.creation_time, c.is_open, t.text
FROM sys.dm_exec_cursors (0) c
LEFT JOIN sys.dm_exec_sessions AS es ON c.session_id = es.session_id
CROSS APPLY sys.dm_exec_sql_text (c.sql_handle) t