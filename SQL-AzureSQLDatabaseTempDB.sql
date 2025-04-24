SELECT *
FROM SYS.dm_io_virtual_file_stats(2,null) A
INNER JOIN TEMPDB.sys.database_files B
	ON A.file_id = B.FILE_ID

select  *
from sys.dm_os_performance_counters 
where counter_name like '%temp%'