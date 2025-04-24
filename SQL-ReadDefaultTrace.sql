DECLARE   @filename nvarchar(1000);
 
-- Get the name of the current default trace
SELECT   @filename = cast(value as nvarchar(1000))
FROM   ::fn_trace_getinfo(default)
WHERE   traceid = 1 and   property = 2;
 
-- view current trace file
SELECT   *
FROM   ::fn_trace_gettable(@filename, default) AS ftg 
INNER   JOIN sys.trace_events AS te ON ftg.EventClass = te.trace_event_id  
  ORDER BY   ftg.StartTime
