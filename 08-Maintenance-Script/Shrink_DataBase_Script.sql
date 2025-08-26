/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
	- Do NOT run or apply these results directly in a Production Environment.
	- Always validate in a lower environment first (Dev / QA / UAT).
	- Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
	- Create a Database with the name Z_ETS before running the script
*/
/*
Name: Shrink_DataBase_Script.sql
Description	: 
	- Creates a table ARS_SHRINK_DATABASE_STATUS to log shrink operation status for all databases except system DBs.
	- Inserts metadata (file names, sizes, recovery model) for each database file.
	- Loops through each database file and attempts to shrink the file using DBCC SHRINKFILE.
	- If recovery model is not SIMPLE, it temporarily changes it to SIMPLE, performs shrink, and resets it back.
	- Logs the SQL executed, duration, and any error messages in the status table.
Manual Checks Before Running
	- Shrinking files can lead to fragmentation — consider if shrinking is really needed.
	- Keep on monitoring the "% Process Time", "RAM Utilization", "Database I/O". If it increses beyond the permissible limit then interrupt the execution to release the resource utilizaiton.
	- Dont run on high-load servers without maintenance window.
	- Ensure proper backups exist — especially for full recovery model databases.	
*/

USE MASTER
go
IF NOT EXISTS(SELECT 1 FROM Z_ETS.INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ARS_SHRINK_DATABASE_STATUS' )
BEGIN
	CREATE TABLE Z_ETS.[dbo].[ARS_SHRINK_DATABASE_STATUS](
		[ROW_ID] [bigint] IDENTITY(1,1) NOT NULL,
		[DATABASE_NAME] [varchar](500) NOT NULL,
		[START_DATE_TIME] [datetime] NULL,
		[END_DATE_TIME] [datetime] NULL,
		[TIME_IN_SECONDS]  AS (case when [START_DATE_TIME] IS NOT NULL then datediff(second,[START_DATE_TIME],isnull([END_DATE_TIME],getdate())) else (0) end),
		[SQL_TO_EXECUTE] [varchar](8000) NULL,
		[ERROR_MESSAGE] [varchar](8000) NULL,
		[DATABASE_FILE_NAME] [varchar](500) NOT NULL,
		[PHYSICAL_NAME] [varchar](500) NOT NULL,
		[TYPE_DESC] [varchar](500) NULL,
		[SIZE] [int] NOT NULL,
		[RECOVERY_MODEL_DESC] [nvarchar](60) NULL,
	 CONSTRAINT [PK_ARS_SHRINK_DATABASE_STATUS] PRIMARY KEY CLUSTERED 
	(
		[ROW_ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END

INSERT INTO Z_ETS.dbo.ARS_SHRINK_DATABASE_STATUS(
	[DATABASE_NAME],
	[DATABASE_FILE_NAME] ,
	[PHYSICAL_NAME],
	[TYPE_DESC] ,
	[SIZE] ,
	[RECOVERY_MODEL_DESC] 
)
SELECT 
	MD.NAME AS DATABASE_NAME,
	MF.NAME DATABASE_FILE_NAME, 
	MF.PHYSICAL_NAME,
	MF.TYPE_DESC,
	MF.SIZE,
	MD.RECOVERY_MODEL_DESC
FROM MASTER.SYS.MASTER_FILES AS MF 
INNER JOIN  MASTER.SYS.DATABASES AS MD ON MF.DATABASE_ID = MD.DATABASE_ID
WHERE MD.NAME NOT IN ('MASTER','MODEL','MSD','TEMPDB','msdb')
 --AND TYPE_DESC='LOG' -- ENABLE IF YOU WANT TO RUN FOR LOG FILES ONLY
ORDER BY TYPE_DESC,MF.SIZE ASC
	

Declare @curr_count int,@max_count int
SELECT
	@curr_count= MIN(ROW_ID),
	@max_count = MAX(ROW_ID)
FROM Z_ETS.dbo.ARS_SHRINK_DATABASE_STATUS

Declare 
	@database_name varchar(50),
	@recovery_model_desc varchar(500),
	@database_logical_file_name varchar(50),
	@stmt_to_execute as NVARCHAR(MAX),
	@alter_db_stmt_to_execute as NVARCHAR(MAX)
WHILE (@curr_count<= @max_count)
BEGIN
	-- Accessing Current Values
	SELECT 
		@database_name = database_name,
		@database_logical_file_name = database_file_name ,
		@recovery_model_desc = recovery_model_desc
	FROM Z_ETS.dbo.ARS_SHRINK_DATABASE_STATUS
	WHERE ROW_ID = @curr_count

	-- Main Busines Logic
	IF @recovery_model_desc = 'SIMPLE'
	BEGIN 

		-- START: COMMON WORK 
		-- Updating Start Time and SQL Statement
		UPDATE Z_ETS.dbo.ARS_SHRINK_DATABASE_STATUS
		SET START_DATE_TIME = GETDATE()
		WHERE ROW_ID = @curr_count
		BEGIN TRY
			-- SHRINK FILE
			SET @stmt_to_execute = 'USE ' + QUOTENAME(@database_name) + '; ' + ' DBCC SHRINKFILE (' + QUOTENAME(@database_logical_file_name) + ', 1)'
			EXEC(@stmt_to_execute)
			-- Updating End Time
			UPDATE Z_ETS.dbo.ARS_SHRINK_DATABASE_STATUS
			SET 
				SQL_TO_EXECUTE = @stmt_to_execute, 
				END_DATE_TIME = GETDATE()
			WHERE ROW_ID = @curr_count
		END TRY
		BEGIN CATCH
			-- Updating Error and End Time	
			UPDATE Z_ETS.dbo.ARS_SHRINK_DATABASE_STATUS
			SET 
				[ERROR_MESSAGE] = ERROR_MESSAGE(),
				SQL_TO_EXECUTE = @stmt_to_execute, 
				END_DATE_TIME = GETDATE()
			WHERE ROW_ID = @curr_count
		END CATCH
		-- END: COMMON WORK 

	END
	ELSE
	BEGIN
		-- START: COMMON WORK 
		-- Updating Start Time and SQL Statement
		UPDATE Z_ETS.dbo.ARS_SHRINK_DATABASE_STATUS
		SET START_DATE_TIME = GETDATE()
		WHERE ROW_ID = @curr_count
		BEGIN TRY
			-- STEP_1: ALTER DATABASE TO SIMPLE RECOVERY MODEL
			SET @alter_db_stmt_to_execute = 'USE ' + QUOTENAME(@database_name) + '; ' +' ALTER DATABASE ' + QUOTENAME(@database_name) + ' SET RECOVERY SIMPLE'
			EXEC(@alter_db_stmt_to_execute)
			-- STEP_2: SHRINK DATABAS WORK
			SET @stmt_to_execute = 'USE ' + QUOTENAME(@database_name) + '; ' + ' DBCC SHRINKFILE (' + QUOTENAME(@database_logical_file_name) + ', 1)'
			EXEC(@stmt_to_execute)
			-- STEP_3: ALTER DATABASE TO PREVIOUS RECOVERY MODEL
			SET @alter_db_stmt_to_execute = 'ALTER DATABASE ' + QUOTENAME(@database_name) + ' SET RECOVERY ' + @recovery_model_desc
			EXEC(@alter_db_stmt_to_execute)
			-- Updating End Time
			UPDATE Z_ETS.dbo.ARS_SHRINK_DATABASE_STATUS
			SET 
				SQL_TO_EXECUTE = @stmt_to_execute, 
				END_DATE_TIME = GETDATE()
			WHERE ROW_ID = @curr_count
		END TRY
		BEGIN CATCH
			-- Updating Error and End Time	
			UPDATE Z_ETS.dbo.ARS_SHRINK_DATABASE_STATUS
			SET 
				[ERROR_MESSAGE] = ERROR_MESSAGE(),
				SQL_TO_EXECUTE = @stmt_to_execute, 
				END_DATE_TIME = GETDATE()
			WHERE ROW_ID = @curr_count
		END CATCH
		-- END: COMMON WORK 
	END
	-- Loop Management
	SET @curr_count = @curr_count + 1 
END