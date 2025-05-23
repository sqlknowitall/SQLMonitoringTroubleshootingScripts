USE [Archer]
GO
ALTER TABLE CounterData ALTER COLUMN counterValue FLOAT
ALTER TABLE CounterData ALTER COLUMN CounterDateTime DATETIME

/****** Object:  StoredProcedure [dbo].[usp_Non_SQL_CPU_consumption]    Script Date: 5/17/2018 2:09:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure  [dbo].[usp_Non_SQL_CPU_consumption]
as
begin
		declare @t_DisplayMessage nvarchar(1256)
		declare @t_BeginTime datetime
		declare @t_EndTime datetime
		declare @t_IncTime datetime
		declare @t_avg decimal (38,2)
		declare @t_min decimal (38,2)
		declare @t_max decimal (38,2)
		declare @is_Rulehit int
		declare @cpuCount int
		declare @message_Number int
		declare @CPU_threshold decimal (38,2)
		declare @T_CounterDateTime nvarchar(256)
	    declare @t_AvgValue int
	    declare @counter int
	    declare @SQLcpuCount int
	    declare @TotalcpuCount int
		declare @NonSQLCPU_threshold decimal (38,2)
		declare @SQLCPU_threshold decimal (38,2)
			set @SQLcpuCount = 16
			set @NonSQLCPU_threshold = 80.0		
			set @SQLCPU_threshold = 50.0
			set @counter = 0
			set @CPU_threshold = 80.0
			set @TotalcpuCount = 1
		
			set @is_Rulehit = 0
			set @cpuCount = 1
			set @t_DisplayMessage = ' Temp'
			set @message_Number = 1
			
			set @t_avg = 0
			set @t_min = 0
			set @t_max = 0
			set @SQLcpuCount = 1
		Create table #tmp (cnt_avg int, b_CounterDateTime datetime, e_CounterDateTime datetime,Outmsg varchar(100))
		Create table #tmpCounterDateTime (CounterDateTime varchar(100))
		 
		IF EXISTS ( SELECT * FROM sysobjects WHERE name = ltrim(rtrim('CounterData')))
		begin
			 
			select   @SQLcpuCount  =   (count( distinct InstanceName)-1)
			from counterdata dat inner join counterdetails dl on dat.counterid = dl.counterid 
			where dl.objectname in ('Processor' )
		 End 	
		IF EXISTS ( SELECT * FROM sysobjects WHERE name = ltrim(rtrim('CounterData')))
			begin
				insert into #tmpCounterDateTime (CounterDateTime) select CounterDateTimeTotal from (
								select cast(CounterDateTime as  datetime) CounterDateTimeTotal
								   from counterdata dat inner join counterdetails dli on dat.counterid = dli.counterid  
                                   where dli.objectname in ('Process' ) --'physicaldisk','Processor'
                                  and  dli.countername in ( '% User Time') 
                                   and dli.InstanceName like '%_Total%'
                                    and    counterValue  >= @NonSQLCPU_threshold 
                                  )  a1,
                                  (
                                  select  cast(CounterDateTime as  datetime) CounterDateTimeSQL
							      from counterdata dat inner join counterdetails dli on dat.counterid = dli.counterid  
                                   where dli.objectname in ('Process' ) --'physicaldisk','Processor'
                                  and  dli.countername in ( '% User Time') 
                                   and dli.InstanceName like '%SQLservr%'
                                    and counterValue  <= @SQLCPU_threshold 
								 )  b
								 where cast(a1.CounterDateTimeTotal as  datetime) = cast(b.CounterDateTimeSQL as datetime)

								 
			end

		select  @is_Rulehit = COUNT(*) from #tmpCounterDateTime
		if ( @is_Rulehit > 0)
		begin
		    				declare C_CounterDateTime cursor 
                            for select 
                                  CounterDateTime  
                                   from #tmpCounterDateTime
 
                            open C_CounterDateTime
                            fetch next from C_CounterDateTime into @T_CounterDateTime
                            while (@@fetch_status = 0)
                            Begin
									 
									      
                               select @t_AvgValue= avg(a1.counterValue)/@SQLcpuCount 
 
                                            from (
										select cast(counterValue as decimal (38,2)) counterValue ,CounterDateTime
										   from counterdata dat inner join counterdetails dli on dat.counterid = dli.counterid  
										   where dli.objectname in ('Process' ) --'physicaldisk','Processor'
										  and  dli.countername in ( '% User Time') 
										   and dli.InstanceName like '%_Total%'
											and    counterValue   >= @NonSQLCPU_threshold 
											and CounterDateTime between (cast(@T_CounterDateTime  as datetime) - '00:01:30')  and (cast(@T_CounterDateTime  as datetime) + '00:01:30') 
										  )  a1,
										  (
										  select  cast(counterValue as decimal (38,2)) counterValue,CounterDateTime
										  from counterdata dat inner join counterdetails dli on dat.counterid = dli.counterid  
										   where dli.objectname in ('Process' ) --'physicaldisk','Processor'
										  and  dli.countername in ( '% User Time') 
										   and dli.InstanceName like '%SQLservr%'
											and counterValue  <= @SQLCPU_threshold 
											and CounterDateTime between (cast(@T_CounterDateTime  as datetime) - '00:01:30')  and (cast(@T_CounterDateTime  as datetime) + '00:01:30') 
										 )  b
									where cast(a1.CounterDateTime as  datetime) = cast(b.CounterDateTime as datetime)
								 
									          
                                         if (@t_AvgValue > @CPU_threshold)
                                         begin
                                                      insert into #tmp values(@t_AvgValue,(cast(@T_CounterDateTime  as datetime) - '00:01:30')  , (cast(@T_CounterDateTime  as datetime) + '00:01:30') ,'Non-SQL CPU consumption was more than  '+ rtrim(cast (@t_AvgValue as char(5))) +'% for an extended period of time')
                                         end
                            fetch next from C_CounterDateTime into @T_CounterDateTime
                            end
                            close C_CounterDateTime
                            deallocate C_CounterDateTime
                            select  @is_Rulehit = COUNT(*) from #tmp 
							if ( @is_Rulehit > 0) 
								begin 
									update tbl_AnalysisSummary
										set [Status] = 1
										where Name = 'usp_Non_SQL_CPU_consumption'
								end 
					 
		end
		drop table #tmp
		drop table #tmpCounterDateTime
end