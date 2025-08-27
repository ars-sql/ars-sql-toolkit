1. Shifting_MDF_N_LDF_File_of_a_database.sql
	1. Moves a database MDF and LDF files to a new location.
	2. First checks current file paths using sys.database_files.
	3. Takes the database offline, updates file paths with MODIFY FILE.
	4. Finally, brings the database back online after physical file movement.
Name: Get_All_Databases_N_SIZE_MDF_LDF.sql
	Description :
		- Retrieves current sizes (in GB) of MDF (data files) and LDF (log files) for all user databases.
		- Excludes system databases (master, model, msdb, tempdb).
		- Helps DBAs monitor file growth and perform capacity planning.
	Execution Instruction:
		- Before execution: Ensure you have appropriate access to sys.master_files.
		- After execution: Review size information for database capacity management or maintenance planning.

