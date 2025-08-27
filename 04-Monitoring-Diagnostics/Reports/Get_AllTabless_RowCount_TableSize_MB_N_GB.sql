/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsibility of the Author; the executor is solely responsible.
*/

/*
Name: Get_AllTabless_RowCount_TableSize_MB_N_GB.sql
Description :
    - Retrieves row counts for all user tables in the current database.
    - Reports total and used space for each table in KB, MB, and GB units.
    - Helps in capacity planning, identifying large/heavy tables, and monitoring data growth trends.
Execution Instruction:
    - Run in the target database context where you want to analyze tables.
    - Ensure access to sys.objects, sys.partitions, and sys.allocation_units.
    - Review results to plan indexing, partitioning, or archiving strategies for large tables.
*/


SELECT so.name as Table_Name
	,MAX(sp.rows) as Total_Rows
	,CAST(MAX(sp.rows)/1000000.0 AS NUMERIC(18, 2)) as Total_Rows_Million
	,SUM(au.total_pages)* 8 AS KB_TotalSpace
   , SUM(au.used_pages)* 8 AS KB_UsedSpace
    ,CAST(SUM(au.total_pages)*8/1024.00 AS NUMERIC(18, 2)) AS MB_TotalSpace
    ,CAST(SUM(au.used_pages)*8/1024.00 AS NUMERIC(18, 2)) AS MB_UsedSpace
    ,CAST(SUM(au.total_pages)*8/(1024.00*1024.00) AS NUMERIC(18, 2)) AS GB_TotalSpace
    ,CAST(SUM(au.used_pages)*8/(1024.00*1024.00) AS NUMERIC(18, 2)) AS GB_UsedSpace    
FROM sys.objects as SO 
INNER JOIN sys.partitions AS sp ON SO.object_id = sp.object_id
INNER JOIN sys.allocation_units AS au ON sp.partition_id = au.container_id
WHERE so.type='U'
GROUP BY SO.name
HAVING MAX(sp.rows) <> 0
ORDER BY MAX(sp.rows) DESC;

