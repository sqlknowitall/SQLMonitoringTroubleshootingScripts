/*********************************************************************************************
PURPOSE:    Shows what is currently using tempdb
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name				Change Description                                    
----------			--------------				------------------
07/18/2020			Jared Karney				Original Version
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


SELECT
	st.dbid AS QueryExecutionContextDBID,
	DB_NAME(st.dbid) AS QueryExecContextDBNAME,
	st.objectid AS ModuleObjectId,
	SUBSTRING(st.TEXT,
				r.statement_start_offset/2 + 1,
				(CASE
					WHEN r.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX),st.TEXT)) * 2
					ELSE r.statement_end_offset
				END - r.statement_start_offset)/2) AS Query_Text,
	t.session_id ,
	t.request_id,
	t.exec_context_id,
	(t.user_objects_alloc_page_count - t.user_objects_dealloc_page_count) AS OutStanding_user_objects_page_counts,
	(t.internal_objects_alloc_page_count - t.internal_objects_dealloc_page_count) AS OutStanding_internal_objects_page_counts,
	r.start_time,
	r.command,
	r.open_transaction_count,
	r.percent_complete,
	r.estimated_completion_time,
	r.cpu_time,
	r.total_elapsed_time,
	r.reads,r.writes,
	r.logical_reads,
	r.granted_query_memory,
	s.HOST_NAME,
	s.login_name,
	s.program_name
FROM sys.dm_db_task_space_usage t
INNER JOIN sys.dm_exec_requests r
	ON t.session_id = r.session_id AND t.request_id = r.request_id
INNER JOIN sys.dm_exec_sessions s
	ON t.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE t.internal_objects_alloc_page_count + t.user_objects_alloc_page_count > 0
ORDER BY (t.user_objects_alloc_page_count - t.user_objects_dealloc_page_count) + (t.internal_objects_alloc_page_count - t.internal_objects_dealloc_page_count) DESC