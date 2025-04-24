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


USE tempdb

SELECT  s.session_id,
        --DB_NAME(ssu.database_id) AS database_name,
        s.host_name ,
        s.program_name ,
        s.login_name ,
        s.status ,
        --s.cpu_time AS [CPU TIME (in milisec)] ,
        --s.total_scheduled_time AS [Total Scheduled TIME (in milisec)] ,
        s.total_elapsed_time AS [Elapsed TIME (in milisec)] ,
		s.last_request_start_time,
		s.last_request_end_time,
		(( ssu.user_objects_alloc_page_count * 8 ) + ( ssu.user_objects_dealloc_page_count * 8 ) + ( ssu.internal_objects_alloc_page_count * 8 ) + ( ssu.internal_objects_dealloc_page_count * 8 ))/1024 AS TotalSpaceMB ,
        --( s.memory_usage * 8 ) AS [Memory USAGE (in KB)] ,
        --( ssu.user_objects_alloc_page_count * 8 ) AS [SPACE Allocated FOR USER Objects (in KB)] ,
        --( ssu.user_objects_dealloc_page_count * 8 ) AS [SPACE Deallocated FOR USER Objects (in KB)] ,
        --( ssu.internal_objects_alloc_page_count * 8 ) AS [SPACE Allocated FOR Internal Objects (in KB)] ,
        --( ssu.internal_objects_dealloc_page_count * 8 ) AS [SPACE Deallocated FOR Internal Objects (in KB)] ,
        s.is_user_process ,
        s.row_count
FROM    sys.dm_db_session_space_usage ssu
        INNER JOIN sys.dm_exec_sessions s
        ON ssu.session_id = s.session_id
WHERE s.session_id > 50
ORDER BY TotalSpaceMB DESC;

/*
KILL 64
*/

