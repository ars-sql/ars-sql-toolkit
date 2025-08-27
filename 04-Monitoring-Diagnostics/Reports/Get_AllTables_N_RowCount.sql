/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsibility of the Author; the executor is solely responsible.
*/

/*
Name: Get_AllTables_N_RowCount.sql
Description :
    - Retrieves all user tables in the current database with their total row count.
    - Provides row counts both in absolute numbers and in millions.
    - Useful for capacity planning, data growth analysis, and monitoring large tables.
Execution Instruction:
    - Run in the target database context where you want to count rows.
    - Ensure access to sys.objects and sys.partitions catalog views.
    - Review output to identify large/heavy tables that may need partitioning, indexing, or archiving.
*/


SELECT so.name as Table_Name
	,MAX(sp.rows) as Total_Rows
	,CAST(MAX(sp.rows)/1000000.0 AS NUMERIC(18, 2)) as Total_Rows_Million
FROM sys.objects as SO 
INNER JOIN sys.partitions AS sp ON SO.object_id = sp.object_id
WHERE so.type='U'
GROUP BY SO.name
--HAVING MAX(sp.rows) <> 0
ORDER BY MAX(sp.rows) DESC;

