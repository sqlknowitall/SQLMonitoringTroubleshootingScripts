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

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ClonePermissions')
    CREATE DATABASE ClonePermissions;
GO

USE ClonePermissions;

CREATE TABLE [dbo].[Audit_Roles]
(
    [ID] [INT] IDENTITY(1, 1) NOT NULL,
    [DatabaseName] [VARCHAR](128) NULL,
    [SQL_Login] [VARCHAR](128) NULL,
    [SQL_Login_type] [VARCHAR](1) NULL,
    [SQL_Login_type_desc] [VARCHAR](32) NULL,
    [Login_disabled] [BIT] NULL,
    [DB_Login] [VARCHAR](128) NULL,
    [DB_Login_type] [VARCHAR](1) NULL,
    [DB_Login_type_desc] [VARCHAR](32) NULL,
    [Role_Name] [VARCHAR](64) NOT NULL,
    [default_schema_name] [VARCHAR](64) NULL,
    [action] [VARCHAR](128) NOT NULL,
    [Discovered_Date] [DATETIME] NOT NULL,
    [Date_Changed] [DATETIME] NOT NULL,
    CONSTRAINT [PK_Role_Audit]
        PRIMARY KEY CLUSTERED ([ID] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90
             ) ON [PRIMARY]
) ON [PRIMARY];

CREATE TABLE [dbo].[Exceptions_Audit_Roles]
(
    [SQL_Login] [VARCHAR](128) NULL,
    [DB_Login] [VARCHAR](128) NULL,
    [DatabaseName] [VARCHAR](128) NULL,
    [Role_Name] [VARCHAR](64) NULL
) ON [PRIMARY];

CREATE TABLE [dbo].[Inv_Roles]
(
    [ID] [INT] IDENTITY(1, 1) NOT NULL,
    [DatabaseName] [VARCHAR](128) NULL,
    [SQL_Login] [VARCHAR](128) NULL,
    [SQL_Login_type] [VARCHAR](1) NULL,
    [SQL_Login_type_desc] [VARCHAR](32) NULL,
    [Login_disabled] [BIT] NULL,
    [DB_Login] [VARCHAR](128) NULL,
    [DB_Login_type] [VARCHAR](1) NULL,
    [DB_Login_type_desc] [VARCHAR](32) NULL,
    [Role_Name] [VARCHAR](64) NOT NULL,
    [default_schema_name] [VARCHAR](64) NULL,
    [Discovered_Date] [DATETIME] NOT NULL,
    CONSTRAINT [PK_Inv_Roles]
        PRIMARY KEY CLUSTERED ([ID] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90
             ) ON [PRIMARY]
) ON [PRIMARY];

CREATE TABLE [dbo].[Audit_Permissions]
(
    [ID] [INT] IDENTITY(1, 1) NOT NULL,
    [DatabaseName] [VARCHAR](128) NULL,
    [class] [TINYINT] NOT NULL,
    [class_desc] [NVARCHAR](60) NOT NULL,
    [major_id] [INT] NOT NULL,
    [schema_id] [INT] NULL,
    [schema_name] [VARCHAR](128) NULL,
    [object_name] [VARCHAR](128) NULL,
    [minor_id] [INT] NOT NULL,
    [column_id] [INT] NULL,
    [column_name] [sysname] NULL,
    [grantee_principal_id] [INT] NOT NULL,
    [grantee_name] [VARCHAR](128) NOT NULL,
    [grantee_sid] [VARBINARY](85) NULL,
    [grantor_principal_id] [INT] NOT NULL,
    [grantor_name] [VARCHAR](128) NOT NULL,
    [grantor_sid] [VARBINARY](85) NOT NULL,
    [type] [CHAR](4) NOT NULL,
    [permission_name] [NVARCHAR](128) NOT NULL,
    [state] [CHAR](1) NOT NULL,
    [state_desc] [NVARCHAR](60) NOT NULL,
    [action] [VARCHAR](128) NOT NULL,
    [Discovered_Date] [DATETIME] NOT NULL,
    [Date_Changed] [DATETIME] NOT NULL,
    CONSTRAINT [PK_Permissions_Audit_ID]
        PRIMARY KEY CLUSTERED ([ID] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90
             ) ON [PRIMARY]
) ON [PRIMARY];

CREATE TABLE [dbo].[Inv_Permissions]
(
    [ID] [INT] IDENTITY(1, 1) NOT NULL,
    [DatabaseName] [VARCHAR](128) NULL,
    [class] [TINYINT] NOT NULL,
    [class_desc] [NVARCHAR](60) NOT NULL,
    [major_id] [INT] NOT NULL,
    [schema_id] [INT] NULL,
    [schema_name] [VARCHAR](128) NULL,
    [object_name] [VARCHAR](128) NULL,
    [minor_id] [INT] NOT NULL,
    [column_id] [INT] NULL,
    [column_name] [sysname] NULL,
    [grantee_principal_id] [INT] NOT NULL,
    [grantee_name] [VARCHAR](128) NOT NULL,
    [grantee_sid] [VARBINARY](85) NULL,
    [grantor_principal_id] [INT] NOT NULL,
    [grantor_name] [VARCHAR](128) NOT NULL,
    [grantor_sid] [VARBINARY](85) NOT NULL,
    [type] [CHAR](4) NOT NULL,
    [permission_name] [NVARCHAR](128) NOT NULL,
    [state] [CHAR](1) NOT NULL,
    [state_desc] [NVARCHAR](60) NOT NULL,
    [Discovered_Date] [DATETIME] NOT NULL,
    CONSTRAINT [PK_Inv_Permissions_ID]
        PRIMARY KEY CLUSTERED ([ID] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90
             ) ON [PRIMARY]
) ON [PRIMARY];

CREATE TABLE [dbo].[Audit_Clone_Account]
(
    [Audit_ID] [INT] IDENTITY(1, 1) NOT NULL,
    [Run_Date] [DATETIME] NOT NULL,
    [AuditUser] [VARCHAR](128) NOT NULL,
    [Old_Login] [VARCHAR](128) NOT NULL,
    [New_Login] [VARCHAR](128) NOT NULL,
    [Results] [VARCHAR](256) NOT NULL,
    [Error] [VARCHAR](4000) NULL,
    CONSTRAINT [PK_Audit_Clone_Account]
        PRIMARY KEY CLUSTERED ([Audit_ID] ASC)
        WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
              ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90
             ) ON [PRIMARY]
) ON [PRIMARY];


GO

CREATE PROCEDURE [dbo].[usp_Role_Audit]
    /*********************************************************************************************
PURPOSE:	Purpose of this object is to audit changes in role memberships.
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date					Developer Name					Change Description	
----------				--------------					------------------
2018-05-11				Jared Karney					Original adapted from James Rzepka
USAGE:		EXEC dbo.usp_Role_Audit

This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
**********************************************************************************************/

    @Silent BIT = 0
AS
SET NOCOUNT ON;

DECLARE @SQL NVARCHAR(4000),
        @DBName VARCHAR(128),
        @NumDBs INT,
        @DBNum INT,
        @Date DATETIME;

SET @Date = GETDATE();

CREATE TABLE #security
(
    DatabaseName VARCHAR(128),
    SQL_Login VARCHAR(128),
    SQL_Login_type VARCHAR(1),
    SQL_Login_type_desc VARCHAR(32),
    Login_disabled BIT,
    DB_Login VARCHAR(128),
    DB_Login_type VARCHAR(1),
    DB_Login_type_desc VARCHAR(32),
    Role_Name VARCHAR(64),
    default_schema_name VARCHAR(64)
);

