/*
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
*/


use master
go
if db_id('PartitionDB') is not null
drop database PartitionDB
go
CREATE DATABASE PartitionDB 
go

use PartitionDB
go

--Create partition function
-- The below script creates 101 partitions
declare @IntegerPartitionFunction nvarchar(max) = N'CREATE PARTITION FUNCTION IntegerPartitionFunction (int) AS RANGE RIGHT FOR VALUES (';
declare @i int = 1;
while @i < 100  
begin
set @IntegerPartitionFunction += cast(@i as nvarchar(10)) + N', ';
set @i += 1;
end
set @IntegerPartitionFunction += cast(@i as nvarchar(10)) + N');';
exec sp_executesql @IntegerPartitionFunction;
GO
--Create partition scheme

CREATE PARTITION SCHEME [IntegerPartitionScheme]
AS PARTITION [IntegerPartitionFunction]
ALL TO ([PRIMARY])
GO


--Create table on partition scheme
CREATE TABLE t
( PersonId int PRIMARY KEY CLUSTERED,
 PersonName varchar(100),
 ) ON [IntegerPartitionScheme](PersonId)
 GO

--it will show 101 partitions for the table
select * from sys.partitions where object_id = object_id ('t')
go

--create a table for general work
CREATE TABLE testing123 (idCol INT IDENTITY(1,1) PRIMARY KEY CLUSTERED, firstName VARCHAR(25), lastName VARCHAR(25))
GO
--create a procedure that hits testing123 first and the partitioned table second
CREATE OR ALTER PROCEDURE usp_partitionLocking
AS
BEGIN
	INSERT INTO testing123 (firstName, lastName)
	SELECT 'Jared','Karney'

	SELECT * FROM t WHERE personid = 100
END
GO

--create a lock on the partition
BEGIN TRAN
TRUNCATE TABLE t WITH (PARTITIONS (1))
--rollback

--check locks
SELECT * FROM sys.dm_tran_locks

--in another window, run the procedure
--EXEC usp_partitionlocking
--It will be in a running state, so see if the first statement ran
SELECT * FROM testing123

--check locks again
SELECT * FROM sys.dm_tran_locks
SELECT * FROM sys.dm_exec_requests WHERE session_id = 59
SELECT * FROM sys.dm_exec_sql_text(0x030005007C46A537FF43930042B2000001000000000000000000000000000000000000000000000000000000)

/*
--merge few of the partitions to reduce number of partitions
declare @mergeint int = 90
while @mergeint <= 100
begin
ALTER PARTITION FUNCTION IntegerPartitionFunction ()
MERGE RANGE (@mergeint)
set @mergeint += 1
end 

--this will show 90 partitions for the table
select * from sys.partitions where object_id = object_id ('t')

--set Database Recovery Model to SIMPLE
USE master ;
ALTER DATABASE PartitionDB SET RECOVERY SIMPLE ;


*/






