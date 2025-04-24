USE [master];
GO

IF DATABASEPROPERTY (N'recordanatomy', 'Version') > 0 DROP DATABASE [RecordAnatomy];
GO
CREATE DATABASE [RecordAnatomy];
GO

USE [RecordAnatomy];
GO

CREATE TABLE [example] (colID INT PRIMARY KEY CLUSTERED, [destination] VARCHAR(100), [activity] VARCHAR(100), [duration] INT);
GO

INSERT INTO [example] VALUES (20,'Banff', 'sightseeing', 5);
INSERT INTO [example] VALUES (10,'Chicago', 'sailing', 4);
GO

DBCC IND ('recordanatomy', 'example', 1); --note the PageFID and PagePID where PageType = 1
--1,320
--PageType 10 is the actual IAM page
--PageType 1 is a data page while PageType 2 would be an index page
--In this case, you'll also see that the index level is 0 for our data page indicating that the
--		current page is the root of the clustered index
GO

DBCC TRACEON(3604)--redirect output of dbcc page to console instead of error log
DBCC PAGE('recordanatomy',1,320,3) WITH TABLERESULTS --Shows row/column information well
	--Note: Rows are broken down into "slots" and columns are labeled as columns
	--also note that there are offsets within the columns noting where that columns'
	--data resides. Even though column "duration" is the 4th column, becuas it is a fixed
	--width data type it is stored earlier in the row than the 2 variable length 
	--columns.
	--Row Structure: https://aboutsqlserver.com/2013/10/15/sql-server-storage-engine-data-pages-and-data-rows/
DBCC PAGE('recordanatomy',1,320,2) WITH TABLERESULTS --Last 3 rows show the slot offsets
	--Slot 0 is the first row in order of index, but starts at 134
	--Slot 1 is the second row in the index, but was inserted first into the table and starts at byte 97 (after 96 byte header)

DBCC TRACEOFF(3604)