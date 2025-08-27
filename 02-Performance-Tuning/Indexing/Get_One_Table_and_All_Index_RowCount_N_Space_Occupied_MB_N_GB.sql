/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Get_One_Table_and_All_Index_RowCount_N_Space_Occupied_MB_N_GB.sql
Description :
    - Retrieves row counts and index-level space usage (TotalSpace / UsedSpace in GB) for a specific table.
    - Helps DBAs identify largest indexes and storage distribution within a table.
    - Useful for index tuning, capacity management, and performance diagnostics.
Execution Instruction:
    - Before execution: Set @myTableName variable to the target table name.
    - After execution: Review space usage per index to plan index cleanup, tuning, or partitioning strategies.
*/

--use PDCDev
go
Declare @myTableName VARCHAR(100) = 'ASPUEComps'

SELECT  TOP 100 PERCENT st.name as TableName
	,si.name as IndexName
	,si.type_desc as IndexType
	,sp.rows as TotRows
	--,SUM(sau.total_pages)*8 as Total_Space_KB
	--,SUM(sau.used_pages)*8 as Used_Space_KB
    --,CAST(SUM(sau.total_pages)*8/1024.00 AS NUMERIC(18, 2)) AS MB_TotalSpace
    --,CAST(SUM(sau.used_pages)*8/1024.00 AS NUMERIC(18, 2)) AS MB_UsedSpace
    ,CAST(SUM(sau.total_pages)*8/(1024.00*1024.00) AS NUMERIC(18, 2)) AS GB_TotalSpace
    ,CAST(SUM(sau.used_pages)*8/(1024.00*1024.00) AS NUMERIC(18, 2)) AS GB_UsedSpace    
--	,(SUM(sau.total_pages)-SUM(sau.used_pages))*8 as  Unused_Space_KB
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
ORDER BY SUM(sau.used_pages) DESC