USE master

--verify existence of service master key
SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_ServiceMasterKey##'

--drop master key if exists
IF EXISTS(SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_DatabaseMasterKey##')
DROP MASTER KEY

--create database master key
CREATE MASTER KEY
  ENCRYPTION BY PASSWORD = 'testing123!';

--verify database master key
SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_DatabaseMasterKey##'

--create a database for testing
USE master
CREATE DATABASE TDELogGenerationSize
GO

--begin log chain 
BACKUP DATABASE TDELogGenerationSize
TO DISK = 'NUL'

--create a cert in master to encrypt DEK
CREATE CERTIFICATE TDE_TDELogGenerationSize
	WITH SUBJECT = 'TDE cert'


USE TDELogGenerationSize

--create an empty table for insertion of data
SELECT *
INTO dbo.usercolumns
FROM sys.syscolumns
WHERE 1 = 0

--create a table for my test data collection
CREATE TABLE #temp(situation VARCHAR(256), numLogRows INT, logSizeMB INT, logFreeSpaceMB INT,logReservedMB INT, numRowsTable INT)

--clear out t-log
BACKUP LOG TDELogGenerationSize
TO DISK = 'NUL'

--gather initial data
INSERT INTO #temp(situation, numLogRows, logSizeMB, logFreeSpaceMB, logReservedMB, numRowsTable)
SELECT 	'Before Loading Data',
		COUNT(1) AS numLogRows,
		CAST(dbf.size*8/1024 AS int) AS FileSizeMB, 
		CAST(dbf.size*8/1024 - CAST(FILEPROPERTY(dbf.name, 'SpaceUsed' ) AS int)*8/1024 AS int) AS FreeSpaceMB, 
		CAST(dbf.size*8/1024 AS int) - CAST(dbf.size*8/1024 - CAST(FILEPROPERTY(dbf.name, 'SpaceUsed' ) AS int)*8/1024 AS int) as reservedMB,
		(SELECT COUNT(1) FROM dbo.usercolumns)
FROM fn_dblog(null, null) dbl
CROSS JOIN sys.database_files dbf
WHERE type = 1
GROUP BY dbf.size, dbf.name

--insert some data to generate log
INSERT INTO dbo.usercolumns
SELECT TOP 1000000 c1.*
FROM sys.syscolumns c1
CROSS JOIN sys.syscolumns c2

--gather post-data load data
INSERT INTO #temp(situation, numLogRows, logSizeMB, logFreeSpaceMB, logReservedMB, numRowsTable)
SELECT 	'After Loading Data',
		COUNT(1) AS numLogRows,
		CAST(dbf.size*8/1024 AS int) AS FileSizeMB, 
		CAST(dbf.size*8/1024 - CAST(FILEPROPERTY(dbf.name, 'SpaceUsed' ) AS int)*8/1024 AS int) AS FreeSpaceMB, 
		CAST(dbf.size*8/1024 AS int) - CAST(dbf.size*8/1024 - CAST(FILEPROPERTY(dbf.name, 'SpaceUsed' ) AS int)*8/1024 AS int) as reservedMB,
		(SELECT COUNT(1) FROM dbo.usercolumns)
FROM fn_dblog(null, null) dbl
CROSS JOIN sys.database_files dbf
WHERE type = 1
GROUP BY dbf.size, dbf.name

--enable encryption
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDE_TDELogGenerationSize

USE master
ALTER DATABASE TDELogGenerationSize SET ENCRYPTION ON

WHILE EXISTS(SELECT * FROM sys.dm_database_encryption_keys WHERE encryption_state <> 3 AND DB_NAME(database_id) = 'TDELogGenerationSize')
WAITFOR DELAY '00:00:05.000'

--gather post-encryption data
USE TDELogGenerationSize
INSERT INTO #temp(situation, numLogRows, logSizeMB, logFreeSpaceMB, logReservedMB, numRowsTable)
SELECT 	'After Encrypting Data',
		COUNT(1) AS numLogRows,
		CAST(dbf.size*8/1024 AS int) AS FileSizeMB, 
		CAST(dbf.size*8/1024 - CAST(FILEPROPERTY(dbf.name, 'SpaceUsed' ) AS int)*8/1024 AS int) AS FreeSpaceMB, 
		CAST(dbf.size*8/1024 AS int) - CAST(dbf.size*8/1024 - CAST(FILEPROPERTY(dbf.name, 'SpaceUsed' ) AS int)*8/1024 AS int) as reservedMB,
		(SELECT COUNT(1) FROM dbo.usercolumns)
FROM fn_dblog(null, null) dbl
CROSS JOIN sys.database_files dbf
WHERE type = 1
GROUP BY dbf.size, dbf.name

SELECT * FROM #temp

--cleanup
USE master
ALTER DATABASE TDELogGenerationSize SET ENCRYPTION OFF

WHILE EXISTS(SELECT * FROM sys.dm_database_encryption_keys WHERE DB_NAME(database_id) = 'TDELogGenerationSize' AND encryption_state <> 1)
WAITFOR DELAY '00:00:05.000'

USE TDELogGenerationSize
DROP DATABASE ENCRYPTION KEY

USE master
DROP CERTIFICATE TDE_TDELogGenerationSize

DROP DATABASE TDELogGenerationSize

DROP TABLE #temp


