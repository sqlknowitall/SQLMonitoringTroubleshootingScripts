/*********************************************************************************************
PURPOSE:    Suggest or set MAX and MIN memory for a SQL Server based on actual server memory
	or passed as a parameter. This script assumes a single instance of SQL Server is the only
	resource consumer on this system

USAGE:		Can change @Execute, @ServerMemory
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

-- declare local variables
DECLARE @InstanceName		SYSNAME
DECLARE @SQLVersionMajor	TINYINT
DECLARE @ServerMemory		INT
DECLARE @InstanceMinMemory	INT
DECLARE @InstanceMaxMemory	INT
DECLARE @SQL				NVARCHAR(MAX)
DECLARE @Execute			BIT

--Set this to determine a setting for a specific amount of RAM, elst it will be the connected machine
SET @ServerMemory = NULL

SET @Execute = 0 --change to 1 to set the values for the server

-- initialize local variables
SELECT	@SQLVersionMajor	= @@MicrosoftVersion / 0x01000000, -- Get major version
		@InstanceName		= @@SERVERNAME  + ' (' + CAST(SERVERPROPERTY('productversion') AS VARCHAR) + ' - ' +  LOWER(SUBSTRING(@@VERSION, CHARINDEX('X',@@VERSION),4))  + ' - ' + CAST(SERVERPROPERTY('edition') AS VARCHAR)

-- get the server memory
-- wrap queries execution with sp_executesql to avoid compilation errors
IF @SQLVersionMajor >= 11 AND @ServerMemory IS NULL
BEGIN
	
	SET @SQL = 'SELECT @ServerMemory = physical_memory_kb/1024 FROM	sys.dm_os_sys_info'
	EXEC sp_executesql @SQL, N'@ServerMemory int OUTPUT', @ServerMemory = @ServerMemory OUTPUT

END
ELSE
IF @SQLVersionMajor in (9, 10) AND @ServerMemory IS NULL
BEGIN
	
	SET @SQL = 'SELECT	@ServerMemory = physical_memory_in_bytes/1024/1024 FROM	sys.dm_os_sys_info'
	EXEC sp_executesql @SQL, N'@ServerMemory int OUTPUT', @ServerMemory = @ServerMemory OUTPUT

END
ELSE
IF @SQLVersionMajor < 9
BEGIN
	
	PRINT 'SQL Server versions before 2005 are not supported by this script.'
	RETURN
END

-- fix rounding issues
SET @ServerMemory = @ServerMemory + 1

-- now determine max server settings
-- utilized formula from Jonathan Kehayias: https://www.sqlskills.com/blogs/jonathan/how-much-memory-does-my-sql-server-actually-need/
-- reserve 1 GB of RAM for the OS, 1 GB for each 4 GB of RAM installed from 4–16 GB and then 1 GB for every 8 GB RAM installed above 16 GB RAM.

SELECT	@InstanceMaxMemory = 	CASE	WHEN @ServerMemory <= 1024*2 THEN @ServerMemory - 512  -- @ServerMemory < 2 GB
										WHEN @ServerMemory <= 1024*4 THEN @ServerMemory - 1024 -- @ServerMemory between 2 GB & 4 GB
										WHEN @ServerMemory <= 1024*16 THEN @ServerMemory - 1024 - CEILING((@ServerMemory-4096) / (4.0*1024))*1024 -- @ServerMemory between 4 GB & 8 GB
										WHEN @ServerMemory > 1024*16 THEN @ServerMemory - 4096 - CEILING((@ServerMemory-1024*16) / (8.0*1024))*1024 -- @ServerMemory > 8 GB
								END,
		@InstanceMinMemory =	CEILING(@InstanceMaxMemory * .75) -- set minimum memory to 75% of the maximum

-- adjust the server min / max memory settings accordingly
SET @SQL = 'EXEC sp_configure ''Show Advanced Options'', 1;	
RECONFIGURE WITH OVERRIDE; 
EXEC sp_configure ''min server memory'',' + CONVERT(VARCHAR(6), @InstanceMinMemory) +'; 
RECONFIGURE WITH OVERRIDE; 
EXEC sp_configure ''max server memory'',' + CONVERT(VARCHAR(6), @InstanceMaxMemory) +'; 
RECONFIGURE WITH OVERRIDE; 
--EXEC sp_configure ''Show Advanced Options'', 0; 
--RECONFIGURE WITH OVERRIDE;'

PRINT '----------------------------------------------------------------------'
PRINT 'Instance: ' + @InstanceName
PRINT '----------------------------------------------------------------------'
PRINT 'Determined Minimum Instance Memory: ' + CONVERT(VARCHAR(6), @InstanceMinMemory) + ' MB'
PRINT '----------------------------------------------------------------------'
PRINT 'Determined Maximum Instance Memory: ' + CONVERT(VARCHAR(6), @InstanceMaxMemory) + ' MB' 
PRINT '----------------------------------------------------------------------'

IF @Execute = 1
BEGIN
	
	PRINT 'Executed commands: ' + CHAR(13) + CHAR(13) + @SQL
	PRINT CHAR(13)
	PRINT '----------------------------------------------------------------------'
	PRINT CHAR(13)
	
	EXEC sp_executesql @SQL

	PRINT CHAR(13)
	PRINT '----------------------------------------------------------------------'

END
ELSE
BEGIN

	PRINT 'Commands to execute: ' + CHAR(13) + CHAR(13) + @SQL
	PRINT CHAR(13)
	PRINT '----------------------------------------------------------------------'

END

