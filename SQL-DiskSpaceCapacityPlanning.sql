

/*********************************************************************************************
PURPOSE:    Look at history of disk space to determine a linear regression line and
			and help predict future space needs for capacity planning
----------------------------------------------------------------------------------------------
REVISION HISTORY:
Date				Developer Name				Change Description                                    
----------			--------------				------------------
10/15/2017			Jared Karney				Original Version
----------------------------------------------------------------------------------------------
USAGE:	EXEC dbo.usp_diskSpaceCapacityPlanning

This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
We grant You a nonexclusive, royalty-free right to use and modify the 
Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is 
embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
Please note: None of the conditions outlined in the disclaimer above will supercede the terms and conditions contained within the Premier Customer Services Description.
**********************************************************************************************/
CREATE PROC [dbo].usp_diskSpaceCapacityPlanning
	@regressionDays INT = 90 --number of days to use for calculating a linear regression line
	, @capacityPlanningTime INT = 1095 --number of days to look forward for capacity planning
AS
BEGIN
	--DECLARE @regressionDays INT;
	--DECLARE @spaceThresholdDays INT;
	--SET @regressionDays = 90;
	--SET @spaceThresholdDays = 90;
	
	
	DECLARE @snapshotTimeCurr DATETIME;
	DECLARE @snapshotTimeYesterday DATETIME;
	DECLARE @snapshotTimePrevWeek DATETIME;
	DECLARE @regressionDateStart DATETIME;
	DECLARE @spaceTraceStart DATETIME;
	DECLARE @spaceTraceYesterday DATETIME;
	DECLARE @spaceTracePrevWeek DATETIME;
	DECLARE @spaceTraceLess90 DATETIME;
	DECLARE @spaceRunOutDate TABLE(Drive_Letter CHAR(1), runOutDate DATETIME, currFreeSpace INT,
		yesterdayFreeSpace INT, prevWKFreeSpace INT);
	DECLARE @databasesChanged TABLE(Drive_Letter CHAR(1), DB VARCHAR(25), type_desc VARCHAR(10), currDBFileSizeGB INT,
		yesterdayDBFileSizeGB INT, FileChangeFromYesterday INT, prevWkDBFileSizeGB INT, FileChangeFromPrevWK INT,
		FileSizeLess90 INT, currDBDataSizeGB INT, yesterdayDBDataSizeGB INT, DataChangeFromYesterday INT,
		prevWkDBDataSizeGB INT, DataChangeFromPrevWK INT, DataSizeLess90 INT
		)

	SET NOCOUNT ON;
	
	SET @snapshotTimeCurr = DATEADD(DAY,DATEDIFF(DAY,0,GETDATE()),0)
	SET @snapshotTimeYesterday = DATEADD(DAY, -1, @snapshotTimeCurr)
	SET @snapshotTimePrevWeek = DATEADD(DAY, -7, @snapshotTimeCurr)
	SET @regressionDateStart = DATEADD(DAY, -@regressionDays,DATEADD(DAY,DATEDIFF(DAY,0,GETDATE()),0));
	SET @spaceTraceStart = (SELECT TOP 1 snapshot_date
							FROM dbo.Database_Space_Daily
							ORDER BY snapshot_date DESC);
	SET @spaceTraceYesterday = (SELECT DATEADD(DAY,-1,@spaceTraceStart));
	SET @spaceTracePrevWeek = (SELECT DATEADD(DAY,-7,@spaceTraceStart));
	SET @spaceTraceLess90 = (SELECT DATEADD(DAY,-90,@spaceTraceStart));


	--SELECT @spaceTraceStart;
	--SELECT @spaceTraceYesterday;
	--SELECT @spaceTracePrevWeek;
	--SELECT @spaceTraceLess90;



	/***********************************************
	* Figure out if any drive(s) will run
	* out within the specified number of days
	************************************************/
	;WITH
	groupedFreeSpace
	AS
	(
	SELECT Drive_Letter, ROW_NUMBER() OVER(PARTITION BY Drive_Letter ORDER BY snapshot_time ASC) rowNum, Drive_Free_Space
	FROM Disk_Free_Space
	WHERE snapshot_time > @regressionDateStart
	),
	--Determine the number of days we have data for and y-intercept number
	slopeDrive
	AS
	(
	SELECT Drive_Letter
		, MAX(rowNum) AS dayNum
		, (COUNT(1) * SUM(rowNum * Drive_Free_Space) - sum(rowNum) * sum(Drive_Free_Space)) / NULLIF(count(1) * sum(power(rowNum,2)) - power(sum(rowNum),2),0) AS slope
		--, (SUM(rowNum)/COUNT(1)) AS avgX
		--, (SUM(Drive_Free_Space)/COUNT(1)) AS avgY
		, (SUM(Drive_Free_Space)/COUNT(1)) - 
			((SUM(rowNum)/COUNT(1))  *  (COUNT(1) * SUM(rowNum * Drive_Free_Space) - sum(rowNum) * sum(Drive_Free_Space)) / NULLIF(count(1) * sum(power(rowNum,2)) - power(sum(rowNum),2),0)) AS B
	FROM groupedFreeSpace
	GROUP BY Drive_Letter
	)
	--Display where the drive will run out of space within threshold range
	INSERT INTO @spaceRunOutDate (Drive_Letter, runOutDate, currFreeSpace, yesterdayFreeSpace, prevWKFreeSpace)
	SELECT
		sd.Drive_Letter
		, DATEADD(DAY,DATEDIFF(DAY, 0,DATEADD(DAY, CASE WHEN sd.slope = 0 THEN 100000 ELSE -sd.B / sd.slope END - sd.dayNum, GETDATE())),0) 
		, curr.Drive_Free_Space
		, yesterday.Drive_Free_Space
		, prevweek.Drive_Free_Space
	FROM slopeDrive sd
	LEFT JOIN Disk_Free_Space curr
		ON sd.Drive_Letter = curr.Drive_Letter
		AND DATEADD(DAY, DATEDIFF(DAY, 0, curr.snapshot_time),0) = @snapshotTimeCurr
	LEFT JOIN Disk_Free_Space yesterday
		ON sd.Drive_Letter = yesterday.Drive_Letter
		AND DATEADD(DAY, DATEDIFF(DAY, 0, yesterday.snapshot_time),0) = @snapshotTimeYesterday
	LEFT JOIN Disk_Free_Space prevweek
		ON sd.Drive_Letter = prevweek.Drive_Letter
		AND DATEADD(DAY, DATEDIFF(DAY, 0, prevweek.snapshot_time),0) = @snapshotTimePrevWeek
	WHERE
		CASE
			WHEN slope = 0 THEN 100000
			ELSE -B / slope
		END - dayNum BETWEEN 0 AND @spaceThresholdDays;
	
	INSERT INTO @databasesChanged(Drive_Letter, DB, type_desc, currDBFileSizeGB, yesterdayDBFileSizeGB,
		FileChangeFromYesterday, prevWkDBFileSizeGB, FileChangeFromPrevWK, FileSizeLess90,currDBDataSizeGB, yesterdayDBDataSizeGB,
		DataChangeFromYesterday, prevWkDBDataSizeGB, DataChangeFromPrevWK, DataSizeLess90)	
	SELECT DISTINCT d1.Drive_Letter
		, CAST(DB_NAME(mf.database_id) AS VARCHAR(25))
		, CAST(mf.type_desc AS VARCHAR(10))
		, CAST(st.data_allocated_KB/1024/1024 AS INT)
		, CAST(sty.data_allocated_KB/1024/1024 AS INT)
		, CAST(st.data_allocated_KB/1024/1024 AS INT) - CAST(sty.data_allocated_KB/1024/1024 AS INT)
		, CAST(stw.data_allocated_KB/1024/1024 AS INT)
		, CAST(st.data_allocated_KB/1024/1024 AS INT) - CAST(stw.data_allocated_KB/1024/1024 AS INT)
		, CAST(st90.data_allocated_KB/1024/1024 AS INT)
		, CAST(st.data_reserved_KB/1024/1024 AS INT)
		, CAST(sty.data_reserved_KB/1024/1024 AS INT)
		, CAST(st.data_reserved_KB/1024/1024 AS INT) - CAST(sty.data_reserved_KB/1024/1024 AS INT)
		, CAST(stw.data_reserved_KB/1024/1024 AS INT)
		, CAST(st.data_reserved_KB/1024/1024 AS INT) - CAST(stw.data_reserved_KB/1024/1024 AS INT)
		, CAST(st90.data_reserved_KB/1024/1024 AS INT)
	FROM @spaceRunOutDate d1
	INNER JOIN sys.master_files mf
		ON d1.Drive_Letter = SUBSTRING(mf.physical_name,1,1)
		AND mf.[type] = 0
		--AND DB_NAME(mf.database_id) <> 'tempdb'
	LEFT JOIN dbo.Database_Space_Daily st
		ON mf.database_id = DB_ID(st.database_name)
		AND st.snapshot_date = @spaceTraceStart
	LEFT JOIN dbo.Database_Space_Daily sty
		ON mf.database_id = DB_ID(sty.database_name)
		AND sty.snapshot_date = @spaceTraceYesterday
	LEFT JOIN  dbo.Database_Space_Daily stw
		ON mf.database_id = DB_ID(stw.database_name)
		AND stw.snapshot_date = @spaceTracePrevWeek
	LEFT JOIN dbo.Database_Space_Daily st90
		ON mf.database_id = DB_ID(st90.database_name)
		AND st90.snapshot_date = @spaceTraceLess90;

	INSERT INTO @databasesChanged(Drive_Letter, DB, type_desc, currDBFileSizeGB, yesterdayDBFileSizeGB,
		FileChangeFromYesterday, prevWkDBFileSizeGB, FileChangeFromPrevWK, FileSizeLess90)	
	SELECT DISTINCT d1.Drive_Letter
		, CAST(DB_NAME(mf.database_id) AS VARCHAR(25))
		, CAST(mf.type_desc AS VARCHAR(10))
		, CAST(st.log_allocated_KB/1024/1024 AS INT)
		, CAST(sty.log_allocated_KB/1024/1024 AS INT)
		, CAST(st.log_allocated_KB/1024/1024 AS INT) - CAST(sty.log_allocated_KB/1024/1024 AS INT)
		, CAST(stw.log_allocated_KB/1024/1024 AS INT)
		, CAST(st.log_allocated_KB/1024/1024 AS INT) - CAST(stw.log_allocated_KB/1024/1024 AS INT)
		, CAST(st90.log_allocated_KB/1024/1024 AS INT)
	FROM @spaceRunOutDate d1
	INNER JOIN sys.master_files mf
		ON d1.Drive_Letter = SUBSTRING(mf.physical_name,1,1)
		AND mf.[type] = 1
	LEFT JOIN dbo.Database_Space_Daily st
		ON mf.database_id = DB_ID(st.database_name)
		AND st.snapshot_date = @spaceTraceStart
	LEFT JOIN dbo.Database_Space_Daily sty
		ON mf.database_id = DB_ID(sty.database_name)
		AND sty.snapshot_date = @spaceTraceYesterday
	LEFT JOIN dbo.Database_Space_Daily stw
		ON mf.database_id = DB_ID(stw.database_name)
		AND stw.snapshot_date = @spaceTracePrevWeek
	LEFT JOIN dbo.Database_Space_Daily st90
		ON mf.database_id = DB_ID(st90.database_name)
		AND st90.snapshot_date = @spaceTraceLess90
	WHERE type_desc IS NOT NULL


	/****************************************
	* Display final results
	*****************************************/
	IF EXISTS (SELECT TOP 1 1
		FROM @spaceRunOutDate d1
		INNER JOIN sys.master_files mf
			ON d1.Drive_Letter = SUBSTRING(mf.physical_name,1,1)
		LEFT JOIN (SELECT 'C' AS DriveName
				   UNION
				   SELECT 'D' AS DriveName
				   UNION
				   SELECT DriveName FROM sys.dm_io_cluster_shared_drives) c
			ON d1.Drive_Letter = c.DriveName
		WHERE c.DriveName IS NOT NULL OR NOT EXISTS (SELECT TOP 1 1 FROM sys.dm_io_cluster_shared_drives))
	BEGIN
		SELECT '*** Free disk space report:'
		
		SELECT 'Drives Running Out of Space'
		SELECT Drive_Letter, CONVERT(varchar(10), runOutDate, 101) AS runOutDate, currFreeSpace AS currFreeSpaceMB, yesterdayFreeSpace AS yesterdayFreeSpaceMB, currFreeSpace - yesterdayFreeSpace AS ChangeFromYesterday, prevWKFreeSpace AS prevWKFreeSpaceMB, currFreeSpace - prevWKFreeSpace AS ChangeFromPrevWK
		FROM @spaceRunOutDate d1
		LEFT JOIN (SELECT 'C' AS DriveName
				   UNION
				   SELECT 'D' AS DriveName
				   UNION
				   SELECT DriveName FROM sys.dm_io_cluster_shared_drives) c
			ON d1.Drive_Letter = c.DriveName
		WHERE c.DriveName IS NOT NULL OR NOT EXISTS (SELECT TOP 1 1 FROM sys.dm_io_cluster_shared_drives)
		AND currFreeSpace IS NOT NULL
		ORDER BY Drive_Letter
		
		SELECT 'Database and Log Changed File Size'
		SELECT Drive_Letter, DB, type_desc, currDBFileSizeGB, yesterdayDBFileSizeGB, FileChangeFromYesterday,
			prevWkDBFileSizeGB, FileChangeFromPrevWK, FileSizeLess90
		FROM @databasesChanged
		ORDER BY Drive_Letter, DB
		
		SELECT 'Databases Changed Data Size'
		SELECT Drive_Letter, DB, type_desc, currDBDataSizeGB, yesterdayDBDataSizeGB, DataChangeFromYesterday,
			prevWkDBDataSizeGB, DataChangeFromPrevWK, DataSizeLess90
		FROM @databasesChanged
		WHERE currDBDataSizeGB IS NOT NULL
		ORDER BY Drive_Letter, DB
		
		SELECT 'Top 20 Changed Tables'
		SELECT DISTINCT TOP 20 dc.Drive_Letter, dc.DB, CAST(tc.table_name AS VARCHAR(50)) AS table_name, ts.reserved_KB AS currTablesizeKB
			, tsy.reserved_KB AS yesterdayTableSizeKB, ts.reserved_KB - tsy.reserved_KB AS ChangeFromYesterdayKB, tsw.reserved_KB AS prevWKTableSizeKB
			, ts.reserved_KB - tsw.reserved_KB AS ChangeFromPrevWKKB
		FROM @databasesChanged dc
		INNER JOIN Table_Catalog tc
			ON dc.DB = tc.database_name
			AND tc.obsolete_date IS NULL
		INNER JOIN Table_Space ts
			ON tc.table_id = ts.table_id
			AND DATEADD(DAY, DATEDIFF(DAY, 0, ts.snapshot_time), 0) = @snapshotTimeCurr
		INNER JOIN  Table_Space tsy
			ON tc.table_id = tsy.table_id
			AND DATEADD(DAY, DATEDIFF(DAY, 0, tsy.snapshot_time), 0) = @snapshotTimeYesterday
		INNER JOIN  Table_Space tsw
			ON tc.table_id = tsw.table_id
			AND DATEADD(DAY, DATEDIFF(DAY, 0, tsw.snapshot_time), 0) = @snapshotTimePrevWeek
		WHERE ts.reserved_KB - tsw.reserved_KB > 0
		ORDER BY ts.reserved_KB - tsw.reserved_KB DESC
	END
END

