/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
	- Do NOT run or apply these results directly in a Production Environment.
	- Always validate in a lower environment first (Dev / QA / UAT).
	- Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/
/*
Name: Find_MissingIndexQuery_TopN_SinceLastSQLServerStart.sql
Description	: 
	- Finds unused nonclustered indexes since the SQL Server last restarted.
	- Helps identify indexes safe to drop to reduce storage and update cost.
	- Also provides ready-to-use DROP INDEX statements.
Manual Checks Before Dropping Indexes
	- How old is the SQL Server uptime?
	- Are these indexes used in any off-peak or ad-hoc queries?
	- Check execution plans– do they ever use these indexes?
	- Verify with extended monitoring(e.g., Query Store, DMVs over time)
	- Check with application teams before dropping – might be rarely used but important	
*/

Declare @sql_start_date as DateTIme 
SELECT @sql_start_date = sqlserver_start_time FROM sys.dm_os_sys_info

select 
	@sql_start_date as SQL_Server_Start_DateTime,
	so.create_date as Index_Create_Date,
	so.object_id,
	ss.name as SchemaName,
	so.name as TableName,
	si.name as IndexName,
	so.name + '_' + si.name as Table_N_Index,
	si.index_id,
	ius.user_seeks -- Number of seeks by user queries.
	+ ius.user_scans -- The number of scans performed by the user query
	+ ius.user_lookups 
	as user_seeks_scans_and_lookups, 
	'DROP INDEX ['+ si.name +'] on ['+ ss.name +'].['+ so.name +']' as index_drop_satement,
	ius.user_updates, -- Number of updates by user queries. This includes Insert, Delete, and Updates representing number of operations done not the actual rows affected. For example, if you delete 1000 rows in one statement, this count increments by 1
	ius.* 
from sys.dm_db_index_usage_stats as ius
inner join sys.indexes as si on ius.index_id = si.index_id AND ius.OBJECT_ID = si.OBJECT_ID
inner join sys.objects as so on ius.object_id = so.object_id
INNER JOIN sys.schemas as ss ON so.schema_id = ss.schema_id
WHERE ius.database_id = DB_ID()
AND si.type_desc = 'NONCLUSTERED'
and si.is_primary_key = 0
and si.is_unique_constraint = 0
-- INDEX NOT USED SINCE LAST START OF SQL SERVER
and (ius.user_seeks + ius.user_scans + ius.user_lookups) <= 0
and so.create_date <= @sql_start_date
ORDER BY TableName,IndexName