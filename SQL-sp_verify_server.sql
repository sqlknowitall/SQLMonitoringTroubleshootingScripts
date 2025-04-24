/****** Object:  Table [dbo].[Exceptions_All_Logs]    Script Date: 5/12/2015 7:42:16 AM ******/
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Exceptions_All_Logs')
CREATE TABLE [dbo].[Exceptions_All_Logs](
	[EventText] [varchar](2048) NOT NULL
) ON [PRIMARY]

GO

/****** Object:  StoredProcedure [dbo].[checkdisable_xp_cmdshell]    Script Date: 5/12/2015 7:42:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.procedures WHERE name = 'checkdisable_xp_cmdshell')
CREATE PROC [dbo].[checkdisable_xp_cmdshell]
/*********************************************************************************************
PURPOSE:	Purpose of this object is to return xp_cmdshell to the previous state.
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name			Change Description	
----------			--------------			------------------
UNKNOWN				Jared Karney			Original Version
07/08/2013			James N. Rzepka			Updated to add "WITH OVERRIDE"
08/13/2013			James N. Rzepka			Updated to log app
----------------------------------------------------------------------------------------------
USAGE:

DECLARE @xp_cmdshell int
EXEC @xp_cmdshell = DBOM.dbo.checkenable_xp_cmdshell

--Insert code that uses xp_cmdshell here

EXEC DBOM.dbo.checkdisable_xp_cmdshell @returned = @xp_cmdshell
**********************************************************************************************/
	@returned INT,
	@CallingApp varchar(128) = NULL
AS
BEGIN
	IF @returned = 0
	BEGIN
		DECLARE @Message varchar(256)
		SELECT @Message = 'xp_cmdshell being disabled by ' + ISNULL(@CallingApp, 'Undefined')
		EXEC xp_logevent 50001, @Message, 'INFORMATIONAL'
		EXEC sp_configure 'xp_cmdshell', 0
		RECONFIGURE WITH OVERRIDE
	END
END


GO
/****** Object:  StoredProcedure [dbo].[checkenable_xp_cmdshell]    Script Date: 5/12/2015 7:42:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.procedures WHERE name = 'checkenable_xp_cmdshell')
CREATE PROC [dbo].[checkenable_xp_cmdshell]
/*********************************************************************************************
PURPOSE:	Purpose of this object is to enable xp_cmdshell and return the previous state.
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name			Change Description	
----------			--------------			------------------
UNKNOWN				Jared Karney			Original Version
07/08/2013			James N. Rzepka			Updated to add "WITH OVERRIDE"
08/13/2013			James N. Rzepka			Updated to log app
----------------------------------------------------------------------------------------------
USAGE:

DECLARE @xp_cmdshell int
EXEC @xp_cmdshell = DBOM.dbo.checkenable_xp_cmdshell

--Insert code that uses xp_cmdshell here

EXEC DBOM.dbo.checkdisable_xp_cmdshell @returned = @xp_cmdshell
**********************************************************************************************/
	@CallingApp varchar(128) = NULL
AS
BEGIN
	IF EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'xp_cmdshell' AND value_in_use = 0)
	BEGIN
		DECLARE @Message varchar(256)
		SELECT @Message = 'xp_cmdshell being enabled for ' + ISNULL(@CallingApp, 'Undefined')
		EXEC xp_logevent 50001, @Message, 'INFORMATIONAL'
		EXEC sp_configure 'xp_cmdshell', 1
		RECONFIGURE WITH OVERRIDE
		RETURN 0
	END

	RETURN 1
END


GO

/****** Object:  StoredProcedure [dbo].[usp_Read_All_Logs]    Script Date: 5/12/2015 7:42:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_Read_All_Logs')
CREATE PROCEDURE [dbo].[usp_Read_All_Logs]
/*********************************************************************************************
PURPOSE:	Purpose of this object is to combine all server logs for easier review.
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date			Developer Name			Change Description	
----------		--------------			------------------
07/27/2012		James N. Rzepka			Original Version
08/14/2012		James N. Rzepka			Added Exceptions
08/20/2012		James N. Rzepka			Added @SearchText filter.
01/17/2013		James N. Rzepka			Added @ShowMailLog - Show mail logs.
03/26/2013		Jared Karney			Moved to DBOM
04/23/2013		James N. Rzepka			Split out final report to @Report to use as varchar(max). 
										Added @debug.
05/29/2013		James N. Rzepka			Fixed system logs issue.
07/15/2013		James N. Rzepka			xp_cmdshell (turn on/off for each use)
08/11/2013		James N. Rzepka			updated xp_readerrorlog to use nvarchar for search string 1.
08/13/2013		James N. Rzepka			Updated to log app for xp_cmdshell
05/06/2014		James N. Rzepka			Updated to add primary key to #eventlog2008 - slight performance improvement
07/03/2014		James N. Rzepka			Updated to pull cluster logs using powershell for Windows Server 2012+
08/02/2014		James N. Rzepka			Updated to not return an empty resultset.
03/02/2015		James N. Rzepka			Updated to filter the Powershell Cluster log for time range.
----------------------------------------------------------------------------------------------
USAGE:

EXEC dbo.usp_Read_All_Logs
	@NumberOfDays = 2,		--Starting now, go back this number of days
	@ShowAgent = 1,			--Show agent error log
	@ShowSQL = 1,			--show SQL error log
	@ShowWinApp = 1,		--Show Windows Application Log
	@ShowWinSys = 1,		--Show Windows System Log
	@ShowClusterLog = 1,	--Show Cluster Log
	@ShowClusterInfo = 0,	--Show info from cluster log (cluster log must be shown)
	@ShowClusterDebug = 0,	--Show debug from cluster log (cluster log must be shown)
	@ShowDeadlocks = 0,		--Show deadlocks
	@ShowBackups = 0,		--Show Backup events (SQL Log)
	@ShowSQLInfo = 1,		--Show information only (SQL Log)
	@ShowExceptions = 0		--Don't show exceptions

--In case it's needed:
	@start_date = NULL,		--Start at this date (overrides number of days)
	@end_date NULL,			--End at this date

**********************************************************************************************/
	@start_date datetime = NULL,
	@end_date datetime = NULL,
	@NumberOfDays int = 2,
	@ShowAgent bit = 1,
	@ShowSQL bit = 1,
	@ShowWinApp bit = 1,
	@ShowWinSys bit = 1,
	@ShowClusterLog bit = 1,
	@ShowClusterInfo bit = 0,
	@ShowClusterDebug bit = 0,
	@ShowMailLog bit = 1,
	@ShowDeadlocks bit = 0,
	@ShowBackups bit = 0,
	@ShowSQLInfo bit = 1,
	@ShowExceptions bit = 1,
	@DailyReport bit = 0,
	@SearchText varchar(2048) = null,
	@Debug bit = 0
