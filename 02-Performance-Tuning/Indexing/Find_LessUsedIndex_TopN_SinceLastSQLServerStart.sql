/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
	- Do NOT run or apply these results directly in a Production Environment.
	- Always validate in a lower environment first (Dev / QA / UAT).
	- Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/
/*
Name: Find_LessUsedIndex_TopN_SinceLastSQLServerStart.sql
Description	: 
	- Shows the least-used nonclustered indexes in the current database since last SQL Server restart.
	- Helps decide which indexes might be dropped based on low usage. 
	- Gives DROP INDEX statements for easy cleanup.
Manual Checks Before Dropping Indexes
	- Check SQL Server uptime – short uptime = misleading results.
	- Validate usage patterns – maybe used in rare or monthly reports.
	- Check execution plans and Query Store – is the index helping silently?
	- Review index creation reason – was it created for performance tuning or specific needs?
	- Involve developers – get confirmation if index is really unused.	
*/


select top 25
	(SELECT sqlserver_start_time FROM sys.dm_os_sys_info ) as SQL_Server_Start_DateTime,
	ss.name as SchemaName,
	so.name as TableName,
	si.name as IndexName,
	si.index_id,
	ius.user_seeks + ius.user_scans + ius.user_lookups as UsedCount, 
	'DROP INDEX ['+ si.name +'] on ['+ ss.name +'].['+ so.name +']',
	ius.last_user_seek as Last_Date_Seek_Operation,
	ius.last_user_scan as Last_Date_Scan_Operation,
	ius.last_user_lookup as Last_Date_LookUp_Operation
from sys.dm_db_index_usage_stats as ius
inner join sys.indexes as si on ius.index_id = si.index_id AND ius.OBJECT_ID = si.OBJECT_ID
inner join sys.objects as so on ius.object_id = so.object_id
INNER JOIN sys.schemas as ss ON so.schema_id = ss.schema_id
WHERE ius.database_id = DB_ID() -- Looking into Current Database ONly
AND si.type_desc = 'NONCLUSTERED' -- Looking for Non CLustered Key ONly
and si.is_primary_key = 0 -- Excluding Primary Key Information
and si.is_unique_constraint = 0 -- Excluding Unique Key Information
-- INDEX NOT USED SINCE LAST START OF SQL SERVER
and (ius.user_seeks + ius.user_scans + ius.user_lookups) <> 0
ORDER BY (ius.user_seeks + ius.user_scans + ius.user_lookups) ASC