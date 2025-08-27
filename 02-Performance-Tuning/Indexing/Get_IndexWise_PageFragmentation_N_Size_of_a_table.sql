/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Get_IndexWise_PageFragmentation_N_Size_of_a_table.sql
Description :
    - Retrieves index fragmentation percentage and index size (KB/MB) for a specific table.
    - Uses sys.dm_db_index_physical_stats to measure fragmentation.
    - Helps DBAs decide whether to rebuild or reorganize indexes for the target table.
Execution Instruction:
    - Before execution: Set @table_name variable to the target table.
    - After execution: Review fragmentation % and size metrics to plan index maintenance.
*/


Declare @table_Name varchar(100) = 'Accounts'

SELECT Database_Name,
	AA.Index_Name,
	AA.Table_Name,
	AA.index_type_desc,
	AA.Avg_Page_Fragmentation,
	--AA.avg_page_space_used_in_percent,
	AA.Page_Counts,
	BB.Total_Space_KB,
	BB.Total_Space_MB
FROM 
(
	SELECT DB_NAME(DPS.database_id) as Database_Name,
	OBJECT_NAME(DPS.object_id) as Table_Name,
	SI.name as Index_Name,DPS.index_type_desc,
	DPS.avg_fragmentation_in_percent as Avg_Page_Fragmentation,
	avg_page_space_used_in_percent,
	PAGE_COUNT AS Page_Counts
	FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,N'LIMITED') AS DPS
	INNER JOIN sys.indexes as SI
	on DPS.object_id = SI.object_id AND DPS.index_id = SI.index_id
	WHERE OBJECT_NAME(DPS.object_id) = @table_Name
) AS AA
LEFT JOIN 
(
	SELECT  
		st.name as Table_Name
		,si.name as Index_Name
		,si.type_desc as Index_Type
		,SUM(sau.total_pages)*8 as Total_Space_KB
		,CAST((SUM(sau.total_pages)*8)/1000.0 AS NUMERIC(10,2)) as Total_Space_MB
	FROM sys.tables as st
	INNER JOIN sys.schemas  as ss ON st.schema_id = ss.schema_id
	INNER JOIN sys.indexes as si ON st.object_id = si.object_id
	INNER JOIN sys.partitions as sp on st.object_id = sp.object_id and si.index_id = sp.index_id
	INNER JOIN sys.allocation_units as sau on sp.partition_id = sau.container_id
	WHERE st.name NOT LIKE 'dt%'
	and st.is_ms_shipped = 0
	AND si.object_id > 255
	AND st.name = @table_Name
	GROUP BY ss.name,st.name, si.name,si.type_desc,sp.rows
) AS BB
ON AA.Table_Name = BB.Table_Name
AND AA.Index_Name = BB.Index_Name
--order by aa.Table_Name ,aa.Index_Name
ORDER BY Avg_Page_Fragmentation DESC