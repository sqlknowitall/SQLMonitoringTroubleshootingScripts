USE [master]
GO

IF EXISTS  
(SELECT * FROM sys.credentials   
WHERE name = 'https://jaredsqlbackups.blob.core.windows.net/jaredsqlcontainer')  
DROP CREDENTIAL [https://jaredsqlbackups.blob.core.windows.net/jaredsqlcontainer]
GO

CREATE CREDENTIAL [https://jaredsqlbackups.blob.core.windows.net/jaredsqlcontainer] WITH IDENTITY='Shared Access Signature'
, SECRET='sv=2016-05-31&sr=c&si=jaredsqlbackuptourl&sig=PXx7TVKGI2vS1TqedBC1oEbz6Wiva%2Bu0%2BJzIprqRLQk%3D'  
GO

BACKUP DATABASE [DBA] TO  URL = N'https://jaredsqlbackups.blob.core.windows.net/jaredsqlcontainer/dba_backup.bak'
WITH NOFORMAT, NOINIT,  NAME = N'DBA-Full Database Backup', NOSKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

/*
--Cleanup
USE master
IF EXISTS  
(SELECT * FROM sys.credentials   
WHERE name = 'https://jaredsqlbackups.blob.core.windows.net/jaredsqlcontainer')  
DROP CREDENTIAL [https://jaredsqlbackups.blob.core.windows.net/jaredsqlcontainer]
GO
*/