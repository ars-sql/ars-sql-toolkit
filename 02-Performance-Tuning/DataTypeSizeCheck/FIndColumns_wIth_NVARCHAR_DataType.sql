/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
    - This script creates and populates Z_ARS_Optimization.dbo.tbl_Analysis_NVARCHAR for analysis purposes.
*/

/*
Name: FIndColumns_wIth_NVARCHAR_DataType.sql
Description :
    - Identifies all NVARCHAR columns across user tables.
    - Captures maximum defined length and actual maximum length used in data.
    - Helps DBAs optimize schema by right-sizing NVARCHAR columns to reduce memory and storage overhead.
Execution Instruction:
    - Before execution: Ensure database Z_ARS_Optimization exists or adjust schema references accordingly.
    - After execution: Query [Z_ARS_Optimization.dbo.tbl_Analysis_NVARCHAR] to review NVARCHAR column usage and optimization opportunities.
*/

set nocount on
go
IF EXISTS(SELECT 1 FROM Z_ARS_Optimization.dbo.tbl_Analysis_NVARCHAR)
	DROP TABLE Z_ARS_Optimization.dbo.tbl_Analysis_NVARCHAR

	go

CREATE TABLE  Z_ARS_Optimization.dbo.tbl_Analysis_NVARCHAR (
	ROW_ID INT IDENTITY,
	TABLE_NAME VARCHAR(100),
	COLUMN_NAME VARCHAR(100),
	LENGTH_MAX_VALUE BIGINT,
	T_QUERY VARCHAR(8000),
	CHARACTER_MAXIMUM_LENGTH SMALLINT
	)
INSERT INTO Z_ARS_Optimization.dbo.tbl_Analysis_NVARCHAR
--select TABLE_NAME,COLUMN_NAME,0 , 'SELECT MAX(' + COLUMN_NAME + ') FROM '+ TABLE_NAME +''
select top 100 PERCENT TABLE_NAME,COLUMN_NAME,0 
,'UPDATE Z_ARS_Optimization.dbo.tbl_Analysis_NVARCHAR SET LENGTH_MAX_VALUE = (SELECT LEN(MAX([' + COLUMN_NAME + '])) FROM ['+ TABLE_NAME +']) WHERE TABLE_NAME = '''+ TABLE_NAME +''' AND COLUMN_NAME = ''' + COLUMN_NAME + ''''
,CHARACTER_MAXIMUM_LENGTH
from INFORMATION_SCHEMA.COLUMNS 
where TABLE_NAME in (select TABLE_NAME from INFORMATION_SCHEMA.TABLES  where TABLE_TYPE ='BASE TABLE' )
and DATA_TYPE in ('NVARCHAR')
and TABLE_NAME != 'log'
--AND TABLE_NAME='land2016hld'
order by TABLE_NAME,COLUMN_NAME

Declare @curr_counter int,
@max_counter int
,@sql NVARCHAR(MAX)

SELECT @curr_counter = MIN(ROW_ID),@max_counter = MAX(ROW_ID)  FROM Z_ARS_Optimization.dbo.tbl_Analysis_NVARCHAR
WHILE (@curr_counter < @max_counter)
BEGIN
	-- Access the data
	SELECT @sql = T_QUERY FROM Z_ARS_Optimization.dbo.tbl_Analysis_NVARCHAR WHERE ROW_ID = @curr_counter
	-- Main Business Logic
	--UPDATE Z_ARS_Optimization.dbo.tbl_Analysis_NVARCHAR SET MAX_VALUE = (SELECT MAX(AccountID) FROM AccountCompAccessTracking) WHERE TABLE_NAME = 'AccountCompAccessTracking' AND COLUMN_NAME = 'AccountID'
	--SELECT @sql
	--print 'Before'
	print '>>>'+ cast(@curr_counter as varchar(10))
	EXEC sp_executesql @sql;
	--print 'After'
	--Create the counter
	SET @curr_counter += 1
END


SELECT row_id,TABLE_NAME,COLUMN_NAME,LENGTH_MAX_VALUE,CHARACTER_MAXIMUM_LENGTH--,T_QUERY
FROM Z_ARS_Optimization.dbo.tbl_Analysis_NVARCHAR
--where ROW_ID = 346
order by LENGTH_MAX_VALUE desc
--order by ROW_ID 