CREATE TABLE #DatabasesToProcess
(
    ID INT IDENTITY,
    DBName VARCHAR(128)
);
CREATE TABLE #Groups
(
    ID INT IDENTITY,
    GroupName VARCHAR(256),
    Role_Name VARCHAR(64),
    Login_disabled BIT,
    DB_Login VARCHAR(64),
    DatabaseName VARCHAR(128)
);
CREATE TABLE #groupmembers
(
    [account name] sysname,
    [type] CHAR(8),
    [privilege] CHAR(9),
    [masped login name] sysname,
    [permission path] sysname
);

INSERT INTO #DatabasesToProcess
SELECT name
FROM master.sys.databases
WHERE state = 0;

IF @@MICROSOFTVERSION / 0x01000000 >= 11
    EXEC ('DELETE FROM #DatabasesToProcess
WHERE DBName IN (
SELECT db.name
FROM sys.databases db
JOIN sys.dm_hadr_database_replica_states rs
on db.database_id = rs.database_id
JOIN sys.availability_groups ag
on ag.group_id = rs.group_id
LEFT JOIN sys.dm_hadr_availability_group_states ags
ON ag.group_id = ags.group_id
AND ags.primary_replica = serverproperty(N''ServerName'')
WHERE ags.primary_replica IS NULL
)'       );

SELECT @DBNum = MIN(ID),
       @NumDBs = MAX(ID)
FROM #DatabasesToProcess;
WHILE @DBNum <= @NumDBs
BEGIN
    SELECT @DBName = DBName
    FROM #DatabasesToProcess
    WHERE ID = @DBNum;
    --	print 'Processing Database: ' + @DBName
    SET @SQL
        = 'select ''' + QUOTENAME(@DBName)
          + ''', isnull(t4.name,'' '') COLLATE DATABASE_DEFAULT as SQL_Login, 
	isnull(t4.type,'' '') COLLATE DATABASE_DEFAULT as SQL_Login_type,
	isnull(t4.type_desc,'' '') COLLATE DATABASE_DEFAULT as SQL_Login_type_desc, t4.is_disabled as Login_disabled, 
	t3.name COLLATE DATABASE_DEFAULT as DB_Login,
	isnull(t3.type,'' '') COLLATE DATABASE_DEFAULT as SQL_Login_type,
	isnull(t3.type_desc,'' '') COLLATE DATABASE_DEFAULT as SQL_Login_type_desc, 
	t2.name as Role_Name, t3.default_schema_name
	from '     + QUOTENAME(@DBName) + '.sys.database_role_members t1 WITH (NOLOCK)
	left join ' + QUOTENAME(@DBName)
          + '.sys.database_principals t2 WITH (NOLOCK) on t2.principal_id = t1.role_principal_id
	left join ' + QUOTENAME(@DBName)
          + '.sys.database_principals t3 WITH (NOLOCK) on t1.member_principal_id = t3.principal_id
	left join master.sys.server_principals t4 WITH (NOLOCK) on t4.sid = t3.sid
	--where t3.type in (''s'',''g'',''u'',''c'',''r'') 
	union all
	select ''' + QUOTENAME(@DBName)
          + ''', t2.name COLLATE DATABASE_DEFAULT, 
	isnull(t2.type,'' '') COLLATE DATABASE_DEFAULT as SQL_Login_type,
	isnull(t2.type_desc,'' '') COLLATE DATABASE_DEFAULT as SQL_Login_type_desc, t2.is_disabled as Login_disabled, 
	t1.name COLLATE DATABASE_DEFAULT,
	isnull(t1.type,'' '') COLLATE DATABASE_DEFAULT as SQL_Login_type,
	isnull(t1.type_desc,'' '') COLLATE DATABASE_DEFAULT as SQL_Login_type_desc, 
	''public'',t1.default_schema_name
	from '     + QUOTENAME(@DBName)
          + '.sys.database_principals t1 WITH (NOLOCK)
	left join master.sys.server_principals t2 WITH (NOLOCK) on t1.sid = t2.sid
	where t1.type in (''s'',''g'',''u'',''c'')
	';
    --	print @SQL
    INSERT INTO #security
    EXEC (@SQL);

    SELECT @DBNum = MIN(ID)
    FROM #DatabasesToProcess
    WHERE ID > @DBNum;
END;
INSERT INTO #security
SELECT '',
       t3.name,
       t3.type,
       t3.type_desc,
       t3.is_disabled,
       '',
       '',
       '',
       t2.name,
       NULL
FROM master.sys.server_role_members t1 WITH (NOLOCK)
    LEFT JOIN master.sys.server_principals t2 WITH (NOLOCK)
        ON t1.role_principal_id = t2.principal_id
    LEFT JOIN master.sys.server_principals t3 WITH (NOLOCK)
        ON t1.member_principal_id = t3.principal_id
WHERE t2.type IN ( 'r' )
      AND t3.type IN ( 's', 'g', 'u', 'c' )
UNION ALL
SELECT DISTINCT
    '',
    t1.name,
    t1.type,
    t1.type_desc,
    t1.is_disabled,
    '',
    '',
    '',
    'public',
    NULL
FROM master.sys.server_principals t1 WITH (NOLOCK)
WHERE t1.type IN ( 's', 'g', 'u', 'c' );

IF EXISTS (SELECT 1 FROM #security WHERE SQL_Login LIKE 'BUILTIN\%')
BEGIN
    --	print 'Working on BUILTIN\ accounts'
    DECLARE @Group VARCHAR(256),
            @GroupNum INT,
            @NumGroups INT;
    INSERT INTO #Groups
    SELECT DISTINCT
        SQL_Login,
        Role_Name,
        Login_disabled,
        DB_Login,
        DatabaseName
    FROM #security
    WHERE SUBSTRING(SQL_Login, 1, 8) = 'BUILTIN\';
    SELECT @NumGroups = COUNT(*)
    FROM #Groups;
    SELECT @GroupNum = 1;
    WHILE @GroupNum <= @NumGroups
    BEGIN
        SELECT @Group = GroupName
        FROM #Groups
        WHERE ID = @GroupNum;
        DECLARE @script VARCHAR(500);
        SELECT @script = 'insert into #groupmembers
		exec master.dbo.xp_logininfo ''' + @Group + ''', ''members''';
        --		print @script
        EXEC (@script);
        INSERT INTO #security
        SELECT gp.DatabaseName,
               CASE
                   WHEN [account name] LIKE CONVERT(VARCHAR(64), SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) + '\%' THEN
                       REPLACE(
                                  [account name],
                                  CONVERT(VARCHAR(64), SERVERPROPERTY('ComputerNamePhysicalNetBIOS')),
                                  CONVERT(VARCHAR(64), SERVERPROPERTY('MachineName'))
                              )
                   ELSE
                       [account name]
               END,
               CASE type
                   WHEN 'user' THEN
                       'U'
                   WHEN 'group' THEN
                       'G'
               END,
               CASE type
                   WHEN 'user' THEN
                       'WINDOWS_LOGIN'
                   WHEN 'group' THEN
                       'WINDOWS_GROUP'
               END,
               gp.Login_disabled,
               gp.DB_Login,
               ISNULL(sec.DB_Login_type, ''),
               ISNULL(sec.DB_Login_type_desc, ''),
               gp.Role_Name,
               NULL
        FROM #groupmembers gm
            LEFT JOIN #Groups gp
                ON gp.ID = @GroupNum
            LEFT JOIN #security sec
                ON gm.[account name] = sec.[SQL_Login]
                   AND sec.Role_Name = gp.Role_Name
                   AND sec.DatabaseName = gp.DatabaseName
        WHERE sec.[SQL_Login] IS NULL;
        TRUNCATE TABLE #groupmembers;
        SET @GroupNum = @GroupNum + 1;
    END;
    TRUNCATE TABLE #Groups;
END;

INSERT INTO dbo.Audit_Roles
SELECT sec.DatabaseName,
       sec.SQL_Login,
       sec.SQL_Login_type,
       sec.SQL_Login_type_desc,
       sec.Login_disabled,
       sec.DB_Login,
       sec.DB_Login_type,
       sec.DB_Login_type_desc,
       sec.Role_Name,
       sec.default_schema_name,
       'ADD',
       @Date,
       @Date
FROM #security sec
    LEFT JOIN dbo.Inv_Roles ar
        ON sec.DatabaseName = ar.DatabaseName
           AND ISNULL(sec.SQL_Login, '') = ISNULL(ar.SQL_Login, '')
           AND sec.SQL_Login_type = ar.SQL_Login_type
           AND ISNULL(sec.Login_disabled, '') = ISNULL(ar.Login_disabled, '')
           AND sec.DB_Login = ar.DB_Login
           AND sec.DB_Login_type = ar.DB_Login_type
           AND sec.Role_Name = ar.Role_Name
           AND ISNULL(sec.default_schema_name, '') = ISNULL(ar.default_schema_name, '')
WHERE ar.Role_Name IS NULL;

INSERT INTO dbo.Inv_Roles
SELECT sec.DatabaseName,
       sec.SQL_Login,
       sec.SQL_Login_type,
       sec.SQL_Login_type_desc,
       sec.Login_disabled,
       sec.DB_Login,
       sec.DB_Login_type,
       sec.DB_Login_type_desc,
       sec.Role_Name,
       sec.default_schema_name,
       @Date
FROM #security sec
    LEFT JOIN dbo.Inv_Roles ar
        ON sec.DatabaseName = ar.DatabaseName
           AND ISNULL(sec.SQL_Login, '') = ISNULL(ar.SQL_Login, '')
           AND sec.SQL_Login_type = ar.SQL_Login_type
           AND ISNULL(sec.Login_disabled, '') = ISNULL(ar.Login_disabled, '')
           AND sec.DB_Login = ar.DB_Login
           AND sec.DB_Login_type = ar.DB_Login_type
           AND sec.Role_Name = ar.Role_Name
           AND ISNULL(sec.default_schema_name, '') = ISNULL(ar.default_schema_name, '')
WHERE ar.Role_Name IS NULL;

INSERT INTO dbo.Audit_Roles
SELECT ar.DatabaseName,
       ar.SQL_Login,
       ar.SQL_Login_type,
       ar.SQL_Login_type_desc,
       ar.Login_disabled,
       ar.DB_Login,
       ar.DB_Login_type,
       ar.DB_Login_type_desc,
       ar.Role_Name,
       ar.default_schema_name,
       'REMOVE',
       ar.Discovered_Date,
       @Date
FROM #security sec
    RIGHT JOIN dbo.Inv_Roles ar
        ON sec.DatabaseName = ar.DatabaseName
           AND ISNULL(sec.SQL_Login, '') = ISNULL(ar.SQL_Login, '')
           AND sec.SQL_Login_type = ar.SQL_Login_type
           AND ISNULL(sec.Login_disabled, '') = ISNULL(ar.Login_disabled, '')
           AND sec.DB_Login = ar.DB_Login
           AND sec.DB_Login_type = ar.DB_Login_type
           AND sec.Role_Name = ar.Role_Name
           AND ISNULL(sec.default_schema_name, '') = ISNULL(ar.default_schema_name, '')
WHERE sec.Role_Name IS NULL;

DELETE FROM dbo.Inv_Roles
FROM dbo.Inv_Roles ar
    LEFT JOIN #security sec
        ON sec.DatabaseName = ar.DatabaseName
           AND ISNULL(sec.SQL_Login, '') = ISNULL(ar.SQL_Login, '')
           AND sec.SQL_Login_type = ar.SQL_Login_type
           AND ISNULL(sec.Login_disabled, '') = ISNULL(ar.Login_disabled, '')
           AND sec.DB_Login = ar.DB_Login
           AND sec.DB_Login_type = ar.DB_Login_type
           AND sec.Role_Name = ar.Role_Name
           AND ISNULL(sec.default_schema_name, '') = ISNULL(ar.default_schema_name, '')
WHERE sec.Role_Name IS NULL;

DROP TABLE #security;
DROP TABLE #groupmembers;
DROP TABLE #Groups;
DROP TABLE #DatabasesToProcess;

IF @Silent = 0
    SELECT [DatabaseName],
           [SQL_Login],
           [SQL_Login_type],
           [SQL_Login_type_desc],
           [Login_disabled],
           [DB_Login],
           [DB_Login_type],
           [DB_Login_type_desc],
           [Role_Name],
           [default_schema_name],
           [action],
           [Discovered_Date],
           [Date_Changed]
    FROM dbo.Audit_Roles
    WHERE [Date_Changed] = @Date;

GO


CREATE PROCEDURE [dbo].[usp_Permissions_Audit]
    /*********************************************************************************************
PURPOSE:	Purpose of this object is to audit changes in permissions.
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date			Developer Name			Change Description	
----------		--------------			------------------
2018-05-11		Jared Karney			Original adapted from James Rzepka
----------------------------------------------------------------------------------------------
USAGE:		EXEC dbo.usp_Permissions_Audit

This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
**********************************************************************************************/

    @Silent BIT = 0
AS
SET NOCOUNT ON;

DECLARE @SQL NVARCHAR(4000),
        @DBName VARCHAR(128),
        @DBNum INT,
        @NumDBs INT,
        @Date DATETIME;

SET @Date = GETDATE();

CREATE TABLE #permissions
(
    DatabaseName VARCHAR(128),
    class TINYINT,
    class_desc NVARCHAR(60),
    major_id INT,
    schema_id INT,
    schema_name VARCHAR(128),
    object_name VARCHAR(128),
    minor_id INT,
    column_id INT,
    column_name VARCHAR(128),
    grantee_principal_id INT,
    grantee_name VARCHAR(128),
    grantee_sid VARBINARY(85),
    grantor_principal_id INT,
    grantor_name VARCHAR(128),
    grantor_sid VARBINARY(85),
    type CHAR(4),
    permission_name NVARCHAR(128),
    state CHAR(1),
    state_desc NVARCHAR(60)
);
CREATE TABLE #DatabasesToProcess
(
    ID INT IDENTITY,
    DBName VARCHAR(128)
);

INSERT INTO #DatabasesToProcess
SELECT name
FROM master.sys.databases
WHERE state = 0;

IF @@MICROSOFTVERSION / 0x01000000 >= 11
    EXEC ('DELETE FROM #DatabasesToProcess
WHERE DBName IN (
SELECT db.name
FROM sys.databases db
JOIN sys.dm_hadr_database_replica_states rs
on db.database_id = rs.database_id
JOIN sys.availability_groups ag
on ag.group_id = rs.group_id
LEFT JOIN sys.dm_hadr_availability_group_states ags
ON ag.group_id = ags.group_id
AND ags.primary_replica = serverproperty(N''ServerName'')
WHERE ags.primary_replica IS NULL
)'       );

SELECT @DBNum = MIN(ID),
       @NumDBs = MAX(ID)
FROM #DatabasesToProcess;

WHILE @DBNum <= @NumDBs
BEGIN
    SELECT @DBName =
    (
        SELECT DBName FROM #DatabasesToProcess WHERE ID = @DBNum
    );
    --	print 'Processing Database: ' + @DBName
    SET @SQL
        = 'USE ' + QUOTENAME(@DBName) + '
		SELECT 
			 ''' + @DBName
          + '''
			,dataperm.class
			,dataperm.class_desc
			,dataperm.major_id
			,sch.schema_id
			,sch.name
			,CASE dataperm.Class
				when 0 then ''' + @DBName
          + ''' 
				when 1 then obj.name--OBJECT_NAME(dataperm.major_id)
				when 3 then ss.name
				when 4 then dprin.name
				when 6 then st.name
				when 10 then xsc.name
				when 15 then mt.name
				when 16 then sc.name
				when 17 then svc.name COLLATE DATABASE_DEFAULT
				when 18 then rsb.name
				when 19 then rte.name
				when 23 then ftc.name
				when 24 then sk.name
				when 25 then crt.name
				when 26 then ask.name end
				--else OBJECT_NAME(dataperm.major_id) end
			,dataperm.minor_id
			,col.column_id
			,col.name
			,dataperm.grantee_principal_id
			,grantee_dp.name
			,grantee_dp.sid
			,dataperm.grantor_principal_id
			,grantor_dp.name
			,grantor_dp.sid
			,dataperm.type
			,dataperm.permission_name
			,dataperm.state
			,dataperm.state_desc
		FROM sys.database_permissions dataperm WITH (NOLOCK)
		LEFT JOIN sys.all_objects obj WITH (NOLOCK) ON dataperm.major_id = obj.object_id and dataperm.class = 1
		LEFT JOIN sys.schemas sch WITH (NOLOCK) ON obj.schema_id = sch.schema_id
		LEFT JOIN sys.columns col WITH (NOLOCK) ON col.column_id = dataperm.minor_id AND col.object_id = dataperm.major_id
		LEFT JOIN sys.schemas ss WITH (NOLOCK) ON ss.schema_id = dataperm.major_id
		LEFT JOIN sys.database_principals dprin WITH (NOLOCK) ON dprin.principal_id = dataperm.major_id
		LEFT JOIN sys.types st WITH (NOLOCK) ON st.user_type_id = dataperm.major_id
		LEFT JOIN sys.xml_schema_collections xsc WITH (NOLOCK) ON xsc.xml_collection_id = dataperm.major_id
		LEFT JOIN sys.services svc WITH (NOLOCK) ON svc.service_id = dataperm.major_id
		LEFT JOIN sys.service_message_types mt WITH (NOLOCK) ON mt.message_type_id = dataperm.major_id
		LEFT JOIN sys.service_contracts sc WITH (NOLOCK) ON sc.service_contract_id = dataperm.major_id
		LEFT JOIN sys.remote_service_bindings rsb WITH (NOLOCK) ON rsb.remote_service_binding_id = dataperm.major_id
		LEFT JOIN sys.routes rte WITH (NOLOCK) ON rte.route_id = dataperm.major_id
		LEFT JOIN sys.fulltext_catalogs ftc WITH (NOLOCK) ON ftc.fulltext_catalog_id = dataperm.major_id
		LEFT JOIN sys.symmetric_keys sk WITH (NOLOCK) ON sk.symmetric_key_id = dataperm.major_id
		LEFT JOIN sys.certificates crt WITH (NOLOCK) ON crt.certificate_id = dataperm.major_id
		LEFT JOIN sys.asymmetric_keys ask WITH (NOLOCK) ON ask.asymmetric_key_id = dataperm.major_id
		LEFT JOIN sys.database_principals grantee_dp WITH (NOLOCK) ON grantee_dp.principal_id = dataperm.grantee_principal_id
		LEFT JOIN sys.database_principals grantor_dp WITH (NOLOCK) ON grantor_dp.principal_id = dataperm.grantor_principal_id
		WHERE dataperm.major_id not in (-986524149, -369557355, -282896470, -233346666)';
    --print @SQL
    INSERT INTO #permissions
    (
        DatabaseName,
        class,
        class_desc,
        major_id,
        schema_id,
        schema_name,
        object_name,
        minor_id,
        column_id,
        column_name,
        grantee_principal_id,
        grantee_name,
        grantee_sid,
        grantor_principal_id,
        grantor_name,
        grantor_sid,
        type,
        permission_name,
        state,
        state_desc
    )
    EXEC (@SQL);

    SELECT @DBNum = MIN(ID)
    FROM #DatabasesToProcess
    WHERE ID > @DBNum;
END;
INSERT INTO #permissions
(
    DatabaseName,
    class,
    class_desc,
    major_id,
    schema_id,
    schema_name,
    object_name,
    minor_id,
    column_id,
    column_name,
    grantee_principal_id,
    grantee_name,
    grantee_sid,
    grantor_principal_id,
    grantor_name,
    grantor_sid,
    type,
    permission_name,
    state,
    state_desc
)
SELECT NULL,
       svrperm.class,
       svrperm.class_desc,
       svrperm.major_id,
       NULL,
       NULL,
       CASE svrperm.class
           WHEN 100 THEN
               CONVERT(VARCHAR(128), SERVERPROPERTY('MachineName'))
               + ISNULL('\' + CONVERT(VARCHAR(128), SERVERPROPERTY('InstanceName')), '')
           WHEN 101 THEN
               sp.name
           WHEN 105 THEN
               sep.name
       END,
       --else OBJECT_NAME(major_id) end
       svrperm.minor_id,
       NULL,
       NULL,
       svrperm.grantee_principal_id,
       grantee_sp.name,
       grantee_sp.sid,
       svrperm.grantor_principal_id,
       grantor_sp.name,
       grantor_sp.sid,
       svrperm.type,
       svrperm.permission_name,
       svrperm.state,
       svrperm.state_desc
FROM master.sys.server_permissions svrperm WITH (NOLOCK)
    LEFT JOIN sys.server_principals sp WITH (NOLOCK)
        ON sp.principal_id = svrperm.major_id
    LEFT JOIN sys.endpoints sep WITH (NOLOCK)
        ON sep.endpoint_id = svrperm.major_id
    LEFT JOIN sys.server_principals grantee_sp WITH (NOLOCK)
        ON grantee_sp.principal_id = svrperm.grantee_principal_id
    LEFT JOIN sys.server_principals grantor_sp WITH (NOLOCK)
        ON grantor_sp.principal_id = svrperm.grantor_principal_id;

INSERT INTO dbo.Audit_Permissions
(
    DatabaseName,
    class,
    class_desc,
    major_id,
    schema_id,
    schema_name,
    object_name,
    minor_id,
    column_id,
    column_name,
    grantee_principal_id,
    grantee_name,
    grantee_sid,
    grantor_principal_id,
    grantor_name,
    grantor_sid,
    type,
    permission_name,
    state,
    state_desc,
    action,
    Discovered_Date,
    Date_Changed
)
SELECT tp.DatabaseName,
       tp.class,
       tp.class_desc,
       tp.major_id,
       tp.schema_id,
       tp.schema_name,
       tp.object_name,
       tp.minor_id,
       tp.column_id,
       tp.column_name,
       tp.grantee_principal_id,
       tp.grantee_name,
       tp.grantee_sid,
       tp.grantor_principal_id,
       tp.grantor_name,
       tp.grantor_sid,
       tp.type,
       tp.permission_name,
       tp.state,
       tp.state_desc,
       'ADD',
       @Date,
       @Date
FROM #permissions tp
    LEFT JOIN dbo.Inv_Permissions ap
        ON ISNULL(tp.DatabaseName, 'ALL_DBs') = ISNULL(ap.DatabaseName, 'ALL_DBs')
           AND tp.class = ap.class
           AND tp.major_id = ap.major_id
           AND tp.minor_id = ap.minor_id
           AND
           (
               tp.grantee_sid = ap.grantee_sid
               OR
               (
                   tp.grantee_sid IS NULL
                   AND tp.grantee_name = ap.grantee_name
               )
           )
           AND tp.grantor_sid = ap.grantor_sid
           AND tp.type = ap.type
           AND tp.permission_name = ap.permission_name
           AND tp.state = ap.state
WHERE ap.major_id IS NULL;

UPDATE ap
SET ap.schema_id = tp.schema_id,
    ap.schema_name = tp.schema_name,
    ap.column_id = tp.column_id,
    ap.column_name = tp.column_name
FROM dbo.Audit_Permissions ap
    LEFT JOIN #permissions tp
        ON ISNULL(tp.DatabaseName, 'ALL_DBs') = ISNULL(ap.DatabaseName, 'ALL_DBs')
           AND tp.class = ap.class
           AND tp.major_id = ap.major_id
           AND tp.minor_id = ap.minor_id
           AND tp.grantee_principal_id = ap.grantee_principal_id
           AND tp.grantor_principal_id = ap.grantor_principal_id
           AND tp.type = ap.type
           AND tp.permission_name = ap.permission_name
           AND tp.state = ap.state
WHERE (
          ap.schema_id IS NULL
          AND tp.schema_id IS NOT NULL
      )
      OR
      (
          ap.column_id IS NULL
          AND tp.column_id IS NOT NULL
      );

INSERT INTO dbo.Inv_Permissions
(
    DatabaseName,
    class,
    class_desc,
    major_id,
    schema_id,
    schema_name,
    object_name,
    minor_id,
    column_id,
    column_name,
    grantee_principal_id,
    grantee_name,
    grantee_sid,
    grantor_principal_id,
    grantor_name,
    grantor_sid,
    type,
    permission_name,
    state,
    state_desc,
    Discovered_Date
)
SELECT tp.DatabaseName,
       tp.class,
       tp.class_desc,
       tp.major_id,
       tp.schema_id,
       tp.schema_name,
       tp.object_name,
       tp.minor_id,
       tp.column_id,
       tp.column_name,
       tp.grantee_principal_id,
       tp.grantee_name,
       tp.grantee_sid,
       tp.grantor_principal_id,
       tp.grantor_name,
       tp.grantor_sid,
       tp.type,
       tp.permission_name,
       tp.state,
       tp.state_desc,
       @Date
FROM #permissions tp
    LEFT JOIN dbo.Inv_Permissions ap
        ON ISNULL(tp.DatabaseName, 'ALL_DBs') = ISNULL(ap.DatabaseName, 'ALL_DBs')
           AND tp.class = ap.class
           AND tp.major_id = ap.major_id
           AND tp.minor_id = ap.minor_id
           AND
           (
               tp.grantee_sid = ap.grantee_sid
               OR
               (
                   tp.grantee_sid IS NULL
                   AND tp.grantee_name = ap.grantee_name
               )
           )
           AND tp.grantor_sid = ap.grantor_sid
           AND tp.type = ap.type
           AND tp.permission_name = ap.permission_name
           AND tp.state = ap.state
WHERE ap.major_id IS NULL;

INSERT INTO dbo.Audit_Permissions
(
    DatabaseName,
    class,
    class_desc,
    major_id,
    schema_id,
    schema_name,
    object_name,
    minor_id,
    column_id,
    column_name,
    grantee_principal_id,
    grantee_name,
    grantee_sid,
    grantor_principal_id,
    grantor_name,
    grantor_sid,
    type,
    permission_name,
    state,
    state_desc,
    action,
    Discovered_Date,
    Date_Changed
)
SELECT ap.DatabaseName,
       ap.class,
       ap.class_desc,
       ap.major_id,
       ap.schema_id,
       ap.schema_name,
       ap.object_name,
       ap.minor_id,
       ap.column_id,
       ap.column_name,
       ap.grantee_principal_id,
       ap.grantee_name,
       ap.grantee_sid,
       ap.grantor_principal_id,
       ap.grantor_name,
       ap.grantor_sid,
       ap.type,
       ap.permission_name,
       ap.state,
       ap.state_desc,
       'REMOVE',
       ap.Discovered_Date,
       @Date
FROM #permissions tp
    RIGHT JOIN dbo.Inv_Permissions ap
        ON ISNULL(tp.DatabaseName, 'ALL_DBs') = ISNULL(ap.DatabaseName, 'ALL_DBs')
           AND tp.class = ap.class
           AND tp.major_id = ap.major_id
           AND tp.minor_id = ap.minor_id
           AND
           (
               tp.grantee_sid = ap.grantee_sid
               OR
               (
                   tp.grantee_sid IS NULL
                   AND tp.grantee_name = ap.grantee_name
               )
           )
           AND tp.grantor_sid = ap.grantor_sid
           AND tp.type = ap.type
           AND tp.permission_name = ap.permission_name
           AND tp.state = ap.state
WHERE tp.major_id IS NULL;

DELETE FROM dbo.Inv_Permissions
FROM dbo.Inv_Permissions ap
    LEFT JOIN #permissions tp
        ON ISNULL(tp.DatabaseName, 'ALL_DBs') = ISNULL(ap.DatabaseName, 'ALL_DBs')
           AND tp.class = ap.class
           AND tp.major_id = ap.major_id
           AND tp.minor_id = ap.minor_id
           AND
           (
               tp.grantee_sid = ap.grantee_sid
               OR
               (
                   tp.grantee_sid IS NULL
                   AND tp.grantee_name = ap.grantee_name
               )
           )
           AND tp.grantor_sid = ap.grantor_sid
           AND tp.type = ap.type
           AND tp.permission_name = ap.permission_name
           AND tp.state = ap.state
WHERE tp.major_id IS NULL;

UPDATE dbo.Inv_Permissions
SET object_name = CONVERT(VARCHAR(128), SERVERPROPERTY('MachineName'))
                  + ISNULL('\' + CONVERT(VARCHAR(128), SERVERPROPERTY('InstanceName')), '')
WHERE class_desc = 'SERVER'
      AND object_name <> CONVERT(VARCHAR(128), SERVERPROPERTY('MachineName'))
                         + ISNULL('\' + CONVERT(VARCHAR(128), SERVERPROPERTY('InstanceName')), '');

DROP TABLE #permissions;
DROP TABLE #DatabasesToProcess;

IF @Silent = 0
    SELECT [DatabaseName],
           [class],
           [class_desc],
           [major_id],
           [schema_id],
           [schema_name],
           [object_name],
           [minor_id],
           [column_id],
           [column_name],
           [grantee_principal_id],
           [grantee_name],
           [grantee_sid],
           [grantor_principal_id],
           [grantor_name],
           [grantor_sid],
           [type],
           [permission_name],
           [state],
           [state_desc],
           [action],
           [Discovered_Date],
           [Date_Changed]
    FROM dbo.[Audit_Permissions]
    WHERE [Date_Changed] = @Date;

GO

CREATE PROCEDURE [dbo].[usp_Clone_Account]
    /*********************************************************************************************
PURPOSE:	Purpose of this object is to clone all roles/permissions for an account
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name			Change Description	
----------			--------------			------------------
2015-04-03			Jared Karney			Original adapted from James Rzepka
----------------------------------------------------------------------------------------------
USAGE:
EXEC dbo.usp_Clone_Account
	@OldLogin = 'All Logins',
	@CreateLogin = 0,
	@Debug = 1

EXEC dbo.usp_Clone_Account
	@OldLogin = 'jaredTest',
	@NewLogin = 'JaredTest2',
	@Password = 'E!y1sB2]8b{QfP6Rs{&o1CQ%d82B'

EXEC dbo.usp_Clone_Account
	@OldLogin = 'All Logins',
	@CreateLogin = 0,
	@SourceDB = 'JaredTestDB',
	@DestDB = 'JaredTestDB2'

This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
**********************************************************************************************/

    @OldLogin sysname,        --Pass in 'All Logins' to clone everything (mainly for use with @SourceDB and @DestDB)
    @NewLogin sysname = NULL, --Do not use when 'All Logins' is passed into @OldLogin
    @Password VARCHAR(128) = NULL,
    @CreateLogin BIT = 1,
    @Debug BIT = 0,
    @WindowsLogin BIT = 0,
    @SelectReturnValue BIT = 0,
    @SourceDB VARCHAR(128) = NULL,
    @DestDB VARCHAR(128) = NULL
AS
SET NOCOUNT ON;


CREATE TABLE #Rights
(
    ID INT IDENTITY,
    Rights VARCHAR(1024),
    DBName VARCHAR(128)
);
CREATE TABLE #test
(
    ServerName VARCHAR(128)
);

DECLARE @Error VARCHAR(512),
        @RunDate DATETIME,
        @message VARCHAR(3072),
        @Rights VARCHAR(1024);

IF LEN(ISNULL(@Password, '')) = 0
   AND @CreateLogin = 1
   AND @WindowsLogin = 0
BEGIN
    SELECT @Error = 'Password must be specified.';
    RAISERROR(@Error, 16, 10);
    IF @SelectReturnValue = 1
        SELECT -1 AS result;
    RETURN -1;
END;

IF @NewLogin IS NULL
   AND @OldLogin <> 'All Logins'
BEGIN
    SELECT @Error = '@NewLogin must be specified.';
    RAISERROR(@Error, 16, 10);
    IF @SelectReturnValue = 1
        SELECT -1 AS result;
    RETURN -1;
END;

IF @OldLogin IS NULL
BEGIN
    SELECT @Error = '@OldLogin must be specified.';
    RAISERROR(@Error, 16, 10);
    IF @SelectReturnValue = 1
        SELECT -1 AS result;
    RETURN -1;
END;

IF @SourceDB IS NOT NULL
   AND @DestDB IS NULL
BEGIN
    SELECT @Error = '@DestDB must be specified when @SourceDB is specified.';
    RAISERROR(@Error, 16, 10);
    IF @SelectReturnValue = 1
        SELECT -1 AS result;
    RETURN -1;
END;

IF @OldLogin = 'All Logins'
   AND @SourceDB IS NULL
   AND @Debug = 0
BEGIN
    SELECT @Error = '@Debug must be used when cloning all logins.';
    RAISERROR(@Error, 16, 10);
    IF @SelectReturnValue = 1
        SELECT -1 AS result;
    RETURN -1;
END;

IF @OldLogin = 'All Logins'
   AND ISNULL(@SourceDB, 'Source') = ISNULL(@DestDB, 'Destination')
   AND @Debug = 0
BEGIN
    SELECT @Error = '@Debug must be used when cloning a database''s rights to itself.';
    RAISERROR(@Error, 16, 10);
    IF @SelectReturnValue = 1
        SELECT -1 AS result;
    RETURN -1;
END;

IF @SourceDB IS NULL
   AND @DestDB IS NOT NULL
    SELECT @DestDB = NULL;

IF @OldLogin = 'All Logins'
   AND @NewLogin IS NOT NULL
    SELECT @NewLogin = NULL;

IF @OldLogin = 'All Logins'
   AND @CreateLogin = 1
    SELECT @CreateLogin = 0;

SET @RunDate = GETDATE();

EXEC dbo.usp_Role_Audit @Silent = 1;
EXEC dbo.usp_Permissions_Audit @Silent = 1;

INSERT INTO #Rights
SELECT '--Cloning permissions from ' + CASE @OldLogin
                                           WHEN 'All Logins' THEN
                                               ISNULL(QUOTENAME(@SourceDB), '''All Logins''')
                                           ELSE
                                               QUOTENAME(@OldLogin)
                                       END + ISNULL(' to ' + QUOTENAME(ISNULL(@NewLogin, @DestDB)), ''),
       '';

--Create Login
IF @CreateLogin = 1
BEGIN
    BEGIN TRY
        SELECT @Rights
            = 'USE [master]' + CHAR(10)
              + CASE @WindowsLogin
                    WHEN 1 THEN
                        'CREATE LOGIN [' + @NewLogin + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]'
                    ELSE
                        'CREATE LOGIN [' + @NewLogin + '] WITH PASSWORD=N''' + @Password
                        + ''', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF--, CHECK_POLICY=OFF'
                END;

        IF @Debug = 1
            INSERT INTO #Rights
            SELECT @Rights,
                   '';
        ELSE
            EXEC (@Rights);

        IF @WindowsLogin = 0
        BEGIN
            SELECT @Rights
                = 'xp_cmdshell ''sqlcmd -S ' + @@servername + ' -U ' + @NewLogin + ' -P "' + @Password
                  + '" -q "select @@Servername"''' + CHAR(10);
            IF @Debug = 1
                PRINT @Rights;
            ELSE
                INSERT INTO #test
                EXEC (@Rights);
            IF @Debug = 1
            BEGIN
                PRINT '/* The Clone from ' + @OldLogin + ' to ' + @NewLogin
                      + ' has not been tested.  This was a debug run only */';
                INSERT INTO dbo.Audit_Clone_Account
                SELECT @RunDate,
                       SUSER_NAME(),
                       @OldLogin,
                       @NewLogin,
                       'debug run',
                       NULL;
            END;
            ELSE IF EXISTS (SELECT ServerName FROM #test WHERE ServerName = @@servername)
            BEGIN
                PRINT '/* The Clone from ' + @OldLogin + ' to ' + @NewLogin + ' succeeded. */';
                INSERT INTO Audit_Clone_Account
                SELECT @RunDate,
                       SUSER_NAME(),
                       @OldLogin,
                       @NewLogin,
                       'Success - Create Account',
                       NULL;
            END;
            ELSE
            BEGIN
                PRINT '/* The Clone from ' + @OldLogin + ' to ' + @NewLogin + ' failed. */';
                INSERT INTO Audit_Clone_Account
                SELECT @RunDate,
                       SUSER_NAME(),
                       @OldLogin,
                       @NewLogin,
                       'Failure - Create Account',
                       'The clone test login failed.';

                SET @message = 'The connection test failed.';
                RAISERROR(@message, 16, 1);
                IF @SelectReturnValue = 1
                    SELECT -1 AS result;
                RETURN -1;
            END;
        END;
        ELSE
        BEGIN
            PRINT '/* The Clone from ' + @OldLogin + ' to ' + @NewLogin
                  + ' has not been tested.  This is a windows login */';
            INSERT INTO Audit_Clone_Account
            SELECT @RunDate,
                   SUSER_NAME(),
                   @OldLogin,
                   @NewLogin,
                   'Windows login - cannot test',
                   NULL;
        END;
    END TRY
    BEGIN CATCH
        PRINT '/* The Clone from ' + @OldLogin + ' to ' + @NewLogin + ' failed.  Error message: ' + ERROR_MESSAGE()
              + ' */';
        INSERT INTO Audit_Clone_Account
        SELECT @RunDate,
               SUSER_NAME(),
               @OldLogin,
               @NewLogin,
               'Failure - Create Account',
               ERROR_MESSAGE();

        SET @message = ERROR_MESSAGE();
        RAISERROR(@message, 16, 1);
        IF @SelectReturnValue = 1
            SELECT -1 AS result;
        RETURN -1;
    END CATCH;
END;
ELSE IF @OldLogin <> 'All Logins'
    INSERT INTO Audit_Clone_Account
    SELECT @RunDate,
           SUSER_NAME(),
           @OldLogin,
           @NewLogin,
           'No login created.',
           ERROR_MESSAGE();


--Server Roles
INSERT INTO #Rights
SELECT 'USE [Master]' + CHAR(10) + 'EXEC master.dbo.sp_addsrvrolemember @loginame = '
       + QUOTENAME(ISNULL(@NewLogin, rm.SQL_Login), '''') + ', @rolename = ' + QUOTENAME(Role_Name, ''''),
       ''
FROM dbo.Inv_Roles AS rm
WHERE DatabaseName = ''
      AND Role_Name <> 'Public'
      AND rm.SQL_Login = CASE
                             WHEN @OldLogin = 'All Logins'
                                  AND @SourceDB IS NULL THEN
                                 rm.SQL_Login
                             ELSE
                                 @OldLogin
                         END
ORDER BY rm.SQL_Login ASC;

--Server Permissions (Exclude Connect as the login automatically gets that when created)
INSERT INTO #Rights
SELECT 'USE [Master] ' + CHAR(10) + CASE
                                        WHEN perm.state <> 'W' THEN
                                            perm.state_desc + ' '
                                        ELSE
                                            'GRANT '
                                    END + perm.permission_name + ' TO '
       + QUOTENAME(ISNULL(@NewLogin, perm.grantee_name)) COLLATE DATABASE_DEFAULT + CASE
                                                                                        WHEN perm.state <> 'W' THEN
                                                                                            ''
                                                                                        ELSE
                                                                                            ' WITH GRANT OPTION'
                                                                                    END,
       ''
FROM dbo.Inv_Permissions AS perm
WHERE DatabaseName IS NULL
      AND perm.grantee_name = CASE
                                  WHEN @OldLogin = 'All Logins'
                                       AND @SourceDB IS NULL THEN
                                      perm.grantee_name
                                  ELSE
                                      @OldLogin
                              END
      AND perm.class = 100
      AND type <> 'COSQ'
ORDER BY perm.permission_name ASC,
         perm.state_desc ASC;

INSERT INTO #Rights
SELECT 'USE [Master] ' + CHAR(10) + CASE
                                        WHEN perm.state <> 'W' THEN
                                            perm.state_desc + ' '
                                        ELSE
                                            'GRANT '
                                    END + perm.permission_name + ' ON ' + CASE class_desc
                                                                              WHEN 'SERVER_PRINCIPAL' THEN
                                                                                  'LOGIN'
                                                                              ELSE
                                                                                  class_desc
                                                                          END + '::' + QUOTENAME(perm.object_name)
       + ' TO ' + QUOTENAME(ISNULL(@NewLogin, perm.grantee_name)) COLLATE DATABASE_DEFAULT
       + CASE
             WHEN perm.state <> 'W' THEN
                 ''
             ELSE
                 ' WITH GRANT OPTION'
         END,
       ''
FROM dbo.Inv_Permissions AS perm
WHERE DatabaseName IS NULL
      AND perm.grantee_name = CASE
                                  WHEN @OldLogin = 'All Logins'
                                       AND @SourceDB IS NULL THEN
                                      perm.grantee_name
                                  ELSE
                                      @OldLogin
                              END
      AND perm.class <> 100
ORDER BY perm.permission_name ASC,
         perm.state_desc ASC;

--Set DB Owner when @OldLogin = 'All Logins'
INSERT INTO #Rights
SELECT CASE
           WHEN sdb.is_read_only = 1 THEN
               'ALTER DATABASE ' + ISNULL(QUOTENAME(@DestDB), rm.DatabaseName) + CHAR(10) + 'SET READ_WRITE' + CHAR(10)
           ELSE
               ''
       END + 'alter authorization on database::' + ISNULL(QUOTENAME(@DestDB), rm.DatabaseName) + ' to '
       + QUOTENAME(rm.SQL_Login)
       + CASE
             WHEN sdb.is_read_only = 1 THEN
                 CHAR(10) + 'ALTER DATABASE ' + ISNULL(QUOTENAME(@DestDB), rm.DatabaseName) + CHAR(10)
                 + 'SET READ_ONLY'
             ELSE
                 ''
         END,
       DatabaseName
FROM dbo.Inv_Roles AS rm
    JOIN master.sys.databases sdb
        ON REPLACE(REPLACE(ISNULL(@DestDB, rm.DatabaseName), '[', ''), ']', '') = sdb.name
WHERE rm.Role_Name = 'Public'
      AND @OldLogin = 'All Logins'
      AND REPLACE(REPLACE(rm.DatabaseName, '[', ''), ']', '') = ISNULL(
                                                                          @SourceDB,
                                                                          REPLACE(
                                                                                     REPLACE(rm.DatabaseName, '[', ''),
                                                                                     ']',
                                                                                     ''
                                                                                 )
                                                                      )
      AND rm.DB_Login = 'dbo';

--Create User
INSERT INTO #Rights
SELECT 'USE ' + ISNULL(QUOTENAME(@DestDB), rm.DatabaseName) + CHAR(10)
       + CASE
             WHEN sdb.is_read_only = 1 THEN
                 'ALTER DATABASE ' + ISNULL(QUOTENAME(@DestDB), rm.DatabaseName) + CHAR(10) + 'SET READ_WRITE'
                 + CHAR(10)
             ELSE
                 ''
         END
       + 'IF NOT EXISTS(SELECT TOP 1 1 FROM sys.database_principals dp JOIN sys.server_principals sp ON dp.sid = sp.sid WHERE sp.name = '''
       + ISNULL(@NewLogin, rm.SQL_Login) + ''')' + CHAR(10) + 'CREATE USER '
       + QUOTENAME(ISNULL(ISNULL(@NewLogin, rm.SQL_Login), rm.DB_Login)) + ' FOR LOGIN '
       + QUOTENAME(ISNULL(@NewLogin, rm.SQL_Login))
       + ISNULL(' WITH DEFAULT_SCHEMA=[' + rm.default_schema_name + ']', '')
       + CASE
             WHEN sdb.is_read_only = 1 THEN
                 CHAR(10) + 'ALTER DATABASE ' + ISNULL(QUOTENAME(@DestDB), rm.DatabaseName) + CHAR(10)
                 + 'SET READ_ONLY'
             ELSE
                 ''
         END,
       DatabaseName
FROM dbo.Inv_Roles AS rm
    JOIN master.sys.databases sdb
        ON REPLACE(REPLACE(ISNULL(@DestDB, rm.DatabaseName), '[', ''), ']', '') = sdb.name
WHERE rm.Role_Name = 'Public'
      AND rm.SQL_Login = CASE @OldLogin
                             WHEN 'All Logins' THEN
                                 rm.SQL_Login
                             ELSE
                                 @OldLogin
                         END
      AND rm.SQL_Login <> ''
      AND rm.SQL_Login IS NOT NULL
      AND REPLACE(REPLACE(rm.DatabaseName, '[', ''), ']', '') = ISNULL(
                                                                          @SourceDB,
                                                                          REPLACE(
                                                                                     REPLACE(rm.DatabaseName, '[', ''),
                                                                                     ']',
                                                                                     ''
                                                                                 )
                                                                      )
      AND rm.DB_Login <> 'dbo';

--Database Roles
INSERT INTO #Rights
SELECT 'USE ' + ISNULL(QUOTENAME(@DestDB), rm.DatabaseName) + CHAR(10)
       + CASE
             WHEN sdb.is_read_only = 1 THEN
                 'ALTER DATABASE ' + ISNULL(QUOTENAME(@DestDB), rm.DatabaseName) + CHAR(10) + 'SET READ_WRITE'
                 + CHAR(10)
             ELSE
                 ''
         END + 'EXEC sp_addrolemember @rolename = ' + QUOTENAME(Role_Name, '''') + ', @membername = '
       + QUOTENAME(ISNULL(@NewLogin, rm.SQL_Login), '''')
       + CASE
             WHEN sdb.is_read_only = 1 THEN
                 CHAR(10) + 'ALTER DATABASE ' + ISNULL(QUOTENAME(@DestDB), rm.DatabaseName) + CHAR(10)
                 + 'SET READ_ONLY'
             ELSE
                 ''
         END,
       DatabaseName
FROM dbo.Inv_Roles AS rm
    JOIN master.sys.databases sdb
        ON REPLACE(REPLACE(ISNULL(@DestDB, rm.DatabaseName), '[', ''), ']', '') = sdb.name
WHERE rm.Role_Name <> 'Public'
      AND rm.SQL_Login = CASE @OldLogin
                             WHEN 'All Logins' THEN
                                 rm.SQL_Login
                             ELSE
                                 @OldLogin
                         END
      AND rm.SQL_Login <> ''
      AND REPLACE(REPLACE(rm.DatabaseName, '[', ''), ']', '') = ISNULL(
                                                                          @SourceDB,
                                                                          REPLACE(
                                                                                     REPLACE(rm.DatabaseName, '[', ''),
                                                                                     ']',
                                                                                     ''
                                                                                 )
                                                                      )
      AND rm.DB_Login <> 'dbo'
ORDER BY rm.SQL_Login ASC;

--Database Permissions
INSERT INTO #Rights
SELECT 'USE ' + QUOTENAME(ISNULL(@DestDB, perm.DatabaseName)) + CHAR(10)
       + CASE
             WHEN sdb.is_read_only = 1 THEN
                 'ALTER DATABASE ' + QUOTENAME(ISNULL(@DestDB, perm.DatabaseName)) + CHAR(10) + 'SET READ_WRITE'
                 + CHAR(10)
             ELSE
                 ''
         END + CASE
                   WHEN perm.state <> 'W' THEN
                       perm.state_desc + ' '
                   ELSE
                       'GRANT '
               END + perm.permission_name + ' ON ' + CASE perm.class
                                                         WHEN 1 THEN
                                                             ISNULL(QUOTENAME(perm.schema_name) + '.', '')
                                                         ELSE
                                                             CASE class_desc
                                                                 WHEN 'SERVICE_CONTRACT' THEN
                                                                     'CONTRACT'
                                                                 WHEN 'SYMMETRIC_KEYS' THEN
                                                                     'SYMMETRIC KEY'
                                                                 ELSE
                                                                     class_desc
                                                             END + '::'
                                                     END + QUOTENAME(perm.object_name)
       + ISNULL('(' + QUOTENAME(perm.column_name) + ')', '') + ' TO '
       + QUOTENAME(ISNULL(@NewLogin, perm.grantee_name)) COLLATE DATABASE_DEFAULT + CASE
                                                                                        WHEN perm.state <> 'W' THEN
                                                                                            ''
                                                                                        ELSE
                                                                                            ' WITH GRANT OPTION'
                                                                                    END
       + CASE
             WHEN sdb.is_read_only = 1 THEN
                 CHAR(10) + 'ALTER DATABASE ' + QUOTENAME(ISNULL(@DestDB, perm.DatabaseName)) + CHAR(10)
                 + 'SET READ_ONLY'
             ELSE
                 ''
         END,
       QUOTENAME(DatabaseName)
FROM dbo.Inv_Permissions AS perm
    JOIN master.sys.server_principals
        ON perm.grantee_sid = sid
    JOIN master.sys.databases sdb
        ON ISNULL(@DestDB, perm.DatabaseName) = sdb.name
WHERE perm.grantee_name = CASE @OldLogin
                              WHEN 'All Logins' THEN
                                  perm.grantee_name
                              ELSE
                                  @OldLogin
                          END
      AND perm.major_id <> 0
      AND perm.DatabaseName = ISNULL(@SourceDB, perm.DatabaseName)
ORDER BY perm.permission_name ASC,
         perm.state_desc ASC;

INSERT INTO #Rights
SELECT 'USE ' + QUOTENAME(ISNULL(@DestDB, perm.DatabaseName)) + CHAR(10)
       + CASE
             WHEN sdb.is_read_only = 1 THEN
                 'ALTER DATABASE ' + QUOTENAME(ISNULL(@DestDB, perm.DatabaseName)) + CHAR(10) + 'SET READ_WRITE'
                 + CHAR(10)
             ELSE
                 ''
         END + CASE
                   WHEN perm.state <> 'W' THEN
                       perm.state_desc + ' '
                   ELSE
                       'GRANT '
               END + perm.permission_name + ' TO '
       + QUOTENAME(ISNULL(@NewLogin, perm.grantee_name)) COLLATE DATABASE_DEFAULT + CASE
                                                                                        WHEN perm.state <> 'W' THEN
                                                                                            ''
                                                                                        ELSE
                                                                                            ' WITH GRANT OPTION'
                                                                                    END
       + CASE
             WHEN sdb.is_read_only = 1 THEN
                 CHAR(10) + 'ALTER DATABASE ' + QUOTENAME(ISNULL(@DestDB, perm.DatabaseName)) + CHAR(10)
                 + 'SET READ_ONLY'
             ELSE
                 ''
         END,
       QUOTENAME(DatabaseName)
FROM dbo.Inv_Permissions AS perm
    JOIN master.sys.databases sdb
        ON ISNULL(@DestDB, perm.DatabaseName) = sdb.name
    JOIN master.sys.server_principals
        ON perm.grantee_sid = sid
WHERE DatabaseName IS NOT NULL
      AND perm.grantee_name = CASE @OldLogin
                                  WHEN 'All Logins' THEN
                                      perm.grantee_name
                                  ELSE
                                      @OldLogin
                              END
      AND perm.major_id = 0
      AND perm.type <> 'CO  '
      AND perm.DatabaseName = ISNULL(@SourceDB, perm.DatabaseName)
ORDER BY perm.permission_name ASC,
         perm.state_desc ASC;

--All Rights
IF @Debug = 1
BEGIN
    SELECT Rights AS '--Rights'
    FROM #Rights
    ORDER BY DBName,
             ID;
    IF @CreateLogin = 1
    BEGIN
        PRINT '/* The Clone from ' + @OldLogin + ' to ' + @NewLogin
              + ' has not been tested.  This was a debug run only */';
        INSERT INTO Audit_Clone_Account
        SELECT @RunDate,
               SUSER_NAME(),
               @OldLogin,
               @NewLogin,
               'debug run',
               NULL;
    END;
END;
ELSE
BEGIN
    --BEGIN TRAN Clone
    BEGIN TRY
        DECLARE DBCursor CURSOR FOR
        SELECT Rights
        FROM #Rights
        ORDER BY DBName,
                 ID;

        OPEN DBCursor;
        FETCH NEXT FROM DBCursor
        INTO @Rights;
        WHILE @@fetch_status = 0
        BEGIN
            PRINT @Rights;
            EXEC (@Rights);
            FETCH NEXT FROM DBCursor
            INTO @Rights;
        END;

        PRINT '/* The Clone from ' + CASE @OldLogin
                                         WHEN 'All Logins' THEN
                                             @SourceDB
                                         ELSE
                                             @OldLogin
                                     END + ' to ' + ISNULL(@NewLogin, @DestDB) + ' succeeded. */';
        INSERT INTO Audit_Clone_Account
        SELECT @RunDate,
               SUSER_NAME(),
               CASE @OldLogin
                   WHEN 'All Logins' THEN
                       @SourceDB
                   ELSE
                       @OldLogin
               END,
               ISNULL(@NewLogin, @DestDB),
               'Success - Rights assignment',
               NULL;

        CLOSE DBCursor;
        DEALLOCATE DBCursor;
    END TRY
    BEGIN CATCH
        CLOSE DBCursor;
        DEALLOCATE DBCursor;

        --IF @@TRANCOUNT > 0
        --ROLLBACK TRAN Clone

        DECLARE @ErrorMessage VARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        PRINT '/* The Clone from ' + CASE @OldLogin
                                         WHEN 'All Logins' THEN
                                             @SourceDB
                                         ELSE
                                             @OldLogin
                                     END + ' to ' + ISNULL(@NewLogin, @DestDB) + ' failed.  Error message: '
              + ERROR_MESSAGE() + ' */';
        INSERT INTO Audit_Clone_Account
        SELECT @RunDate,
               SUSER_NAME(),
               CASE @OldLogin
                   WHEN 'All Logins' THEN
                       @SourceDB
                   ELSE
                       @OldLogin
               END,
               ISNULL(@NewLogin, @DestDB),
               'Failure - Rights assignment',
               ERROR_MESSAGE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        IF @SelectReturnValue = 1
            SELECT -1 AS result;
        RETURN -1;
    END CATCH;

--IF @@TRANCOUNT > 0
--COMMIT TRAN Clone
END;

DROP TABLE #Rights;
DROP TABLE #test;

IF @SelectReturnValue = 1
    SELECT 0 AS result;
RETURN 0;

SET NOCOUNT OFF;
GO


