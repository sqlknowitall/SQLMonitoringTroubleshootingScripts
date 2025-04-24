USE [DBA_Rep]
GO

/****** Object:  StoredProcedure [dbo].[usp_Audit_Extract]    Script Date: 11/21/2018 2:21:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[usp_Audit_Extract]
/*********************************************************************************************
PURPOSE:	Purpose of this object is to Extract the audit reports.
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name			Change Description	
----------			--------------			------------------
01/09/2013			Jared Karney			Original Version
02/11/2013			Jared Karney			Updated to not stop/start audits, but use max date
											instead for insert.
08/05/2013			Jared Karney			Updated max date to use conversion style 109.
02/10/2014			Jared Karney			Defaulted @KeepDays to 180 instead of 30
04/29/2014			Jared Karney			Updated to include index if table is created.
06/30/2014			Jared Karney			Updated to work with standard on 2012.
07/18/2014			Jared Karney			Updated delete to remove index scan, added index.
12/29/2014			Jared Karney			Filtered 'OPEN SYMMETRIC KEY %DECRYPTION BY CERTIFICATE %'.
----------------------------------------------------------------------------------------------
USAGE:	EXEC dbo.[usp_Audit_Extract] @AuditName = 'Object_Change'
**********************************************************************************************/
	@AuditName varchar(128),
	@KeepDays int = 180,
	@BatchSize int = 25000,
	@LogTable varchar(128) = NULL,
	@Debug bit = 0

AS

SET NOCOUNT ON

--SELECT @AuditName = 'Object_Change'

DECLARE @AuditFile varchar(512), @SQL nvarchar(4000), @Error varchar(1024), @MaxRecord datetime, @Rowcount int

IF NOT (@@MICROSOFTVERSION / 0x01000000 > 10 OR (@@MICROSOFTVERSION / 0x01000000 = 10 AND SERVERPROPERTY('EngineEdition') = 3))
BEGIN
	RAISERROR ('Audit requires Enterprise edition and is only available in 2008 and newer.', 1,1)
	RETURN -1
END
IF NOT EXISTS (SELECT 1 FROM sys.server_audits sa JOIN sys.server_audit_specifications sas ON sa.audit_guid = sas.audit_guid WHERE sa.name = @AuditName AND sas.name = @AuditName)
BEGIN
	RAISERROR ('The requested audit is not running.', 16,10)
	RETURN -1
END

SELECT @AuditFile = sfa.log_file_path + sa.name + '_' + convert(varchar (128), sa.audit_guid) + '*.sqlaudit'
FROM sys.server_audits sa
JOIN sys.server_file_audits sfa
  ON sa.audit_id = sfa.audit_id
WHERE sa.name = @AuditName

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = ISNULL(@LogTable, 'Log_SvrAdt_' + @AuditName))
BEGIN
	SELECT @SQL = 'SELECT TOP 1 @MaxRecord = [event_time] FROM dbo.' + ISNULL(@LogTable, 'Log_SvrAdt_' + @AuditName) + ' ORDER BY [event_time] DESC'
	EXEC sp_executeSQL @SQL, N'@MaxRecord datetime OUTPUT', @MaxRecord = @MaxRecord OUTPUT
