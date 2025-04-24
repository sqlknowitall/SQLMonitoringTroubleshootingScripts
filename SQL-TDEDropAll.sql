/*********************************************************************************************
PURPOSE:    This script removes TDE for demos or dev/test purposes

USAGE:		Change @debug to 0 and @removeTDE to 1 to remove TDE
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name				Change Description                                    
----------			--------------				------------------
07/18/2018			Jared Karney				Original Version
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

SET NOCOUNT ON;

DECLARE @dbname SYSNAME
DECLARE @removeTDE BIT = 1
DECLARE @debug BIT = 0
DECLARE @sql NVARCHAR(MAX)
DECLARE @temp TABLE (dbname SYSNAME)
DECLARE @decryptionProcess VARCHAR(MAX)
/*
SET @debug = 0
SET @removeTDE = 1
*/

DECLARE cur CURSOR
FOR
SELECT name
FROM sys.databases
WHERE is_encrypted = 1 AND database_id <> 2


OPEN cur
FETCH NEXT FROM cur INTO @dbname
WHILE @@FETCH_STATUS = 0
BEGIN
SET @sql =
'USE master
ALTER DATABASE ' + QUOTENAME(@dbname) + ' SET ENCRYPTION OFF
'

IF @debug = 1
PRINT(@SQL)
IF @removeTDE = 1
EXEC sp_executesql @SQL


FETCH NEXT FROM cur INTO @dbname
END
CLOSE cur
DEALLOCATE cur

IF @debug = 0 AND @removeTDE = 1
BEGIN
	WHILE (SELECT COUNT(1) FROM sys.dm_database_encryption_keys WHERE database_id <> 2 AND encryption_state NOT IN (0,1)) > 0
	BEGIN
		PRINT('Waiting for encryption to happen')
		SET @decryptionProcess = (SELECT TOP 1 db_name(database_id) + ' is encrypting and is at ' + CAST(percent_complete AS VARCHAR(10)) + 'pct'
				FROM sys.dm_database_encryption_keys
				WHERE database_id <> 2 AND encryption_state NOT IN (0,1))
		PRINT (@decryptionProcess)
		WAITFOR DELAY '00:00:25.000'
	END
END

DECLARE cur CURSOR
FOR
SELECT DB_NAME(database_id)
FROM sys.dm_database_encryption_keys
WHERE encryption_state = 1 AND database_id <> 2

OPEN cur
FETCH NEXT FROM cur INTO @dbname
WHILE @@FETCH_STATUS = 0
BEGIN
SET @sql =
'USE ' + QUOTENAME(@dbname) + '
DROP DATABASE ENCRYPTION KEY

USE master
DROP CERTIFICATE TDE_' + @dbname + '
'

IF @debug = 1
PRINT(@SQL)
IF @removeTDE = 1
EXEC sp_executesql @SQL


FETCH NEXT FROM cur INTO @dbname
END
CLOSE cur
DEALLOCATE cur
