/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Get_Table_All_Keys_Space_Used_by_Keys.sql
Description :
    - Returns total space used by all keys/indexes of a specified table.
    - Shows row counts, allocated space, and used space in MB and GB.
    - Helps identify large or heavy indexes for performance and storage optimization.
Execution Instruction:
    - Before execution: Set @myTableName variable to the desired table name.
    - After execution: Review space usage results to decide on index tuning or cleanup.
*/

Declare @myTableName VARCHAR(100) = 'Accounts'

SELECT 
		Table_Name
		,MAX(CAST(Total_Rows/1000000.0 AS NUMERIC(10,2))) as Rows_Millions
		,SUM(CAST(Total_Space_KB/1000.0 AS NUMERIC(10,2))) as Total_Space_MB
		,SUM(CAST(Total_Space_KB/1000000.0 AS NUMERIC(10,2))) as Total_Space_GB
		,SUM(CAST(Used_Space_KB/1000.0 AS NUMERIC(10,2))) as Used_Space_MB
		,SUM(CAST(Used_Space_KB/1000000.0 AS NUMERIC(10,2))) as Used_Space_GB
FROM
(
	SELECT  
		st.name as Table_Name
		,si.name as Index_Name
		,si.type_desc as Index_Type
		,sp.rows as Total_Rows
		,SUM(sau.total_pages)*8 as Total_Space_KB
		,SUM(sau.used_pages)*8 as Used_Space_KB
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
) AS AA
GROUP BY Table_Name


