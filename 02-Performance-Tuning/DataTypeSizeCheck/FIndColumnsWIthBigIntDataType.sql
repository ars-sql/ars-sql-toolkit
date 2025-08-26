set nocount on
go
--IF EXISTS(SELECT 1 FROM Z_ARS_Optimization.dbo.tbl_Analysis)
	DROP TABLE Z_ARS_Optimization.dbo.tbl_Analysis

	go

CREATE TABLE  Z_ARS_Optimization.dbo.tbl_Analysis (
	ROW_ID INT IDENTITY,
	TABLE_NAME VARCHAR(100),
	COLUMN_NAME VARCHAR(100),
	MAX_VALUE BIGINT,
	T_QUERY VARCHAR(8000)
	)
INSERT INTO Z_ARS_Optimization.dbo.tbl_Analysis
--select TABLE_NAME,COLUMN_NAME,0 , 'SELECT MAX(' + COLUMN_NAME + ') FROM '+ TABLE_NAME +''
select top 100 PERCENT TABLE_NAME,COLUMN_NAME,0 
,'UPDATE Z_ARS_Optimization.dbo.tbl_Analysis SET MAX_VALUE = (SELECT MAX([' + COLUMN_NAME + ']) FROM ['+ TABLE_NAME +']) WHERE TABLE_NAME = '''+ TABLE_NAME +''' AND COLUMN_NAME = ''' + COLUMN_NAME + ''''
from INFORMATION_SCHEMA.COLUMNS 
where TABLE_NAME in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES  where TABLE_TYPE ='BASE TABLE' )
and DATA_TYPE in ('BIGINT')
and TABLE_NAME != 'log'
order by TABLE_NAME,COLUMN_NAME

Declare @curr_counter int,
@max_counter int
,@sql NVARCHAR(MAX)

SELECT @curr_counter = MIN(ROW_ID),@max_counter = MAX(ROW_ID)  FROM Z_ARS_Optimization.dbo.tbl_Analysis
WHILE (@curr_counter < @max_counter)
BEGIN
	-- Access the data
	SELECT @sql = T_QUERY FROM Z_ARS_Optimization.dbo.tbl_Analysis WHERE ROW_ID = @curr_counter
	-- Main Business Logic
	--UPDATE Z_ARS_Optimization.dbo.tbl_Analysis SET MAX_VALUE = (SELECT MAX(AccountID) FROM AccountCompAccessTracking) WHERE TABLE_NAME = 'AccountCompAccessTracking' AND COLUMN_NAME = 'AccountID'
	--SELECT @sql
	--print 'Before'
	print '>>>'+ cast(@curr_counter as varchar(10))
	EXEC sp_executesql @sql;
	--print 'After'
	--Create the counter
	SET @curr_counter += 1
END


SELECT row_id,TABLE_NAME,COLUMN_NAME,MAX_VALUE--,T_QUERY
FROM Z_ARS_Optimization.dbo.tbl_Analysis
--where ROW_ID = 346
order by MAX_VALUE desc
--order by ROW_ID 