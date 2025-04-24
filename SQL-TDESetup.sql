USE master

--verify existence of service master key
SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_ServiceMasterKey##'

--verify database master key
SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_DatabaseMasterKey##'

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
ALTER MASTER KEY
	DROP ENCRYPTION BY PASSWORD = 'testing123!'

SELECT * FROM sys.key_encryptions

SELECT * FROM sys.asymmetric_keys