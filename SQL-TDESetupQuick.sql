USE master

--verify existence of service master key
SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_ServiceMasterKey##'

--verify database master key
SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_DatabaseMasterKey##'

--drop master key if exists
IF EXISTS(SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_DatabaseMasterKey##')
DROP MASTER KEY

--create database master key
CREATE MASTER KEY
  ENCRYPTION BY PASSWORD = 'testing123!';
GO 

--verify copy encrypted by service master key (SMK)
SELECT name, is_master_key_encrypted_by_server FROM sys.databases

--verify database master key
SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_DatabaseMasterKey##'


--alter master key drop encryption by password
--ALTER MASTER KEY
--	DROP ENCRYPTION BY PASSWORD = 'testing123!'

SELECT * FROM sys.key_encryptions

SELECT * FROM sys.asymmetric_keys

USE master
RESTORE DATABASE AdventureWorks2019 
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\AdventureWorks2019.bak'
WITH REPLACE

ALTER DATABASE AdventureWorks2019 SET RECOVERY FULL

BACKUP DATABASE AdventureWorks2019
TO DISK = 'NUL'

BACKUP LOG AdventureWorks2019
TO DISK = 'NUL'

USE master
CREATE CERTIFICATE TDE_AdventureWorks2019
	WITH SUBJECT = 'TDE cert'

USE AdventureWorks2019

SELECT COUNT(1) AS BeforeEncKey FROM fn_dblog(null, null)

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDE_AdventureWorks2019

SELECT COUNT(1) AS AfterEncKey FROM fn_dblog(null, null)



USE master
ALTER DATABASE AdventureWorks2019 SET ENCRYPTION ON

WHILE EXISTS(SELECT 1 FROM sys.dm_database_encryption_keys WHERE encryption_state <> 3 AND DB_NAME(database_id) = 'AdventureWorks2019')
WAITFOR DELAY '00:00:05.000'

USE AdventureWorks2019
SELECT COUNT(1) AS AfterEncryption FROM fn_dblog(null, null)

BACKUP LOG AdventureWorks2019
TO DISK = 'NUL'


USE master
ALTER DATABASE AdventureWorks2019 SET ENCRYPTION OFF

WHILE EXISTS(SELECT * FROM sys.dm_database_encryption_keys WHERE DB_NAME(database_id) = 'AdventureWorks2019' AND encryption_state <> 1)
WAITFOR DELAY '00:00:05.000'

USE AdventureWorks2019
DROP DATABASE ENCRYPTION KEY

USE master
DROP CERTIFICATE TDE_AdventureWorks2019



