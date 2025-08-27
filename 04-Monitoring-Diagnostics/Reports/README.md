Name: Get_Database_Mdf_N_Ldf_File_Size.sql
	Description :
		- Retrieves the size of all MDF (data) and LDF (log) files across all databases in the SQL Server instance.
		- Provides total instance size usage, per-database totals, and file-level details.
		- Highlights tempdb file usage separately for monitoring and troubleshooting.
	Execution Instruction:
		- Ensure you have access to sys.master_files in the master database.
		- Confirm that the script is executed with sysadmin or equivalent privileges.
		- (Optional) Modify WHERE clause to target a specific database if required.
		- Review output to identify space-heavy databases or tempdb usage.
Name: Get_AllTables_N_RowCount.sql
	Description :
		- Retrieves all user tables in the current database with their total row count.
		- Provides row counts both in absolute numbers and in millions.
		- Useful for capacity planning, data growth analysis, and monitoring large tables.
	Execution Instruction:
		- Run in the target database context where you want to count rows.
		- Ensure access to sys.objects and sys.partitions catalog views.
		- Review output to identify large/heavy tables that may need partitioning, indexing, or archiving.
Name: Get_AllTabless_RowCount_TableSize_MB_N_GB.sql
	Description :
		- Retrieves row counts for all user tables in the current database.
		- Reports total and used space for each table in KB, MB, and GB units.
		- Helps in capacity planning, identifying large/heavy tables, and monitoring data growth trends.
	Execution Instruction:
		- Run in the target database context where you want to analyze tables.
		- Ensure access to sys.objects, sys.partitions, and sys.allocation_units.
		- Review results to plan indexing, partitioning, or archiving strategies for large tables.
