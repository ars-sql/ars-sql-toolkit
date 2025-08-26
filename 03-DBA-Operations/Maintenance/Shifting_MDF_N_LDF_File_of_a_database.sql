/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
	- Do NOT run or apply these results directly in a Production Environment.
	- Always validate in a lower environment first (Dev / QA / UAT).
	- Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
DON'T EXECUTE THE SCRIPT IN ONE GO 	
*/
/*
Name: Shifting_MDF_N_LDF_File_of_a_database.sql.sql
Description	: 
	1. Moves a database MDF and LDF files to a new location.
	2. First checks current file paths using sys.database_files.
	3. Takes the database offline, updates file paths with MODIFY FILE.
	4. Finally, brings the database back online after physical file movement.
Manual Checks Before Running
	1. Update all references to your actual database name.
	2. Confirm new MDF and LDF folder paths exist and SQL Server has access to them.
	3. Ensure no active sessions are connected — database must go offline.
	4. Physically move the files to the new location after going offline and before bringing online.
	5. Take a full backup before doing file movements.
	6. If part of Always On, Mirroring, or Log Shipping, pause or reconfigure those features.	
*/

-------------------------------------------------------------------------------------------------------
-- step_1: change the database name and then run the below query
-------------------------------------------------------------------------------------------------------
-- Update the NAME and FILENAME for both the command ALTER DATABASE <DB_NAME> MODIFY FILE  
-- Change the database name in complete file
select * from <DB_NAME>.sys.database_files


-------------------------------------------------------------------------------------------------------
--Step 2: MAKE DATBASE OFFLINE
-------------------------------------------------------------------------------------------------------
-- ALTER DATABASE myDatabaseName SET OFFLINE;
ALTER DATABASE <DB_NAME> SET OFFLINE;


GO
-------------------------------------------------------------------------------------------------------
--Step 3: 
-------------------------------------------------------------------------------------------------------
-- MOVE LDF FILE AND MDF FILE TO NEW LOCATION MANUALLY 

-------------------------------------------------------------------------------------------------------
-- Step 4
-------------------------------------------------------------------------------------------------------
 ALTER DATABASE myDataBaseName MODIFY FILE ( NAME = myDatabase_DataFileLogicalName, FILENAME = 'New_Path\myMdfFIleName.mdf' );
--ALTER DATABASE <DB_NAME> MODIFY FILE ( NAME = IPMV_Data, FILENAME = 'H:\SQLFiles\Data\PDCDev.mdf' );
ALTER DATABASE myDataBaseName MODIFY FILE ( NAME = myDatabase_LogFileLogicalName, FILENAME = 'New_Path\myLdfFIleName.mdf' );
--ALTER DATABASE <DB_NAME> MODIFY FILE ( NAME = IPMV_Log, FILENAME = 'E:\MSSQLLog\LOG\PDCDev_log.ldf' );
GO

-------------------------------------------------------------------------------------------------------
-- Step 5
-------------------------------------------------------------------------------------------------------
ALTER DATABASE <DB_NAME> SET ONLINE;