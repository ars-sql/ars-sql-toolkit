/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsibility of the Author; the executor is solely responsible.
    - This script performs ALTER TABLE and ALTER INDEX REBUILD operations, which can cause blocking, high I/O, and transaction log growth.
*/

/*
Name: Rebuild_A_Table_N_All_Index.sql
Description :
    - Rebuilds a specified table and all associated indexes in the current database.
    - Creates a helper table (tbl_TABLE_N_INDEX_REBUILD) to store and loop through dynamic ALTER INDEX commands.
    - Improves query performance and removes fragmentation by rebuilding indexes.
    - Reports table and index space usage (total, used, unused) before and after rebuild.
Execution Instruction:
    - Modify @myTableName to the target table name before execution.
    - Ensure sufficient free space and transaction log capacity (index rebuild is resource-intensive).
    - Run during a maintenance window to minimize impact on users (locks and blocking possible).
    - After execution, review the output space-usage report to validate improvements.
*/


use PDCDev
GO
/*
sp_spaceused 'AccountHistory'
go
sp_spaceused 'Accounts2016hld_V1'

ALTER TABLE AccountHistory REBUILD
ALTER INDEX I_TaxYear ON AccountHistory REBUILD;

DBCC CLEANTABLE (PDCDev,'dbo.Accounts2016hld');  
DBCC CLEANTABLE (PDCDev,'dbo.Accounts2016hld', 0)  WITH NO_INFOMSGS; 
*/
Declare @myTableName VARCHAR(100) = 'Accounts'
Declare @curr_counter int,
@max_counter int
,@sql NVARCHAR(MAX) = 'ALTER TABLE '+ @myTableName +' REBUILD'

print '>>>'+ cast(@curr_counter as varchar(10))  + @sql
print 'Record 0' + ' >>> ' + @sql
EXEC sp_executesql @sql

-- Check and Drop table used for processing		
IF OBJECT_ID('Z_ARS_Optimization.dbo.tbl_TABLE_N_INDEX_REBUILD') IS NOT NULL
	DROP TABLE Z_ARS_Optimization.dbo.tbl_TABLE_N_INDEX_REBUILD

SELECT ROW_NUMBER() OVER (ORDER BY  TableName,IndexName) as ROW_ID,*,'ALTER INDEX '+ IndexName +' ON '+ TableName +' REBUILD;' as SQL_QUERY
INTO Z_ARS_Optimization.dbo.tbl_TABLE_N_INDEX_REBUILD
FROM 
(
	SELECT  TOP 100 PERCENT st.name as TableName, si.name as IndexName,si.type_desc as IndexType,sp.rows as TotRows
	,SUM(sau.total_pages)*8 as Total_Space_KB
	,SUM(sau.used_pages)*8 as Used_Space_KB
	,(SUM(sau.total_pages)-SUM(sau.used_pages))*8 as  Unused_Space_KB
	FROM sys.tables as st
	INNER JOIN sys.schemas  as ss ON st.schema_id = ss.schema_id
	INNER JOIN sys.indexes as si ON st.object_id = si.object_id
	INNER JOIN sys.partitions as sp on st.object_id = sp.object_id and si.index_id = sp.index_id
	INNER JOIN sys.allocation_units as sau on sp.partition_id = sau.container_id
	WHERE st.name NOT LIKE 'dt%'
	and st.is_ms_shipped = 0
	AND si.object_id > 255
	AND st.name = @myTableName
	GROUP BY ss.name,st.name, si.name,si.type_desc,sp.rows
	ORDER BY ss.name,st.name, si.name,si.type_desc,sp.rows
) AS ARS
--


SELECT @curr_counter = MIN(ROW_ID),@max_counter = MAX(ROW_ID)  FROM Z_ARS_Optimization.dbo.tbl_TABLE_N_INDEX_REBUILD
WHILE (@curr_counter < @max_counter)
BEGIN
	-- Access the data
	SELECT @sql = SQL_QUERY FROM Z_ARS_Optimization.dbo.tbl_TABLE_N_INDEX_REBUILD WHERE ROW_ID = @curr_counter
	-- Main Business Logic
	--print 'Before'
	print 'Record '+ cast(@curr_counter as varchar(10)) + ' >>> ' + @sql
	BEGIN TRY
		EXEC sp_executesql @sql;
	END TRY
	BEGIN CATCH
		print '		Error Found >>> ' + @sql
	END CATCH
	--print 'After'
	--Create the counter
	SET @curr_counter += 1
END

	

	SELECT  TOP 100 PERCENT st.name as TableName, si.name as IndexName,si.type_desc as IndexType,sp.rows as TotRows
	,SUM(sau.total_pages)*8 as Total_Space_KB
	,SUM(sau.used_pages)*8 as Used_Space_KB
	,(SUM(sau.total_pages)-SUM(sau.used_pages))*8 as  Unused_Space_KB
	FROM sys.tables as st
	INNER JOIN sys.schemas  as ss ON st.schema_id = ss.schema_id
	INNER JOIN sys.indexes as si ON st.object_id = si.object_id
	INNER JOIN sys.partitions as sp on st.object_id = sp.object_id and si.index_id = sp.index_id
	INNER JOIN sys.allocation_units as sau on sp.partition_id = sau.container_id
	WHERE st.name NOT LIKE 'dt%'
	and st.is_ms_shipped = 0
	AND si.object_id > 255
	AND st.name = @myTableName
	GROUP BY ss.name,st.name, si.name,si.type_desc,sp.rows
	ORDER BY ss.name,st.name, si.name,si.type_desc,sp.rows