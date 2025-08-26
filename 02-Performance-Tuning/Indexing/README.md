1. Find_MissingIndexQuery_TopN_SinceLastSQLServerStart.sql: 
	- This script identifies top 25 missing index recommendations in the current database.
	- It builds ready-to-use CREATE NONCLUSTERED INDEX statements based on SQL Server’s internal suggestions.
	- It ranks them by estimated performance improvement.

2. Find_NeverUsedIndex_SinceLastSQLServerStart.sql
	- Finds unused nonclustered indexes since the SQL Server last restarted.
	- Helps identify indexes safe to drop to reduce storage and update cost.
	- Also provides ready-to-use DROP INDEX statements.

3. Find_LessUsedIndex_TopN_SinceLastSQLServerStart.sql
	- Shows the least-used nonclustered indexes in the current database since last SQL Server restart.
	- Helps decide which indexes might be dropped based on low usage. 
	- Gives DROP INDEX statements for easy cleanup.