END
ELSE
BEGIN
	SELECT @SQL = 'CREATE TABLE dbo.' + ISNULL(@LogTable, 'Log_SvrAdt_' + @AuditName) + '(' + CHAR(10) +
	'	Log_Server_Audit_ID int IDENTITY,' + CHAR(10) +
	'	event_time datetime2 NOT NULL,' + CHAR(10) +
	'	sequence_number int NOT NULL,' + CHAR(10) +
	'	action_id varchar(4) NULL,' + CHAR(10) +
	'	succeeded bit NOT NULL,' + CHAR(10) +
	'	permission_bitmask bigint NOT NULL,' + CHAR(10) +
	'	is_column_permission bit NOT NULL,' + CHAR(10) +
	'	session_id smallint NOT NULL,' + CHAR(10) +
	'	server_principal_id int NOT NULL,' + CHAR(10) +
	'	database_principal_id int NOT NULL,' + CHAR(10) +
	'	target_server_principal_id int NOT NULL,' + CHAR(10) +
	'	target_database_principal_id int NOT NULL,' + CHAR(10) +
	'	object_id int NOT NULL,' + CHAR(10) +
	'	class_type varchar(2) NULL,' + CHAR(10) +
	'	session_server_principal_name nvarchar(128) NULL,' + CHAR(10) +
	'	server_principal_name nvarchar(128) NULL,' + CHAR(10) +
	'	server_principal_sid varbinary(85) NULL,' + CHAR(10) +
	'	database_principal_name nvarchar(128) NULL,' + CHAR(10) +
	'	target_server_principal_name nvarchar(128) NULL,' + CHAR(10) +
	'	target_server_principal_sid varbinary(85) NULL,' + CHAR(10) +
	'	target_database_principal_name nvarchar(128) NULL,' + CHAR(10) +
	'	server_instance_name nvarchar(128) NULL,' + CHAR(10) +
	'	database_name nvarchar(128) NULL,' + CHAR(10) +
	'	schema_name nvarchar(128) NULL,' + CHAR(10) +
	'	object_name nvarchar(128) NULL,' + CHAR(10) +
	'	statement nvarchar(4000) NULL,' + CHAR(10) +
	'	additional_information nvarchar(4000) NULL' + CHAR(10) +
	')' + CHAR(10) +
	'CREATE CLUSTERED INDEX CLIDX_' + ISNULL(@LogTable, 'Log_SvrAdt_' + @AuditName) + ' ON [dbo].[' + ISNULL(@LogTable, 'Log_SvrAdt_' + @AuditName) + '] ([Log_Server_Audit_ID])' + CHAR(10) +
	'CREATE NONCLUSTERED INDEX NCLIDX_' + ISNULL(@LogTable, 'Log_SvrAdt_' + @AuditName) + ' ON [dbo].[' + ISNULL(@LogTable, 'Log_SvrAdt_' + @AuditName) + '_event_time] ([event_time] DESC)'
	IF @Debug = 0
		EXEC (@SQL)
	ELSE
		PRINT @SQL
END

SELECT @SQL = 'INSERT INTO dbo.' + ISNULL(@LogTable, 'Log_SvrAdt_' + @AuditName) + ' ([event_time]
      ,[sequence_number]
      ,[action_id]
      ,[succeeded]
      ,[permission_bitmask]
      ,[is_column_permission]
      ,[session_id]
      ,[server_principal_id]
      ,[database_principal_id]
      ,[target_server_principal_id]
      ,[target_database_principal_id]
      ,[object_id]
      ,[class_type]
      ,[session_server_principal_name]
      ,[server_principal_name]
      ,[server_principal_sid]
      ,[database_principal_name]
      ,[target_server_principal_name]
      ,[target_server_principal_sid]
      ,[target_database_principal_name]
      ,[server_instance_name]
      ,[database_name]
      ,[schema_name]
      ,[object_name]
      ,[statement]
      ,[additional_information])
SELECT [event_time]
      ,[sequence_number]
      ,[action_id]
      ,[succeeded]
      ,[permission_bitmask]
      ,[is_column_permission]
      ,[session_id]
      ,[server_principal_id]
      ,[database_principal_id]
      ,[target_server_principal_id]
      ,[target_database_principal_id]
      ,[object_id]
      ,[class_type]
      ,[session_server_principal_name]
      ,[server_principal_name]
      ,[server_principal_sid]
      ,[database_principal_name]
      ,[target_server_principal_name]
      ,[target_server_principal_sid]
      ,[target_database_principal_name]
      ,[server_instance_name]
      ,[database_name]
      ,[schema_name]
      ,[object_name]
      ,[statement]
      ,[additional_information]
  FROM fn_get_audit_file (''' + @AuditFile + ''', default, default)
WHERE statement NOT LIKE ''OPEN SYMMETRIC KEY %DECRYPTION BY CERTIFICATE %''
' + ISNULL('AND [event_time] > ''' + convert(varchar(32), @MaxRecord, 109) + '''','') + '
ORDER BY event_time'

IF @Debug = 0
	EXEC (@SQL)
ELSE
	PRINT @SQL

SELECT @Rowcount = @BatchSize

WHILE @Rowcount = @BatchSize
BEGIN
	SELECT @SQL = 'DELETE TOP (' + CONVERT(varchar(32), @BatchSize) + ')' + CHAR(10) +
	'FROM dbo.' + ISNULL(@LogTable, 'Log_SvrAdt_' + @AuditName) + CHAR(10) +
	'WHERE [event_time] < dateadd(day,-' + convert(varchar(32), @KeepDays, 109) + ',getdate())'
	IF @Debug = 0
	BEGIN
		EXEC (@SQL)
		SELECT @Rowcount = @@rowcount
	END
	ELSE
	BEGIN
		PRINT '--Batches:' + CHAR(10) + @SQL
		SELECT @Rowcount = 0
	END
