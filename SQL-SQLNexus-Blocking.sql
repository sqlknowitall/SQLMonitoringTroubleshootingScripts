SELECT blocking_session_id, COUNT(1) AS countbp
FROM dbo.tbl_REQUESTS
WHERE (blocking_session_id IS NOT NULL AND blocking_session_id <> 0)
GROUP BY blocking_session_id
HAVING COUNT(1) > 4
UNION ALL
SELECT blocking_session_id, COUNT(1) AS countbp
FROM dbo.tbl_REQUESTS
WHERE blocking_session_id = 5106
GROUP BY blocking_session_id
ORDER BY countbp DESC


SELECT * FROM [dbo].[tbl_REQUESTS] WHERE session_id IN (4325, 3412, 4633, 5106)

SET NOCOUNT ON
GO
SELECT R.session_id, R.blocking_session_id
INTO #T
FROM dbo.tbl_REQUESTS R
GO
WITH BLOCKERS (session_id, blocking_session_id, LEVEL)
AS
(
SELECT R.session_id,
R.blocking_session_id,
CAST (REPLICATE ('0', 4-LEN (CAST (session_id AS VARCHAR))) + CAST (session_id AS VARCHAR) AS VARCHAR (1000)) AS LEVEL
FROM #T R
WHERE (R.blocking_session_id = 0 OR R.blocking_session_id = R.session_id)
AND EXISTS (SELECT * FROM #T R2 WHERE R2.blocking_session_id = R.session_id AND R2.blocking_session_id <> R2.session_id)
UNION ALL
SELECT R.session_id,
R.blocking_session_id,
CAST (BLOCKERS.LEVEL + RIGHT (CAST ((1000 + R.session_id) AS VARCHAR (100)), 4) AS VARCHAR (1000)) AS LEVEL
FROM #T AS R
INNER JOIN BLOCKERS ON R.blocking_session_id = BLOCKERS.session_id WHERE R.blocking_session_id > 0 AND R.blocking_session_id <> R.session_id
)
SELECT N'    ' + REPLICATE (N'|         ', LEN (LEVEL)/4 - 1) +
CASE WHEN (LEN(LEVEL)/4 - 1) = 0
THEN 'HEAD -  '
ELSE '|------  ' END
+ CAST (session_id AS NVARCHAR (10)) AS BLOCKING_TREE
FROM BLOCKERS ORDER BY LEVEL ASC
GO
DROP TABLE #T
GO