AS
SET NOCOUNT ON

SELECT	 @start_date = isnull(@start_date, dateadd(day, @NumberOfDays * -1, getdate()))
		,@end_date = isnull(@end_date, getdate())

DECLARE  @TimeRange bigint
		,@NumErrorLogs int
		,@LogNum int
		,@SQL nvarchar(4000)
		,@Report varchar(MAX)
		,@Node varchar(128)
		,@loc int
		,@windows_release varchar(256)
		,@xpcheck INT

SELECT	@TimeRange = convert(bigint,datediff(second, @start_date, @end_date)) * 1000

CREATE TABLE #AllLogs(EventTime datetime, Node varchar(128), EvtSource varchar(256), EventDescription varchar(4096))
CREATE TABLE #errorlog (id int identity(1,1), Node varchar(128),logdate datetime, processinfo varchar(25), errortxt varchar(4096))
CREATE TABLE #ErrorLogEnum (LogNum int, LogDate datetime, LogSize int)
CREATE TABLE #eventlog2008(eventid int identity (1,1) PRIMARY KEY CLUSTERED,Messages varchar(1024),servername varchar(256))
CREATE TABLE #ClusterLogOutput (Msg varchar(512))
CREATE TABLE #ClusterLogImport (Msg varchar(1024))

if @ShowSQL = 1
begin
	set @loc = 0
	set @LogNum = 0
	set @NumErrorLogs = NULL
	Insert into #ErrorLogEnum
	EXEC master.sys.xp_enumerrorlogs 1
	select @NumErrorLogs = (select count(*)from #ErrorLogEnum)
	--SELECT 'Number of Error Logs (should be 13, 12+1 running): ' + convert(varchar(5), @NumErrorLogs)
	--print @NumErrorLogs
	while (@LogNum <= @NumErrorLogs and (select LogDate from #ErrorLogEnum where LogNum = @LogNum) > @start_date)
	begin
		--print 'Reading error log ' + convert(varchar(5), @LogNum)
		insert into #errorlog (logdate, processinfo, errortxt)
		EXEC master.sys.xp_readerrorlog
			@LogNum, --change to 0 for current errorlog
			1, --type of log (sql,sqlagent)
			null, --search for string 1
			null, --search for string 2
			@start_date,
			@end_date,
			'asc'
		if not exists (SELECT errortxt from #errorlog where errortxt like 'The NETBIOS name of the local node that is running the server is%' and ID >= @loc)
		BEGIN
			insert into #errorlog (logdate, processinfo, errortxt)
			EXEC master.sys.xp_readerrorlog
				@LogNum, --change to 0 for current errorlog
				1, --type of log (sql,sqlagent)
				N'The NETBIOS name of the local node that is running the server is'
			SELECT @Node = replace(replace(errortxt,'The NETBIOS name of the local node that is running the server is ''',''),'''. This is an informational message only. No user action is required.','') from #errorlog where errortxt like 'The NETBIOS name of the local node that is running the server is%' and ID >= @loc	
			DELETE FROM #errorlog where errortxt like 'The NETBIOS name of the local node that is running the server is%' and ID >= @loc
		END
		ELSE 
			SELECT @Node = replace(replace(errortxt,'The NETBIOS name of the local node that is running the server is ''',''),'''. This is an informational message only. No user action is required.','') from #errorlog where errortxt like 'The NETBIOS name of the local node that is running the server is%' and ID >= @loc	
		UPDATE #errorlog
		SET Node = isnull(@Node, @@Servername)
		WHERE Node is null
		select @loc = isnull(max(id),0) from #errorlog

		select @LogNum = @LogNum + 1
	end
	TRUNCATE table #ErrorLogEnum
	-- select filtered data from results which were put into temp table
	--select 'SQL ERROR LOG BETWEEN '+convert(varchar(20), @start_date, 100)+' and '+convert(varchar(20), @end_date, 100)
	INSERT INTO #AllLogs (EventTime, Node, EvtSource, EventDescription)
	select t1.logdate, t1.node, 'SQL Log: ' + t1.processinfo, t1.errortxt 
	from #errorlog t1
	left join (select logdate, processinfo from #errorlog
				where errortxt like 'deadlock-list' and @ShowDeadlocks = 0
				group by logdate, processinfo) t3
	  on t1.logdate between dateadd(second, -1, t3.logdate) and dateadd(second, +3, t3.logdate)
	  and t1.processinfo = t3.processinfo
	where t3.processinfo is null
	and errortxt not like CASE WHEN @ShowSQLInfo = 0 THEN '%This is an informational message only%' ELSE '' END
	and errortxt not like 'dbcc checktable%'
	and t1.processinfo <> CASE WHEN @ShowBackups = 0 THEN 'Backup' ELSE '' END
	ORDER BY t1.logdate ASC
	TRUNCATE TABLE #errorlog
end

if @ShowAgent = 1
Begin
	set @loc = 0
	set @LogNum = 0
	set @NumErrorLogs = NULL
	Insert into #ErrorLogEnum
	EXEC master.sys.xp_enumerrorlogs 2
	select @NumErrorLogs = (select count(*)from #ErrorLogEnum)
	--print @NumErrorLogs
	while (@LogNum <= @NumErrorLogs and (select LogDate from #ErrorLogEnum where LogNum = @LogNum) > @start_date)
	begin
		--print 'Reading error log ' + convert(varchar(5), @LogNum)
		insert into #errorlog (logdate, processinfo, errortxt)
		EXEC master.sys.xp_readerrorlog
			@LogNum, --change to 0 for current errorlog
			2, --type of log (sql,sqlagent)
			null, --search for string 1
			null, --search for string 2
			@start_date,
			@end_date,
			'asc'
				
		--Assuming SQL Error Log number corresponds to Agent Error Log number (Agent log does not have node name)
		insert into #errorlog (logdate, processinfo, errortxt)
		EXEC master.sys.xp_readerrorlog
			@LogNum, --change to 0 for current errorlog
			1, --type of log (sql,sqlagent)
			N'The NETBIOS name of the local node that is running the server is'
		SELECT @Node = replace(replace(errortxt,'The NETBIOS name of the local node that is running the server is ''',''),'''. This is an informational message only. No user action is required.','') from #errorlog where errortxt like 'The NETBIOS name of the local node that is running the server is%' and ID >= @loc	
		DELETE FROM #errorlog where errortxt like 'The NETBIOS name of the local node that is running the server is%' and ID >= @loc
		UPDATE #errorlog
		SET Node = isnull(@Node, @@Servername)
		WHERE Node is null
		select @loc = isnull(max(id),0) from #errorlog

		select @LogNum = @LogNum + 1
	end

	INSERT INTO #AllLogs (EventTime, Node, EvtSource, EventDescription)
	select logdate, node, 'SQL Agent Log: ' + processinfo, errortxt 
	from #errorlog
	order by logdate asc
	TRUNCATE TABLE #errorlog
end

IF (SELECT count(1) FROM sys.dm_os_cluster_nodes) > 0
	SELECT @Node = min(NodeName) from sys.dm_os_cluster_nodes
ELSE
	SELECT @Node = convert(varchar(128), SERVERPROPERTY('ComputerNamePhysicalNetBIOS'))

WHILE @Node is not null
BEGIN

	IF @ShowWinApp = 1
	BEGIN
	--  select 'APPLICATION LOG ERRORS and WARNINGS:'
		set @SQL = 'wevtutil qe application "/q:*[System[(Level=1  or Level=2 or Level=3)  and TimeCreated [timediff(@SystemTime) <= '+convert(varchar(32),@TimeRange)+']]]" /f:text /r:'+@Node
	--  print @SQL
		EXEC @xpcheck = dbo.checkenable_xp_cmdshell @CallingApp = 'read_all_logs - app log';
		insert into #eventlog2008(Messages)
		exec xp_cmdshell @SQL
		EXEC dbo.checkdisable_xp_cmdshell @xpcheck, @CallingApp = 'read_all_logs - app log';
      
		update #eventlog2008 
		set servername = @Node
		where servername is null
      
		INSERT INTO #AllLogs (EventTime, Node, EvtSource, EventDescription)
		SELECT 	REPLACE(REPLACE(eventdate.Messages, '  Date: ', ''), 'T', ' ') AS [Event Time],
				eventid.servername,
				'Win App Log: ' + REPLACE(eventsource.Messages, '  Source: ', '') AS [Source],
				REPLACE(eventlevel.Messages, '  Level: ', '') + ': ' +
				eventdescription1.Messages +
				ISNULL(eventdescription2.Messages, '') +
				ISNULL(eventdescription3.Messages, '') +
				ISNULL(eventdescription4.Messages, '') +
				ISNULL(eventdescription5.Messages, '') AS [Event Description]
		FROM #eventlog2008 eventid
		LEFT JOIN #eventlog2008 eventid2
		ON eventid.Messages LIKE 'Event[[]%]:' AND eventid2.Messages LIKE 'Event[[]%]:'
		AND CONVERT(int, REPLACE(REPLACE(eventid.Messages, 'Event[', ''), ']:', '')) = CONVERT(int, REPLACE(REPLACE(eventid2.Messages, 'Event[', ''), ']:', '')) - 1
		JOIN #eventlog2008 eventdate
		ON eventdate.eventid = eventid.eventid + 3
		JOIN #eventlog2008 eventsource
		ON eventsource.eventid = eventid.eventid + 2
		JOIN #eventlog2008 eventdescription1
		ON eventdescription1.eventid = eventid.eventid + 13
		LEFT JOIN #eventlog2008 eventdescription2
		ON eventdescription2.eventid = eventid.eventid + 14
		AND eventdescription2.eventid < ISNULL(eventid2.eventid, (SELECT MAX(eventid) FROM #eventlog2008))
		LEFT JOIN #eventlog2008 eventdescription3
		ON eventdescription3.eventid = eventid.eventid + 15
		AND eventdescription3.eventid < ISNULL(eventid2.eventid, (SELECT MAX(eventid) FROM #eventlog2008))
		LEFT JOIN #eventlog2008 eventdescription4
		ON eventdescription4.eventid = eventid.eventid + 16
		AND eventdescription4.eventid < ISNULL(eventid2.eventid, (SELECT MAX(eventid) FROM #eventlog2008))
		LEFT JOIN #eventlog2008 eventdescription5
		ON eventdescription5.eventid = eventid.eventid + 17
		AND eventdescription5.eventid < ISNULL(eventid2.eventid, (SELECT MAX(eventid) FROM #eventlog2008))
		JOIN #eventlog2008 eventlevel
		ON eventlevel.eventid = eventid.eventid + 6
		WHERE eventid.Messages LIKE 'Event[[]%]:'
		AND eventdescription1.Messages NOT LIKE 'Driver % is unknown. Contact the administrator to install the driver before you log in again.'
		AND eventdescription1.Messages <> 'N/A'
		AND eventdescription1.Messages NOT LIKE '%BackupMedium%'
		AND eventdescription1.Messages NOT LIKE '%BackupVirtualDeviceFile%' --backup failures will be reported in job failure report
		AND ISDATE(REPLACE(REPLACE(eventdate.Messages, '  Date: ', ''), 'T', ' ')) = 1 
		ORDER BY CONVERT(int, REPLACE(REPLACE(eventid.Messages, 'Event[', ''), ']:', ''))
		OPTION (MAXDOP 1)

		truncate table #eventlog2008
	END
	IF @ShowWinSys = 1
	BEGIN

	--  select 'SYSTEM LOG ERRORS and WARNINGS:'
		set @SQL = 'wevtutil qe system "/q:*[System[(Level=1  or Level=2 or Level=3)  and TimeCreated [timediff(@SystemTime) <= '+convert(varchar(32),@TimeRange)+']]]" /f:text /r:'+@Node
	--  print @SQL
		EXEC @xpcheck = dbo.checkenable_xp_cmdshell @CallingApp = 'read_all_logs - sys log';
		insert into #eventlog2008(Messages)
		exec xp_cmdshell @SQL
		EXEC dbo.checkdisable_xp_cmdshell @xpcheck, @CallingApp = 'read_all_logs - sys log';

		update #eventlog2008 
		set servername = @Node
		where servername is null

		INSERT INTO #AllLogs (EventTime, Node, EvtSource, EventDescription)
		SELECT 	REPLACE(REPLACE(eventdate.Messages, '  Date: ', ''), 'T', ' ') AS [Event Time],
				eventid.servername,
				'Win Sys Log: ' + REPLACE(eventsource.Messages, '  Source: ', '') AS [Source],
				REPLACE(eventlevel.Messages, '  Level: ', '') + ': ' +
				eventdescription1.Messages +
				ISNULL(eventdescription2.Messages, '') +
				ISNULL(eventdescription3.Messages, '') +
				ISNULL(eventdescription4.Messages, '') +
				ISNULL(eventdescription5.Messages, '') AS [Event Description]
		FROM #eventlog2008 eventid
		LEFT JOIN #eventlog2008 eventid2
		ON eventid.Messages LIKE 'Event[[]%]:' AND eventid2.Messages LIKE 'Event[[]%]:'
		AND CONVERT(int, REPLACE(REPLACE(eventid.Messages, 'Event[', ''), ']:', '')) = CONVERT(int, REPLACE(REPLACE(eventid2.Messages, 'Event[', ''), ']:', '')) - 1
		JOIN #eventlog2008 eventdate
		ON eventdate.eventid = eventid.eventid + 3
		JOIN #eventlog2008 eventsource
		ON eventsource.eventid = eventid.eventid + 2
		JOIN #eventlog2008 eventdescription1
		ON eventdescription1.eventid = eventid.eventid + 13
		LEFT JOIN #eventlog2008 eventdescription2
		ON eventdescription2.eventid = eventid.eventid + 14
		AND eventdescription2.eventid < ISNULL(eventid2.eventid, (SELECT MAX(eventid) FROM #eventlog2008))
		LEFT JOIN #eventlog2008 eventdescription3
		ON eventdescription3.eventid = eventid.eventid + 15
		AND eventdescription3.eventid < ISNULL(eventid2.eventid, (SELECT MAX(eventid) FROM #eventlog2008))
		LEFT JOIN #eventlog2008 eventdescription4
		ON eventdescription4.eventid = eventid.eventid + 16
		AND eventdescription4.eventid < ISNULL(eventid2.eventid, (SELECT MAX(eventid) FROM #eventlog2008))
		LEFT JOIN #eventlog2008 eventdescription5
		ON eventdescription5.eventid = eventid.eventid + 17
		AND eventdescription5.eventid < ISNULL(eventid2.eventid, (SELECT MAX(eventid) FROM #eventlog2008))
		JOIN #eventlog2008 eventlevel
		ON eventlevel.eventid = eventid.eventid + 6
		WHERE eventid.Messages LIKE 'Event[[]%]:'
		AND eventdescription1.Messages NOT LIKE 'Driver % is unknown. Contact the administrator to install the driver before you log in again.'
		AND eventdescription1.Messages <> 'N/A'
		AND eventdescription1.Messages NOT LIKE '%BackupMedium%'
		AND eventdescription1.Messages NOT LIKE '%BackupVirtualDeviceFile%' --backup failures will be reported in job failure report
		AND ISDATE(REPLACE(REPLACE(eventdate.Messages, '  Date: ', ''), 'T', ' ')) = 1 
		ORDER BY CONVERT(int, REPLACE(REPLACE(eventid.Messages, 'Event[', ''), ']:', ''))
		OPTION (MAXDOP 1)

		truncate table #eventlog2008
	END

	SELECT @Node = min(NodeName) from sys.dm_os_cluster_nodes WHERE NodeName > @Node
END

IF @ShowClusterLog = 1
BEGIN
	EXEC @xpcheck = dbo.checkenable_xp_cmdshell @CallingApp = 'read_all_logs - cluster log';

	SELECT @SQL = 'CLUSTER.EXE ' + CASE WHEN CHARINDEX('\', @@servername)>0 THEN SUBSTRING(@@servername,1,CHARINDEX('\', @@servername) - 1) ELSE @@servername END + ' LOG /GEN /COPY:"C:\Temp\cluster.log-DBA"'
	INSERT INTO #ClusterLogOutput
	EXEC xp_cmdshell @SQL

	SELECT @SQL = 'powershell Get-ClusterLog -Destination "C:\Temp\cluster.log-DBA" -TimeSpan ' + CONVERT(varchar(32), datediff(MINUTE, @start_date, GETDATE()))
	INSERT INTO #ClusterLogOutput
	EXEC xp_cmdshell @SQL
	
	DELETE FROM #ClusterLogOutput
	WHERE Msg NOT LIKE 'The cluster log has been successfully copied from node%'
	AND Msg NOT LIKE '-a---%_cluster.log%'

	SELECT @Node = UPPER(MIN(Node)) FROM
	(SELECT UPPER(substring(Msg,57,len(Msg)-61)) AS Node
	from #ClusterLogOutput
	WHERE Msg LIKE 'The cluster log has been successfully copied from node%'
	UNION
	SELECT UPPER(substring(Msg,46,CHARINDEX('_cluster.log', Msg, 46) - 46)) AS Node
	FROM #ClusterLogOutput
	WHERE msg like '-a---%_cluster.log%') nodes

	WHILE @Node is not null
	BEGIN
		IF @@MICROSOFTVERSION / 0x01000000 < 10
		BEGIN
			SELECT @SQL = 'BULK INSERT #ClusterLogImport FROM ''C:\Temp\cluster.log-DBA\' + @Node + '_Cluster.log''' 
		END
		ELSE
		BEGIN
			
			EXEC sp_executesql N'SELECT @windows_release = windows_release FROM sys.dm_os_windows_info', N'@windows_release varchar(256) OUTPUT', @windows_release = @windows_release OUTPUT
			IF CONVERT(decimal(3, 1), @windows_release) < 6.2
				SELECT @SQL = 'BULK INSERT #ClusterLogImport FROM ''C:\Temp\cluster.log-DBA\' + @Node + '_Cluster.log''' 
			ELSE
				SELECT @SQL = 'BULK INSERT #ClusterLogImport FROM ''C:\Temp\cluster.log-DBA\' + @Node + '_Cluster.log'' WITH(DATAFILETYPE=''widechar'')' 
		END

		EXEC (@SQL)

		DELETE FROM #ClusterLogImport WHERE dateadd(second,datediff(second,getutcdate(),getdate()),convert(datetime,replace(substring(Msg,20,23),'-',' '))) NOT BETWEEN @start_date AND @end_date

		IF @ShowClusterInfo = 0
		DELETE FROM #ClusterLogImport WHERE ltrim(rtrim(substring(Msg,43,7))) = 'INFO'

		IF @ShowClusterDebug = 0
		DELETE FROM #ClusterLogImport WHERE ltrim(rtrim(substring(Msg,43,7))) = 'DBG'

		INSERT INTO #AllLogs (EventTime, Node, EvtSource, EventDescription)
		SELECT dateadd(second,datediff(second,getutcdate(),getdate()),convert(datetime,replace(substring(Msg,20,23),'-',' '))), REPLACE(@Node, '.IAAI.COM', ''), 'Cluster Log: ' + ltrim(rtrim(substring(Msg,43,7))), substring(Msg,50,500)
		FROM #ClusterLogImport

		SELECT @SQL = 'Del C:\Temp\cluster.log-DBA\' + @Node + '_Cluster.log'
	
		INSERT INTO #ClusterLogImport
		EXEC xp_cmdshell @SQL

		TRUNCATE TABLE #ClusterLogImport

		SELECT @Node = UPPER(MIN(Node)) FROM
		(SELECT UPPER(substring(Msg,57,len(Msg)-61)) AS Node
		from #ClusterLogOutput
		WHERE Msg LIKE 'The cluster log has been successfully copied from node%'
		UNION
		SELECT UPPER(substring(Msg,46,CHARINDEX('_cluster.log', Msg, 46) - 46)) AS Node
		FROM #ClusterLogOutput
		WHERE msg like '-a---%_cluster.log%') nodes
		WHERE Node > @Node
	END

	INSERT INTO #ClusterLogImport
	EXEC xp_cmdshell 'rmdir C:\Temp\cluster.log-DBA\'
	EXEC dbo.checkdisable_xp_cmdshell @xpcheck, @CallingApp = 'read_all_logs - cluster log';
END

IF @ShowMailLog = 1
BEGIN
	INSERT INTO #AllLogs
	SELECT e.log_date, @@servername, 'sysmail - Status: ' + f.sent_status + ' Subject: ' + f.subject, e.description
	FROM msdb.dbo.sysmail_faileditems as f
	JOIN msdb.dbo.sysmail_event_log AS e
	ON f.mailitem_id = e.mailitem_id
	WHERE e.log_date BETWEEN @start_date AND @end_date
	ORDER BY e.log_date
END

IF @DailyReport = 1
BEGIN
	SELECT @Report = 'IF EXISTS(SELECT TOP 1 1 FROM #AllLogs '
	IF @ShowExceptions = 0 and (SELECT count(1) FROM [dbo].[Exceptions_All_Logs]) > 0
	BEGIN
		SELECT @Report = @Report + 'WHERE 1=1 '
		SELECT @Report = @Report + 'and EventDescription not like  ''' + [EventText] + '''' + char(10) FROM [dbo].[Exceptions_All_Logs]
	END

	IF @SearchText is not null
	BEGIN
		IF @Report not like '%WHERE 1=1 %'
		SELECT @Report = @Report + 'WHERE 1=1 '
		SELECT @Report = @Report + 'and EventDescription like  ''' + replace(@SearchText, '''', '''''') + '''' + char(10)
	
	END
	SELECT @Report = @Report + ')' + CHAR(10)

	SELECT @Report = @Report + 'SELECT convert(varchar(25),EventTime) as EventTime
		 , case when len(Node) <= 20 then convert(varchar(20), Node) else convert(varchar(20), convert(varchar(17), Node) + ''...'') end as Node
		 , case when len(EvtSource) <= 32 then convert(varchar(32), EvtSource) else convert(varchar(32), convert(varchar(29), EvtSource) + ''...'') end as EvtSource
		 , case when len(EventDescription) <= 200 then convert(varchar(200), EventDescription) else convert(varchar(200), convert(varchar(197), EventDescription) + ''...'') end as EventDescription
	 FROM #AllLogs' + char(10)
END
ELSE
BEGIN
	SELECT @Report = 'SELECT EventTime
		 , Node
		 , EvtSource
		 , EventDescription
	 FROM #AllLogs' + char(10)
END

IF @ShowExceptions = 0 and (SELECT count(1) FROM [dbo].[Exceptions_All_Logs]) > 0
BEGIN
	SELECT @Report = @Report + 'WHERE 1=1 '
	SELECT @Report = @Report + 'and EventDescription not like  ''' + [EventText] + '''' + char(10) FROM [dbo].[Exceptions_All_Logs]
END

IF @SearchText is not null
BEGIN
	IF @Report not like '%WHERE 1=1 %'
	SELECT @Report = @Report + 'WHERE 1=1 '
	SELECT @Report = @Report + 'and EventDescription like  ''' + replace(@SearchText, '''', '''''') + '''' + char(10)
	
END

SELECT @Report = @Report + 'ORDER BY convert(datetime,EventTime)'
IF @Debug = 1
	PRINT @Report
ELSE
	EXEC (@Report)

DROP TABLE #AllLogs
DROP TABLE #ErrorLogEnum
DROP TABLE #errorlog
DROP TABLE #eventlog2008
DROP TABLE #ClusterLogOutput
DROP TABLE #ClusterLogImport

GO

/****** Object:  StoredProcedure [dbo].[usp_Verify_Server]    Script Date: 5/12/2015 7:42:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Verify_Server]
/*********************************************************************************************
PURPOSE:	Purpose of this object is to verify servers.
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date			Developer Name				Change Description	
----------		--------------				------------------
10/17/2012		James N. Rzepka				Created proc from old script
08/11/2013		James N. Rzepka				Updated memory check to be dynamic.
09/06/2013		James N. Rzepka				Updated to fix error log reads/general cleanup.
----------------------------------------------------------------------------------------------
USAGE:		EXEC DBOM.dbo.usp_Verify_Server
**********************************************************************************************/
@Days int = 2

AS

SET NOCOUNT ON

PRINT '/***********************************************************************************************/'
SELECT @@SERVERNAME

declare @start_date datetime
		,@end_date datetime
		,@xpcheck INT

set @start_date = dateadd(day, -@Days, getdate())
set @end_date = getdate()

--declare @TimeRange bigint

--SELECT @TimeRange = datediff(millisecond, @start_date, @end_date)

print 'Report Dates '
print 'Start = ' + convert(varchar(20), @start_date, 100) 
print 'End = ' +  convert(varchar(20), @end_date, 100)

select 'Active Node = ' + convert(varchar(64),SERVERPROPERTY('ComputerNamePhysicalNetBIOS'))

--CURRENT MEMORY USED
SELECT  'Total Memory Currently Used by SQL Server' , cntr_value/1024 as 'MBs used'
from master.dbo.sysperfinfo
where    [object_name] like '%Memory Manager%' and counter_name = 'Total Server Memory (KB)'

--TOTAL MEMORY ON THE SERVER
SELECT  'Total Memory SQL Server is willing to consume' , cntr_value/1024 as 'MBs used'
from master.dbo.sysperfinfo
where    [object_name] like '%Memory Manager%' and counter_name = 'Target Server Memory (KB)'

--  Memory Check VS Inventory
IF @@MICROSOFTVERSION / 0x01000000 < 11
BEGIN

	IF EXISTS(SELECT 1 FROM sys.servers WHERE name = 'PMonitor3' AND data_source = 'PMonitor3')
	EXEC sp_executesql N'IF (SELECT ABS(t2.ramMB - convert(int,(t1.Physical_memory_in_bytes/1024.0)/1024.0))
		FROM sys.dm_os_sys_info t1 ,pmonitor3.DBA_Central.dbo.server t2
		WHERE SERVERNAME = @@SERVERNAME) > 1 
	BEGIN
		PRINT ''/*********Memory VS PMONITOR3 NOT EQUAL *********/''+CHAR(13)
		SELECT t2.ramMB AS ''Should Be (RAM)'', convert(int,(t1.Physical_memory_in_bytes/1024.0)/1024.0) AS ''Current (RAM)'' 
		FROM sys.dm_os_sys_info t1 ,pmonitor3.DBA_Central.dbo.server t2
		WHERE SERVERNAME = @@SERVERNAME
	END'
END
ELSE
BEGIN

	IF EXISTS(SELECT 1 FROM sys.servers WHERE name = 'PMonitor3' AND data_source = 'PMonitor3')
	EXEC sp_executesql N'IF (SELECT ABS(t2.ramMB - convert(int,(t1.Physical_memory_kb)/1024.0))
		FROM sys.dm_os_sys_info t1 ,pmonitor3.DBA_Central.dbo.server t2
		WHERE SERVERNAME = @@SERVERNAME) > 1 
	BEGIN
		PRINT ''/*********Memory VS PMONITOR3 NOT EQUAL *********/''+CHAR(13)
		SELECT t2.ramMB AS ''Should Be (RAM)'', convert(int,(t1.Physical_memory_kb)/1024.0) AS ''Current (RAM)'' 
		FROM sys.dm_os_sys_info t1 ,pmonitor3.DBA_Central.dbo.server t2
		WHERE SERVERNAME = @@SERVERNAME
	END'
END

/* Verify configured memory */
exec sp_configure 'max server memory (MB)'
exec sp_configure 'min server memory (MB)'

select SUM(awe_allocated_kb) / 1024 as [AWE allocated, Mb] 
from sys.dm_os_memory_clerks

--total - currently using
--target - how much it is willing to use.

-----------------------------------------------------------------------------------------------------

--VERIFY CPU COUNT
IF EXISTS(SELECT 1 FROM sys.servers WHERE name = 'PMonitor3' AND data_source = 'PMonitor3')
EXEC sp_executesql N'IF (SELECT t2.LogicalCPUCount - t1.cpu_count
	FROM master.sys.dm_os_sys_info t1,pmonitor3.DBA_CENTRAL.DBO.SERVER t2
	WHERE SERVERNAME = @@SERVERNAME) <> 0
BEGIN
	PRINT ''/*********VERIFY CPU*********/''+CHAR(13)
	SELECT t2.LogicalCPUCount AS ''SHOULD BE (Logical CPU)'',t1.cpu_count AS ''CURRENT (Logical CPU)''
	FROM master.sys.dm_os_sys_info t1,pmonitor3.DBA_CENTRAL.DBO.SERVER t2
	WHERE SERVERNAME = @@SERVERNAME
END'

-----------------------------------------------------------------------------------------------------

--VERIFY DATABASE STATUS
SELECT 'DATABASES NOT ONLINE',ltrim(rtrim(name)),ltrim(rtrim(state_Desc ))
FROM master.sys.databases
WHERE state_Desc <> 'ONLINE'

-----------------------------------------------------------------------------------------------------
 


--Jobs cancelled by shutdown.
SELECT 'Jobs cancelled by shutdown'
SELECT name as [Job Name],
		convert(datetime, CONVERT(CHAR(8), run_date, 112) + ' '
			+ STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':') ) as [Run Date],
		cast(run_duration / 1000 / 60 / 60 / 24 as varchar(5)) + 'd '
			+ right('00' + cast(run_duration / 1000 / 60 / 60 % 24 as varchar(2)), 2) + ':'
			+ right('00' + cast(run_duration / 1000 / 60 % 60 as varchar(2)), 2) + ':'
			+ right('00' + cast(run_duration / 1000 % 60 as varchar(2)), 2) + '.'
			+ right('000' + cast(run_duration % 1000 as varchar(3)), 3) as [Run Time],
		message
from msdb.dbo.sysjobs sj
join msdb.dbo.sysjobhistory sjh ON sj.job_id = sjh.job_id
where run_status = 3
and message LIKE 'The job was stopped prior to completion by Shutdown Sequence%'
and convert(datetime, CONVERT(CHAR(8), run_date, 112) + ' ' + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':') ) BETWEEN @start_date and @end_date
ORDER BY [Run Date]