END

SET NOCOUNT OFF

RETURN 0


GO

/****** Object:  StoredProcedure [dbo].[usp_Audit_Extract_All]    Script Date: 11/21/2018 2:21:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[usp_Audit_Extract_All]
/*********************************************************************************************
PURPOSE:	Purpose of this object is to Extract the audit reports from all audits.
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name			Change Description	
----------			--------------			------------------
01/09/2013			Jared Karney			Original Version
02/10/2014			Jared Karney			Added parameters to work with usp_Extract_Audit
06/30/2014			Jared Karney			Updated to work with standard on 2012.
----------------------------------------------------------------------------------------------
USAGE:	EXEC dbo.[usp_Audit_Extract_All]
**********************************************************************************************/
	@KeepDays int = 180,
	@BatchSize int = 25000,
	@LogTable varchar(128) = NULL,
	@Debug bit = 0

AS

SET NOCOUNT ON

CREATE TABLE #Audits (AuditName varchar(128))

DECLARE @AuditName varchar(128)

IF NOT (@@MICROSOFTVERSION / 0x01000000 > 10 OR (@@MICROSOFTVERSION / 0x01000000 = 10 AND SERVERPROPERTY('EngineEdition') = 3))
BEGIN
	PRINT 'Audit requires Enterprise edition and is only available in 2008 and newer.'
	RETURN -1
END

INSERT INTO #Audits (AuditName)
SELECT sa.name
FROM sys.server_audits sa
JOIN sys.server_audit_specifications sas
  ON sa.audit_guid = sas.audit_guid AND sa.name = sas.name

