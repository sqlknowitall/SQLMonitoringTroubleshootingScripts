USE DBA_MONITOR
GO

CREATE TABLE [dbo].[Activity_Tracking](
TrackingId BIGINT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
TrackingDateTime DATETIME,
	[session_id] [smallint] NOT NULL,
	[login_time] [datetime] NOT NULL,
	[host_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[client_version] [int] NULL,
	[client_interface_name] [nvarchar](32) NULL,
	[Login_name] [nvarchar](128) NOT NULL,
	[nt_domain] [nvarchar](128) NULL,
	[nt_user_name] [nvarchar](128) NULL,
	[status] [nvarchar](30) NOT NULL,
	[cpu_time] [int] NOT NULL,
	[memory_usage] [int] NOT NULL,
	[total_scheduled_time] [int] NOT NULL,
	[total_elapsed_time] [int] NOT NULL,
	[last_request_end_time] [datetime] NULL,
	[reads] [bigint] NOT NULL,
	[writes] [bigint] NOT NULL,
	[logical_reads] [bigint] NOT NULL,
	[is_user_process] [bit] NOT NULL,
	[quoted_identifier] [bit] NOT NULL,
	[arithabort] [bit] NOT NULL,
	[ansi_null_dflt_on] [bit] NOT NULL,
	[ansi_defaults] [bit] NOT NULL,
	[ansi_warnings] [bit] NOT NULL,
	[ansi_padding] [bit] NOT NULL,
	[ansi_nulls] [bit] NOT NULL,
	[transaction_isolation_level] [smallint] NOT NULL,
	[lock_timeout] [int] NOT NULL,
	[deadlock_priority] [int] NOT NULL,
	[row_count] [bigint] NOT NULL,
	[prev_error] [int] NOT NULL,
	[original_login_name] [nvarchar](128) NOT NULL,
	[last_successful_logon] [datetime] NULL,
	[last_unsuccessful_logon] [datetime] NULL,
	[unsuccessful_logons] [bigint] NULL,
	[group_id] [int] NOT NULL,
	[database_id] [smallint] NOT NULL,
	[authenticating_database_id] [int] NULL,
	[open_transaction_count] [int] NOT NULL,
	[page_server_reads] [bigint] NOT NULL,
	[event_type] [nvarchar](256) NULL,
	[parameters] [smallint] NULL,
	[event_info] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE PROCEDURE sp_LoadActivityTracking
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO Activity_Tracking (TrackingDateTime,
		[session_id],
		[login_time],
		[host_name],
		[program_name],
		[client_version],
		[client_interface_name],
		[Login_name],
		[nt_domain],
		[nt_user_name],
		[status],
		[cpu_time],
		[memory_usage],
		[total_scheduled_time],
		[total_elapsed_time],
		[last_request_end_time],
		[reads],
		[writes],
		[logical_reads],
		[is_user_process],
		[quoted_identifier],
		[arithabort],
		[ansi_null_dflt_on],
		[ansi_defaults] ,
		[ansi_warnings],
		[ansi_padding],
		[ansi_nulls],
		[transaction_isolation_level],
		[lock_timeout],
		[deadlock_priority],
		[row_count],
		[prev_error],
		[original_login_name],
		[last_successful_logon],
		[last_unsuccessful_logon],
		[unsuccessful_logons],
		[group_id],
		[database_id],
		[authenticating_database_id],
		[open_transaction_count],
		[page_server_reads],
		[event_type],
		[parameters],
		[event_info]
	)
	SELECT GETDATE(), s.session_id, s.login_time, s.host_name, s.program_name, s.client_version
		, s.client_interface_name, s.Login_name, s.nt_domain, s.nt_user_name
		, s.status, s.cpu_time, s.memory_usage, s.total_scheduled_time, s.total_elapsed_time
		, s.last_request_end_time, s.reads, s.writes, s.logical_reads, s.is_user_process
		, s.quoted_identifier, s.arithabort, s.ansi_null_dflt_on, s.ansi_defaults, s.ansi_warnings
		, s.ansi_padding, s.ansi_nulls, s.transaction_isolation_level, s.lock_timeout
		, s.deadlock_priority, s.row_count, s.prev_error, s.original_login_name, s.last_successful_logon
		, s.last_unsuccessful_logon, s.unsuccessful_logons, s.group_id, s.database_id
		, s.authenticating_database_id, s.open_transaction_count, s.page_server_reads
		, ib.event_type, ib.parameters, ib.event_info
	FROM sys.dm_exec_sessions s
	CROSS APPLY sys.dm_exec_input_buffer(s.session_id, NULL) ib
END



