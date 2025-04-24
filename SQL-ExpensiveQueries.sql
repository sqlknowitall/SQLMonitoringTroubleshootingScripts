SELECT TOP 20 total_worker_time / execution_count AS AvgCPU ,
    total_worker_time AS TotalCPU ,
    total_elapsed_time / execution_count AS AvgDuration ,
    total_elapsed_time AS TotalDuration ,
    total_logical_reads / execution_count AS AvgReads ,
    total_logical_reads AS TotalReads ,
    execution_count ,
    qs.creation_time AS plan_creation_time,
    qs.last_execution_time,
    SUBSTRING(st.text, ( qs.statement_start_offset / 2 ) + 1, ( ( CASE qs.statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset
        END - qs.statement_start_offset ) / 2 ) + 1) AS QueryText,
        query_plan
    FROM sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
        CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
	ORDER BY AvgCPU DESC;
GO

SELECT TOP 20 total_worker_time / execution_count AS AvgCPU ,
    total_worker_time AS TotalCPU ,
    total_elapsed_time / execution_count AS AvgDuration ,
    total_elapsed_time AS TotalDuration ,
    total_logical_reads / execution_count AS AvgReads ,
    total_logical_reads AS TotalReads ,
    execution_count ,
    qs.creation_time AS plan_creation_time,
    qs.last_execution_time,
    SUBSTRING(st.text, ( qs.statement_start_offset / 2 ) + 1, ( ( CASE qs.statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset
        END - qs.statement_start_offset ) / 2 ) + 1) AS QueryText,
        query_plan
    FROM sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
        CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
    ORDER BY TotalDuration DESC;
GO

SELECT TOP 20 total_worker_time / execution_count AS AvgCPU ,
    total_worker_time AS TotalCPU ,
    total_elapsed_time / execution_count AS AvgDuration ,
    total_elapsed_time AS TotalDuration ,
    total_logical_reads / execution_count AS AvgReads ,
    total_logical_reads AS TotalReads ,
    execution_count ,
    qs.creation_time AS plan_creation_time,
    qs.last_execution_time,
    SUBSTRING(st.text, ( qs.statement_start_offset / 2 ) + 1, ( ( CASE qs.statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset
        END - qs.statement_start_offset ) / 2 ) + 1) AS QueryText,
        query_plan
    FROM sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
        CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
    ORDER BY TotalCPU DESC;
GO

SELECT TOP 20 total_worker_time / execution_count AS AvgCPU ,
    total_worker_time AS TotalCPU ,
    total_elapsed_time / execution_count AS AvgDuration ,
    total_elapsed_time AS TotalDuration ,
    total_logical_reads / execution_count AS AvgReads ,
    total_logical_reads AS TotalReads ,
    execution_count ,
    qs.creation_time AS plan_creation_time,
    qs.last_execution_time,
    SUBSTRING(st.text, ( qs.statement_start_offset / 2 ) + 1, ( ( CASE qs.statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset
        END - qs.statement_start_offset ) / 2 ) + 1) AS QueryText,
        query_plan
    FROM sys.dm_exec_query_stats AS qs
        CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
        CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
    ORDER BY TotalReads DESC;
GO