-----------------------------------------------------------------------------------------------------

/*
--VERIFY SQL SERVER ERRORLOG
--exec master..XP_READERRORLOG 
--xp_readerrorlog

declare @NumErrorLogs int, @LogNum int, @SQL nvarchar(4000), @Node varchar(32), @loc int
--		@start_date varchar(15), 
--		@end_date varchar(15)
--
--set @start_date = '3/20/2011'
--set @end_date	= '3/28/2011'


create table #errorlog (id int identity(1,1), Node varchar(32),logdate datetime, processinfo varchar(25), errortxt varchar(4000))
create table #ErrorLogEnum (LogNum int, LogDate datetime, LogSize int)

set @loc = 0
set @LogNum = 0
set @NumErrorLogs = NULL
set @SQL = 
'exec Master..xp_enumerrorlogs'
--print (@SQL)
Insert into #ErrorLogEnum
EXEC (@SQL)
select @NumErrorLogs = (select count(*)from #ErrorLogEnum)
SELECT 'Number of Error Logs (should be 13, 12+1 running): ' + convert(varchar(5), @NumErrorLogs)
--print @NumErrorLogs
while (@LogNum < @NumErrorLogs and (select LogDate from #ErrorLogEnum where LogNum = @LogNum) > @start_date)
begin
	--print 'Reading error log ' + convert(varchar(5), @LogNum)
	set @SQL = 'exec master..xp_readerrorlog
	' + convert(char(2),@LogNum) + ', --change to 0 for current errorlog
	1, --type of log (sql,sqlagent)
	null, --search for string 1
	null, --search for string 2
	@start_date,
	@end_date,
	''asc'''
	--print @SQL
	insert into #errorlog (logdate, processinfo, errortxt)
	EXEC sp_executesql @SQL, N'@LogNum int, @start_date varchar(20), @end_date varchar (20)', @LogNum, @start_date, @end_date

	if not exists (SELECT errortxt from #errorlog where errortxt like 'The NETBIOS name of the local node that is running the server is%' and ID >= @loc)
	BEGIN
		set @SQL = 'exec master..xp_readerrorlog
		' + convert(char(2),@LogNum) + ', --change to 0 for current errorlog
		1, --type of log (sql,sqlagent)
		N''The NETBIOS name of the local node that is running the server is'''
		--print @SQL
		insert into #errorlog (logdate, processinfo, errortxt)
		EXEC sp_executesql @SQL, N'@LogNum int, @start_date varchar(20), @end_date varchar (20)', @LogNum, @start_date, @end_date
		SELECT @Node = replace(replace(errortxt,'The NETBIOS name of the local node that is running the server is ''',''),'''. This is an informational message only. No user action is required.','') from #errorlog where errortxt like 'The NETBIOS name of the local node that is running the server is%' and ID >= @loc	
		DELETE FROM #errorlog where errortxt like 'The NETBIOS name of the local node that is running the server is%' and ID >= @loc
	END
	ELSE 
		SELECT @Node = replace(replace(errortxt,'The NETBIOS name of the local node that is running the server is ''',''),'''. This is an informational message only. No user action is required.','') from #errorlog where errortxt like 'The NETBIOS name of the local node that is running the server is%' and ID >= @loc	
	UPDATE #errorlog
	SET Node = @Node
	WHERE Node is null

--	if exists(select 1 from #errorlog where errortxt = 'Recovery is complete. This is an informational message only. No user action is required.')
--	begin
--		  --print 'Reboot detected.  Removing errors before recovery is complete.'
--		  delete from #errorlog 
--		  where id <= (select id from #errorlog where errortxt = 'Recovery is complete. This is an informational message only. No user action is required.')
--		  and id >= @loc
--	end
--		
	select @loc = isnull(max(id),0) from #errorlog

	select @LogNum = @LogNum + 1
end
drop table #ErrorLogEnum

--drop table #errorlog

--create table #dbcc( dbname varchar(128) )

--drop table #dbcc


-- insert errorlog events for dbcc verification into temp table
--insert into #dbcc
--select distinct rtrim(ltrim(substring(errortxt, 18, charindex('.', errortxt)-18)))
--from #errorlog
--where errortxt like 'dbcc checktable%'
--
--select d.name as 'Databases which DBCC was not run:'
--from sys.sysdatabases d with (nolock)
--left outer join #dbcc dc
--  on d.name = dc.dbname
--where dc.dbname is null
--and databasepropertyex(name, 'updateability') <> 'Read_Only'
--and d.name not in ('master', 'model', 'tempdb', 'msdb')
--

-- select filtered data from results which were put into temp table
select 'SQL ERROR LOG BETWEEN '+convert(varchar(20), @start_date, 100)+' and '+convert(varchar(20), @end_date, 100)
select t1.logdate, t1.node, t1.processinfo, t1.errortxt 
from #errorlog t1
left join (select logdate, processinfo from #errorlog
			where errortxt like 'deadlock-list'
			group by logdate, processinfo) t3
  on t1.logdate between dateadd(second, -1, t3.logdate) and dateadd(second, +3, t3.logdate)
  and t1.processinfo = t3.processinfo
where t3.processinfo is null
and errortxt not like 'dbcc checktable%'
--and errortxt not like '%backed up.%'
and errortxt not like 'recovery is complete.This is an informational message only%'
and errortxt not like '%cachestore flush%'
and errortxt not like 'Starting up database%'
and errortxt not like 'Backup%'   -- only if backup fails job will fail
and errortxt not like 'Error: 18210%'
and errortxt not like '%Trace%'
and t1.processinfo <> 'Backup'    -- if there are failures job will fail
order by t1.logdate asc

--select * from #errorlog where processinfo = 'spid33s'
--order by 1
--select * from #errorlog
-- select reboots showing in error log
--select * from #reboot

--drop table #errorlog
--drop table #dbcc
--drop table #reboot

-- deadlocks
select 'DEADLOCKS'
select count(*) as 'deadlocks', convert(varchar(11), logdate, 113) as 'date', datename(weekday, convert(varchar(11), logdate, 113)) as 'day'
from (
select count(*) ct, convert(varchar(20), t1.logdate, 113) logdate, t1.processinfo--, t1.errortxt 
from #errorlog t1
join (select logdate, processinfo from #errorlog
			where errortxt like 'deadlock-list'
			group by logdate, processinfo) t3
  on t1.logdate between dateadd(second, -1, t3.logdate) and dateadd(second, +3, t3.logdate)
  and t1.processinfo = t3.processinfo
group by convert(varchar(20), t1.logdate, 113), t1.processinfo
--order by 2
) t
group by convert(varchar(11), logdate, 113) , datename(weekday, convert(varchar(11), logdate, 113))
order by 2


--JUST LOOK FOR ERROR STRING IN THE ERRORLOG
--exec master..xp_readerrorlog
--0, --change to 0 for current errorlog
--1, --type of log (sql,sqlagent)
--'error', --search for string 1
--null, --search for string 2
--'03/07/2010', --start date
--'03/15/2010', --end date
--'asc'

-----------------------------------------------------------------------------------------------------

--select @@version


--VERIFY EVENTLOG

set nocount on


--set @searchstring = 'The winlogon notification subscriber <GPClient>'

create table #eventlog2008(
eventid int identity (1,1)
,Messages varchar(1024)
)

create table #eventlog2003(
eventid int identity (1,1)
,Messages varchar(1024)
)

--if charindex('Windows NT 6.',@@version) > 0 --Windows Server 2008 Servers
--   begin
--
----	select 'APPLICATION LOG ERRORS and WARNINGS:'
--	declare @event_query_a varchar(164)
--	set @event_query_a = 'xp_cmdshell ''wevtutil qe application "/q:*[System[(Level=1  or Level=2 or Level=3)  and TimeCreated [timediff(@SystemTime) <= 86400000]]]" /f:text'''
----	print @event_query_a
--	insert into #eventlog2008
--	exec (@event_query_a)
--
----	select 'SYSTEM LOG ERRORS and WARNINGS:'
--	declare @event_query_s varchar(164)
--	set @event_query_s = 'xp_cmdshell ''wevtutil qe system "/q:*[System[(Level=1  or Level=2 or Level=3)  and TimeCreated [timediff(@SystemTime) <= 86400000]]]" /f:text'''
----	print @event_query_s
--	insert into #eventlog2008
--	exec (@event_query_s)
----select *
----from #eventlog2008
----
----select *
----from #eventlog2008
----where messages like '%' + @searchstring + '%'
----
--create table #events (eventtime datetime, errorlevel varchar(10), evtdesc varchar(1024))
--
--select 'EVENT LOG'
--insert into #events (eventtime, errorlevel, evtdesc)
--select convert(datetime, substring(e5.messages,9,10) + ' ' + substring(e5.messages,20,12)), replace(convert(varchar(16),e3.messages),'  Level: ',''), e1.messages + e6.messages
--from #eventlog2008 e1
--join #eventlog2008 e2
--on e1.eventid = e2.eventid + 1
--join #eventlog2008 e3
--on e1.eventid -7 = e3.eventid
--join #eventlog2008 e4
--on e1.eventid - 11 = e4.eventid
--and e2.messages like '  Description:%'
--join #eventlog2008 e5
--on e2.eventid - 9 = e5.eventid
--join #eventlog2008 e6
--on e1.eventid = e6.eventid - 1
--and e6.messages not like '%NULL%'
--where e1.messages not like '%BackupMedium%' 
--or e1.messages not like '%BackupVirtualDeviceFile%' --backup failures will be reported in job failure report
--
--order by 1 desc
--
----where eventid in (select eventid + 1 from #eventlog2008 where messages like '  Description:%')
--select * from #events
--order by 1
----select * from #eventlog2008
--
--   end
if charindex('Windows NT 6.',@@version) > 0 --Windows Server 2008 Servers
   begin

--	select 'APPLICATION LOG ERRORS and WARNINGS:'
	declare @event_query_a varchar(164)
	set @event_query_a = 'xp_cmdshell ''wevtutil qe application "/q:*[System[(Level=1  or Level=2 or Level=3)  and TimeCreated [timediff(@SystemTime) <= '+convert(varchar(32),@TimeRange)+']]]" /f:text'''
--	print @event_query_a
	insert into #eventlog2008
	exec (@event_query_a)

--	select 'SYSTEM LOG ERRORS and WARNINGS:'
	declare @event_query_s varchar(164)
	set @event_query_s = 'xp_cmdshell ''wevtutil qe system "/q:*[System[(Level=1  or Level=2 or Level=3)  and TimeCreated [timediff(@SystemTime) <= '+convert(varchar(32),@TimeRange)+']]]" /f:text'''
--	print @event_query_s
	insert into #eventlog2008
	exec (@event_query_s)

select 'EVENT LOG'
select count(*) as 'Count'
		,convert(varchar(20),min(convert(datetime,substring(e6.messages,charindex('Date:',e6.messages)+6,10) + ' ' + reverse(substring(reverse(e6.messages),1,charindex('T',reverse(e6.messages))-1))))) as MinTime
		,convert(varchar(20),max(convert(datetime,substring(e6.messages,charindex('Date:',e6.messages)+6,10) + ' ' + reverse(substring(reverse(e6.messages),1,charindex('T',reverse(e6.messages))-1))))) as MaxTime
		,convert(varchar(16),substring(e3.messages,10,8)) + ': ' + rtrim(e1.messages + e5.messages)-- + char(10)

from #eventlog2008 e1
join #eventlog2008 e2
on e1.eventid = e2.eventid + 1
join #eventlog2008 e3
on e1.eventid -7 = e3.eventid
join #eventlog2008 e4
on e1.eventid - 11 = e4.eventid
and e2.messages like '  Description:%'
join #eventlog2008 e5
on e1.eventid = e5.eventid - 1
and e5.messages not like '%NULL%'
join #eventlog2008 e6
on e6.eventid = e2.eventid - 9 
where e1.messages not like '%BackupMedium%' 
or e1.messages not like '%BackupVirtualDeviceFile%' --backup failures will be reported in job failure report

group by 
		convert(varchar(16),substring(e3.messages,10,8)) + ': ' + rtrim(e1.messages + e5.messages)-- + char(10)
		,e1.messages + char(10)
order by 1 desc



   end
else -- Windows 2003 Servers
   begin
--	SELECT 'APPLICATION LOG ERRORS:'
	declare @event_query varchar(128)
	set @event_query = 'xp_cmdshell ''cscript eventquery.vbs /fi "Datetime gt '+convert(varchar(10),getdate()-5,1)+',12:00:00AM" /fi "Type eq error" /l application /V'''
--	print @event_query
	insert into #eventlog2003
	exec (@event_query)

--	SELECT 'APPLICATION LOG WARNINGS:'
	declare @event_query_w varchar(128)
	set @event_query_w = 'xp_cmdshell ''cscript eventquery.vbs /fi "Datetime gt '+convert(varchar(10),getdate()-5,1)+',12:00:00AM" /fi "Type eq warning" /l application /V'''
--	print @event_query_w
	insert into #eventlog2003
	exec (@event_query_w)

--	SELECT 'SYSTEM LOG ERRORS:'
	declare @event_query_se varchar(128)
	set @event_query_se = 'xp_cmdshell ''cscript eventquery.vbs /fi "Datetime gt '+convert(varchar(10),getdate()-5,1)+',12:00:00AM" /fi "Type eq error" /l System /V'''
--	print @event_query_se
	insert into #eventlog2003
	exec (@event_query_se)

--	SELECT 'SYSTEM LOG WARNINGS:'
	declare @event_query_sw varchar(128)
	set @event_query_sw = 'xp_cmdshell ''cscript eventquery.vbs /fi "Datetime gt '+convert(varchar(10),getdate()-5,1)+',12:00:00AM" /fi "Type eq warning" /l System /V'''
--	print @event_query_sw
	insert into #eventlog2003
	exec (@event_query_sw)

select *
from #eventlog2003

   end

--drop table #events
--drop table #dbcc
--drop table #reboot
drop table #errorlog
drop table #eventlog2008
drop table #eventlog2003
-----------------------------------------------------------------------------------------------------

--VERIFY SQL SERVER AGENT SERVICE IS STARTED
SELECT 'SQL AGENT ERRORLOG:'
--exec master.sys.sp_readerrorlog @p2 = 2

-------------------OR------------------

exec master..xp_readerrorlog
1, --change to 0 for current errorlog
2, --type of log (sql,sqlagent)
null, --search for string 1
null, --search for string 2
@start_date,
@end_date,
'asc'

exec master..xp_readerrorlog
0, --change to 0 for current errorlog
2, --type of log (sql,sqlagent)
null, --search for string 1
null, --search for string 2
@start_date,
@end_date,
'asc'
*/

select 'ERROR LOG BETWEEN '+convert(varchar(20), @start_date, 100)+' and '+convert(varchar(20), @end_date, 100)
EXEC dbo.usp_Read_All_Logs
	@start_date = @start_date,
	@end_date = @end_date,
	@ShowAgent = 1,
	@ShowSQL = 1,
	@ShowWinApp = 1,
	@ShowWinSys = 1,
	@ShowClusterLog = 0,
	@ShowClusterInfo = 0,
	@ShowClusterDebug = 0,
	@ShowDeadlocks = 0,
	@ShowBackups = 0,
	@ShowSQLInfo = 1,
	@ShowExceptions = 1,
	@DailyReport = 1
GO