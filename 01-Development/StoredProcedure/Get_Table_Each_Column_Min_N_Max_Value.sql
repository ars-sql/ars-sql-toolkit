/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Get_Table_Each_Column_Min_N_Max_Value.sql
Description :
    - Stored procedure that returns the minimum and maximum values for each column in a given table.
    - Supports optional parameter to restrict results to numeric columns only.
    - Useful for data profiling, ETL validation, and anomaly detection.
Execution Instruction:
    - Before execution: Ensure the target table exists and the user has SELECT permission on it.
    - After execution: Review the min/max values to validate data ranges and detect anomalies.
*/


Create OR ALTER Procedure ARS_Get_Table_Each_Column_Min_N_Max_Value(
	@Table_Name varchar(50) ,
	@Numeric_Columns char(1)= 'N'
)
AS
BEGIN
IF OBJECT_ID('tempdb.dbo.#metadata') IS NOT NULL
	DROP TABLE #metadata

create table #metadata (row_id int IDENTITY(1,1),
		table_schema varchar(5000),
		table_name varchar(5000),
		column_name varchar(5000),
		max_value varchar(max) NULL,
		min_value varchar(max) NULL,
		data_type varchar(5000)
		)

insert into #metadata(table_schema,table_name,column_name,DATA_TYPE)
select tbls.TABLE_SCHEMA,tbls.TABLE_NAME,cols.COLUMN_NAME,DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS as cols
inner join INFORMATION_SCHEMA.TABLES as tbls on cols.TABLE_SCHEMA = tbls.TABLE_SCHEMA
AND cols.TABLE_NAME = tbls.TABLE_NAME
where cols.TABLE_NAME = @Table_Name
AND DATA_TYPE NOT IN ('bit')-- MAX/MIN not work for BIT operator
AND (
		@Numeric_Columns = 'N'
	OR 
	(
		@Numeric_Columns = 'Y'
		AND DATA_TYPE not in ('nchar','char','varchar','nvarchar','ntext','uniqueidentifier','image','text','varbinary')
	)
)

Declare @updateSQL NVARCHAR(MAX)
,@curr_row_id INT
,@max_row_id INT 

SELECT 
	@curr_row_id = MIN(row_id),
	@max_row_id = MAX(row_id)
FROM #metadata

WHILE(@curr_row_id <= @max_row_id)
BEGIN
	-- Iterating CUrrent Value
	SELECT 
		@updateSQL = 
			' UPDATE #metadata
			SET 
				MIN_VALUE = (SELECT MIN('+ column_name +') FROM  ' + table_name + ')
				,MAX_VALUE = (SELECT MAX('+ column_name +') FROM  ' + table_name + ')
			WHERE row_id = ' + CAST(@curr_row_id as nvarchar(10))
	FROM #metadata
	WHERE row_id = @curr_row_id

	-- Executing DDL / DML Statement
	--PRINT @updateSQL
	EXEC sp_executesql @updateSQL; 

	-- Loop Management
	SET @curr_row_id = @curr_row_id + 1
END

SELECT 
	table_name ,
	column_name,
	data_type,
	min_value ,
	max_value 
FROM #metadata
--SELECT 'SalesViewTableBrazoria',MIN(Tax_Year), MAX(Tax_Year) FROM  SalesViewTableBrazoria
END


