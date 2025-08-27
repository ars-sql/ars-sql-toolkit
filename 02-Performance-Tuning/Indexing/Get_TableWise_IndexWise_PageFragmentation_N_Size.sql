/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
    - This script generates ALTER INDEX REBUILD statements. Executor is solely responsible for applying them.
*/

/*
Name: Get_TableWise_IndexWise_PageFragmentation_N_Size.sql
Description :
    - Retrieves fragmentation details and size information for all indexes in the current database.
    - Lists indexes with fragmentation >= 30% (excluding heaps).
    - Generates ALTER INDEX REBUILD statements for fixing fragmentation.
Execution Instruction:
    - Before execution: Ensure you run against the intended database; adjust thresholds (e.g., fragmentation %, space filter) as needed.
    - After execution: Review generated ALTER INDEX statements before executing them in Production.
*/


SELECT Database_Name,
	AA.Table_Name,
	AA.Index_Name,
	AA.index_type_desc,
	AA.Avg_Page_Fragmentation,
	--AA.avg_page_space_used_in_percent,
	AA.Page_Counts,
	BB.Total_Space_KB,
	BB.Total_Space_MB,
	'ALTER INDEX ['+ AA.Index_Name +'] ON [dbo].['+ AA.Table_Name +'] 
	REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)'
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
	GROUP BY ss.name,st.name, si.name,si.type_desc,sp.rows
) AS BB
ON AA.Table_Name = BB.Table_Name
AND AA.Index_Name = BB.Index_Name
where AA.Avg_Page_Fragmentation >=30
and index_type_desc <> 'HEAP'
--and BB.Total_Space_MB > 300
--order by aa.Table_Name ,aa.Index_Name
ORDER BY Total_Space_MB asc