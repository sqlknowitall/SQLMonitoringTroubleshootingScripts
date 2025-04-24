USE [master]
GO

IF EXISTS  
(SELECT * FROM sys.credentials   
WHERE name = 'https://[Storage Account Name].blob.core.windows.net/[Container Name]')  
DROP CREDENTIAL [https://[Storage Account Name].blob.core.windows.net/[Container Name]]
GO

CREATE CREDENTIAL [https://[Storage Account Name].blob.core.windows.net/[Container Name]] WITH IDENTITY='Shared Access Signature'
, SECRET='[SAS Token]'  
GO

BACKUP DATABASE [DBA] TO  URL = N'https://[Storage Account Name].blob.core.windows.net/[Container Name]/dba_backup.bak'
WITH NOFORMAT, NOINIT,  NAME = N'DBA-Full Database Backup', NOSKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

/*
--Cleanup
USE master
IF EXISTS  
(SELECT * FROM sys.credentials   
WHERE name = 'https://[Storage Account Name].blob.core.windows.net/[Container Name]')  
DROP CREDENTIAL [https://[Storage Account Name].blob.core.windows.net/[Container Name]]
GO
*/