IF NOT EXISTS (SELECT 1 FROM #Audits)
BEGIN
	PRINT 'No server audits are currently running.'
	RETURN -1
END

SELECT @AuditName = MIN(AuditName) FROM #Audits

WHILE @AuditName IS NOT NULL
BEGIN
	PRINT 'Extracting audit: ' + @AuditName
	EXEC dbo.usp_Audit_Extract
			@AuditName = @AuditName,
			@KeepDays = @KeepDays,
			@BatchSize = @BatchSize,
			@LogTable  = @LogTable,
			@Debug = @Debug
	PRINT 'Done.'
	
	SELECT @AuditName = MIN(AuditName) FROM #Audits WHERE AuditName > @AuditName
END

DROP TABLE #Audits

SET NOCOUNT OFF

RETURN 0



GO

/****** Object:  StoredProcedure [dbo].[usp_Audit_Start]    Script Date: 11/21/2018 2:21:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Audit_Start]
/*********************************************************************************************
PURPOSE:	Purpose of this object is to setup/start an audit.
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name			Change Description	
----------			--------------			------------------
01/09/2013			Jared Karney			Original Version
01/15/2013			Jared Karney			Updated Specification build to be more efficient.
06/30/2014			Jared Karney			Updated to work with standard on 2012.
06/26/2015			Jared Karney			Updated name to sup_Audit_Start from usp_Start_Audit
----------------------------------------------------------------------------------------------
USAGE:

EXEC dbo.usp_Start_Audit
	@AuditName = 'Object_Change',
	@Specifications = 'DATABASE_CHANGE_GROUP,DATABASE_OBJECT_CHANGE_GROUP,SCHEMA_OBJECT_CHANGE_GROUP,SERVER_OBJECT_CHANGE_GROUP'

**********************************************************************************************/
	@AuditName varchar(128),
	@Specifications varchar(512),
	@MaxFileSize int = 200,
	@MaxRolloverFiles int = 5,
	@Debug bit = 0,
	@Path varchar(512) = NULL

AS

SET NOCOUNT ON

DECLARE @xpcheck INT

--SELECT 	@AuditName = 'Object_Change',
--	@Specifications = 'DATABASE_CHANGE_GROUP,DATABASE_OBJECT_CHANGE_GROUP,SCHEMA_OBJECT_CHANGE_GROUP,SERVER_OBJECT_CHANGE_GROUP'

IF NOT (@@MICROSOFTVERSION / 0x01000000 > 10 OR (@@MICROSOFTVERSION / 0x01000000 = 10 AND SERVERPROPERTY('EngineEdition') = 3))
BEGIN
	RAISERROR ('Audit requires Enterprise edition and is only available in 2008 and newer.', 16,10)
	RETURN -1
END

CREATE TABLE #CMD (data varchar(128))

DECLARE @SQL varchar(4096), @SQL_Specifications varchar(1024), @Error varchar(1024)

SELECT @Path = ISNULL(@Path, replace(convert(varchar(128),SERVERPROPERTY('ErrorLogFileName')), 'LOG\ERRORLOG', 'Audit'))

SELECT @SQL = 'IF NOT EXIST "' + @Path + '" mkdir "' + @Path + '"'

IF @Debug = 1
	PRINT 'EXEC xp_cmdshell ''' + @SQL + ''''
ELSE
	BEGIN
		EXEC @xpcheck = dbo.checkenable_xp_cmdshell;
		INSERT INTO #CMD
		EXEC xp_cmdshell @SQL
		EXEC dbo.checkdisable_xp_cmdshell @xpcheck;
	END

DELETE FROM #CMD WHERE data IS NULL
IF EXISTS (SELECT 1 FROM #CMD)
BEGIN
	SELECT @Error = 'The following error occured while creating the audit directory:' + CHAR(10)
	SELECT @Error = @Error + data FROM #CMD
	RAISERROR (@Error, 16,10)
	RETURN -1
END

SELECT @SQL = 'USE [master]' + CHAR(10) +
'CREATE SERVER AUDIT [' + @AuditName + ']' + CHAR(10) +
'TO FILE' + CHAR(10) +
'(	FILEPATH = N''' + @Path + '''' + CHAR(10) +
'	,MAXSIZE = ' + CONVERT(varchar(32), @MaxFileSize) + ' MB' + CHAR(10) +
'	,MAX_ROLLOVER_FILES = ' + CONVERT(varchar(32), @MaxRolloverFiles) + CHAR(10) +
'	,RESERVE_DISK_SPACE = OFF' + CHAR(10) +
')' + CHAR(10) +
'WITH' + CHAR(10) +
'(	QUEUE_DELAY = 1000' + CHAR(10) +
'	,ON_FAILURE = CONTINUE' + CHAR(10) +
')' + CHAR(10) +
'ALTER SERVER AUDIT [' + @AuditName + '] WITH (STATE = ON)'

IF @Debug = 1
	PRINT @SQL
ELSE
	EXEC (@SQL)

SELECT @SQL = 'USE [master]' + CHAR(10) +
'CREATE SERVER AUDIT SPECIFICATION [' + @AuditName + ']' + CHAR(10) +
'FOR SERVER AUDIT [' + @AuditName + ']'
SELECT @SQL_Specifications = ISNULL(@SQL_Specifications + ',', '') + CHAR(10) + 'ADD (' + VALUE + ')'
FROM dbo.uf_ListToTable (@Specifications, ',')
SELECT @SQL = @SQL + @SQL_Specifications + CHAR(10) +
'WITH (STATE = ON)'

IF @Debug = 1
	PRINT @SQL
ELSE
	EXEC (@SQL)

DROP TABLE #CMD

SET NOCOUNT OFF

RETURN 0



GO

/****** Object:  StoredProcedure [dbo].[usp_Audit_Stop]    Script Date: 11/21/2018 2:21:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[usp_Audit_Stop]
/*********************************************************************************************
PURPOSE:	Purpose of this object is to stop/delete an audit.
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name			Change Description	
----------			--------------			------------------
01/09/2013			Jared Karney			Original Version
06/30/2014			Jared Karney			Updated to work with standard on 2012.
----------------------------------------------------------------------------------------------
USAGE:	EXEC dbo.usp_Stop_Audit @AuditName = 'Object_Change'
**********************************************************************************************/
	@AuditName varchar(128),
	@Debug bit = 0,
	@RemoveFiles bit = 0

AS

SET NOCOUNT ON

DECLARE @xpcheck INT

--SELECT 	@AuditName = 'Object_Change',
--	@Specifications = 'DATABASE_CHANGE_GROUP,DATABASE_OBJECT_CHANGE_GROUP,SCHEMA_OBJECT_CHANGE_GROUP,SERVER_OBJECT_CHANGE_GROUP'

IF NOT (@@MICROSOFTVERSION / 0x01000000 > 10 OR (@@MICROSOFTVERSION / 0x01000000 = 10 AND SERVERPROPERTY('EngineEdition') = 3))
BEGIN
	RAISERROR ('Audit requires Enterprise edition and is only available in 2008 and newer.', 16,10)
	RETURN -1
END

IF NOT EXISTS (SELECT 1 FROM sys.server_audits sa JOIN sys.server_audit_specifications sas ON sa.audit_guid = sas.audit_guid WHERE sa.name = @AuditName AND sas.name = @AuditName)
BEGIN
	RAISERROR ('The requested audit is not running.', 16,10)
	RETURN -1
END

CREATE TABLE #CMD (data varchar(128))

DECLARE @cmd varchar(512), @SQL varchar(4096), @Error varchar(1024)

SELECT @cmd = 'DEL "' + sfa.log_file_path + sa.name + '_' + convert(varchar (128), sa.audit_guid) + '*.sqlaudit"'
FROM sys.server_audits sa
JOIN sys.server_file_audits sfa
	ON sa.audit_id = sfa.audit_id
WHERE sa.name = @AuditName

SELECT @SQL = 'USE [master]' + CHAR(10) +
'ALTER SERVER AUDIT SPECIFICATION [' + @AuditName + ']' + CHAR(10) +
'WITH (STATE = OFF)' + CHAR(10) +
'DROP SERVER AUDIT SPECIFICATION [' + @AuditName + ']' + CHAR(10) + CHAR(10) +
'USE [master]' + CHAR(10) +
'ALTER SERVER AUDIT [' + @AuditName + ']' + CHAR(10) +
'WITH (STATE = OFF)' + CHAR(10) +
'DROP SERVER AUDIT [' + @AuditName + ']'

IF @Debug = 1
	PRINT @SQL
ELSE
	EXEC (@SQL)

IF @RemoveFiles = 1
BEGIN
	IF @Debug = 1
		PRINT 'EXEC xp_cmdshell ''' + @cmd + ''''
	ELSE
	BEGIN
		EXEC @xpcheck = dbo.checkenable_xp_cmdshell;
		INSERT INTO #CMD
		EXEC xp_cmdshell @cmd
		EXEC dbo.checkdisable_xp_cmdshell @xpcheck;

		DELETE FROM #CMD WHERE data IS NULL
		IF EXISTS (SELECT 1 FROM #CMD)
		BEGIN
			SELECT @Error = 'The following error occured while removing the old audit files:' + CHAR(10)
			SELECT @Error = @Error + data FROM #CMD
			RAISERROR (@Error, 16,10)
			RETURN -1
		END
	END
END

DROP TABLE #CMD

SET NOCOUNT OFF

RETURN 0




GO

/****** Object:  StoredProcedure [dbo].[usp_Audit_View]    Script Date: 11/21/2018 2:21:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[usp_Audit_View]
/*********************************************************************************************
PURPOSE:	Purpose of this object is to view the audit reports.
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name			Change Description	
----------			--------------			------------------
01/09/2013			Jared Karney			Original Version
06/06/2013			Jared Karney			Update to add @Database, @Login, @Object
07/15/2013			Jared Karney			Update to add sorting by sequence.
08/06/2013			Jared Karney			Update to convert time from UTC.
06/30/2014			Jared Karney			Updated to work with standard on 2012.
----------------------------------------------------------------------------------------------
USAGE:	EXEC dbo.[usp_Audit_View] @AuditName = 'Object_Change'
**********************************************************************************************/
	@AuditName VARCHAR(128),
	@LogTable VARCHAR(128) = NULL,
	@Debug BIT = 0,
	@Database VARCHAR(128) = NULL,
	@Login VARCHAR(128) = NULL,
	@Object VARCHAR(128) = NULL

AS

SET NOCOUNT ON

--SELECT @AuditName = 'Object_Change'
--SELECT @AuditName = 'Security_Change'

DECLARE @AuditFile varchar(512), @SQL nvarchar(4000), @MaxRecord datetime

IF NOT (@@MICROSOFTVERSION / 0x01000000 > 10 OR (@@MICROSOFTVERSION / 0x01000000 = 10 AND SERVERPROPERTY('EngineEdition') = 3))
BEGIN
	RAISERROR ('Audit requires Enterprise edition and is only available in 2008 and newer.', 1,1)
	RETURN -1
END
IF NOT EXISTS (SELECT 1 FROM sys.server_audits sa JOIN sys.server_audit_specifications sas ON sa.audit_guid = sas.audit_guid WHERE sa.name = @AuditName AND sas.name = @AuditName)
BEGIN
	RAISERROR ('The requested audit is not running.', 1,1)
	RETURN -1
END

SELECT @AuditFile = sfa.log_file_path + sa.name + '_' + convert(varchar (128), sa.audit_guid) + '*.sqlaudit'
FROM sys.server_audits sa
JOIN sys.server_file_audits sfa
  ON sa.audit_id = sfa.audit_id
WHERE sa.name = @AuditName

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = ISNULL(@LogTable, 'Log_SvrAdt_' + @AuditName))
BEGIN
	SELECT @SQL = 'SELECT @MaxRecord = max([event_time]) FROM dbo.' + ISNULL(@LogTable, 'Log_SvrAdt_' + @AuditName)
	EXEC sp_executeSQL @SQL, N'@MaxRecord datetime OUTPUT', @MaxRecord = @MaxRecord OUTPUT

	SELECT @SQL = 'SELECT DATEADD(HOUR, DATEDIFF(HOUR, SYSUTCDATETIME(), SYSDATETIME()), [event_time]) AS [event_time]
      ,[sequence_number]
      ,[action_id]
      ,[succeeded]
      ,[permission_bitmask]
      ,[is_column_permission]
      ,[session_id]
      ,[server_principal_id]
      ,[database_principal_id]
      ,[target_server_principal_id]
      ,[target_database_principal_id]
      ,[object_id]
      ,[class_type]
      ,[session_server_principal_name]
      ,[server_principal_name]
      ,[server_principal_sid]
      ,[database_principal_name]
      ,[target_server_principal_name]
      ,[target_server_principal_sid]
      ,[target_database_principal_name]
      ,[server_instance_name]
      ,[database_name]
      ,[schema_name]
      ,[object_name]
      ,[statement]
      ,[additional_information]
  FROM dbo.' + ISNULL(@LogTable, 'Log_SvrAdt_' + @AuditName) + '
 WHERE 1=1
   ' + ISNULL('AND [database_name] = ''' + @Database + '''', '') + '
   ' + ISNULL('AND ([target_server_principal_name] = ''' + @Login + ''' OR [target_database_principal_name] = ''' + @Login + ''' OR [object_name] = ''' + @Login + ''')', '') + '
   ' + ISNULL('AND [object_name] = ''' + @Object + '''', '') + '
  UNION ALL'
END
ELSE
BEGIN
	SELECT @MaxRecord = 0
	SELECT @SQL = ''
END

SELECT @SQL = @SQL + CHAR(10) +
'  SELECT DATEADD(HOUR, DATEDIFF(HOUR, SYSUTCDATETIME(), SYSDATETIME()), [event_time]) AS [event_time]
      ,[sequence_number]
      ,[action_id]
      ,[succeeded]
      ,[permission_bitmask]
      ,[is_column_permission]
      ,[session_id]
      ,[server_principal_id]
      ,[database_principal_id]
      ,[target_server_principal_id]
      ,[target_database_principal_id]
      ,[object_id]
      ,[class_type]
      ,[session_server_principal_name]
      ,[server_principal_name]
      ,[server_principal_sid]
      ,[database_principal_name]
      ,[target_server_principal_name]
      ,[target_server_principal_sid]
      ,[target_database_principal_name]
      ,[server_instance_name]
      ,[database_name]
      ,[schema_name]
      ,[object_name]
      ,[statement]
      ,[additional_information]
  FROM fn_get_audit_file (''' + @AuditFile + ''', default, default)
 WHERE 1=1 
   ' + ISNULL('AND [event_time] > ''' + CONVERT(VARCHAR(32), @MaxRecord, 109) + '''','') + '
   ' + ISNULL('AND [database_name] = ''' + @Database + '''', '') + '
   ' + ISNULL('AND ([target_server_principal_name] = ''' + @Login + ''' OR [target_database_principal_name] = ''' + @Login + ''' OR [object_name] = ''' + @Login + ''')', '') + '
   ' + ISNULL('AND [object_name] = ''' + @Object + '''', '') + '
ORDER BY [event_time], [sequence_number]'

PRINT @SQL
IF @Debug = 0
	EXEC (@SQL)

SET NOCOUNT OFF

RETURN 0



GO


