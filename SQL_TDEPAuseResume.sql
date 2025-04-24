DECLARE @pauseRestartEncryption VARCHAR(10) = 'Pause' --'Resume'


IF @pauseRestartEncryption = 'Pause'
BEGIN
DBCC TRACEON(5004,-1)
END

SELECT * FROM sys.dm_database_encryption_keys

IF @pauseRestartEncryption = 'Resume'
BEGIN
DBCC TRACEOFF(5004,-1)
ALTER DATABASE CCOMS_MSCRM SET ENCRYPTION ON
--ALTER DATABASE TBOMS_External SET ENCRYPTION ON
END