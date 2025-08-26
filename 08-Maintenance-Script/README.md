1. Shrink_DataBase_Script.sql
	- Creates a table ARS_SHRINK_DATABASE_STATUS to log shrink operation status for all databases except system DBs.
	- Inserts metadata (file names, sizes, recovery model) for each database file.
	- Loops through each database file and attempts to shrink the file using DBCC SHRINKFILE.
	- If recovery model is not SIMPLE, it temporarily changes it to SIMPLE, performs shrink, and resets it back.
	- Logs the SQL executed, duration, and any error messages in the status table.
