USE master

--create database master key if not exists
IF NOT EXISTS(
SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_DatabaseMasterKey##')

CREATE MASTER KEY
  ENCRYPTION BY PASSWORD = 'somerandomstrong password';
GO 

DECLARE @sql VARCHAR(4000)
DECLARE cur CURSOR
FOR
SELECT 'CREATE CERTIFICATE TDE_' + name + '  
WITH SUBJECT = ''Certificate to protect TDE key'''  FROM sys.databases

OPEN cur

FETCH NEXT FROM cur INTO @sql

WHILE @@FETCH_STATUS = 0
BEGIN
 PRINT @sql
 FETCH NEXT FROM cur INTO @sql
END

CLOSE cur
DEALLOCATE cur



