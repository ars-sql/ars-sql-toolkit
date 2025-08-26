1. Shifting_MDF_N_LDF_File_of_a_database.sql
	1. Moves a database MDF and LDF files to a new location.
	2. First checks current file paths using sys.database_files.
	3. Takes the database offline, updates file paths with MODIFY FILE.
	4. Finally, brings the database back online after physical file movement.
