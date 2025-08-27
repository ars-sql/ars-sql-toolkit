Find_MissingIndexQuery_TopN_SinceLastSQLServerStart.sql: 
	- This script identifies top 25 missing index recommendations in the current database.
	- It builds ready-to-use CREATE NONCLUSTERED INDEX statements based on SQL Server’s internal suggestions.
	- It ranks them by estimated performance improvement.

Find_NeverUsedIndex_SinceLastSQLServerStart.sql
	- Finds unused nonclustered indexes since the SQL Server last restarted.
	- Helps identify indexes safe to drop to reduce storage and update cost.
	- Also provides ready-to-use DROP INDEX statements.

Find_LessUsedIndex_TopN_SinceLastSQLServerStart.sql
	- Shows the least-used nonclustered indexes in the current database since last SQL Server restart.
	- Helps decide which indexes might be dropped based on low usage. 
	- Gives DROP INDEX statements for easy cleanup.
	
Name: Rebuild_A_Table_N_All_Index.sql
	- Rebuilds a specified table and all associated indexes in the current database.
	- Creates a helper table (tbl_TABLE_N_INDEX_REBUILD) to store and loop through dynamic ALTER INDEX commands.
	- Improves query performance and removes fragmentation by rebuilding indexes.
	- Reports table and index space usage (total, used, unused) before and after rebuild.
Name: Get_Table_All_Keys_Space_Used_by_Keys.sql
	Description :
		- Returns total space used by all keys/indexes of a specified table.
		- Shows row counts, allocated space, and used space in MB and GB.
		- Helps identify large or heavy indexes for performance and storage optimization.
	Execution Instruction:
		- Before execution: Set @myTableName variable to the desired table name.
		- After execution: Review space usage results to decide on index tuning or cleanup.
Name: Get_TableWise_IndexWise_PageFragmentation_N_Size.sql
	Description :
		- Retrieves fragmentation details and size information for all indexes in the current database.
		- Lists indexes with fragmentation >= 30% (excluding heaps).
		- Generates ALTER INDEX REBUILD statements for fixing fragmentation.
	Execution Instruction:
		- Before execution: Ensure you run against the intended database; adjust thresholds (e.g., fragmentation %, space filter) as needed.
		- After execution: Review generated ALTER INDEX statements before executing them in Production.
Name: Get_One_Table_and_All_Index_RowCount_N_Space_Occupied_MB_N_GB.sql
	Description :
		- Retrieves row counts and index-level space usage (TotalSpace / UsedSpace in GB) for a specific table.
		- Helps DBAs identify largest indexes and storage distribution within a table.
		- Useful for index tuning, capacity management, and performance diagnostics.
	Execution Instruction:
		- Before execution: Set @myTableName variable to the target table name.
		- After execution: Review space usage per index to plan index cleanup, tuning, or partitioning strategies.
Name: Get_IndexWise_PageFragmentation_N_Size_of_a_table.sql
	Description :
		- Retrieves index fragmentation percentage and index size (KB/MB) for a specific table.
		- Uses sys.dm_db_index_physical_stats to measure fragmentation.
		- Helps DBAs decide whether to rebuild or reorganize indexes for the target table.
	Execution Instruction:
		- Before execution: Set @table_name variable to the target table.
		- After execution: Review fragmentation % and size metrics to plan index maintenance.
