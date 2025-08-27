/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Get_All_Database_Backup_History_from_last_X_days.sql
Description :
    - Retrieves backup history for all databases from msdb for the last X days.
    - Displays backup type (Full, Differential, Log), size, compressed size, and compression ratio.
    - Shows start/end time and duration (minutes/seconds).
    - Helps DBAs validate backup frequency, duration, and compression efficiency.
Execution Instruction:
    - Before execution: Set @lastXdays parameter to the desired number of days.
    - After execution: Review output for missing or failed backups; adjust job schedules if necessary.
*/

Declare @lastXdays int = 1

-- Get Backup History for required database
SELECT 
s.database_name as DB_Name,
CASE s.[type] WHEN 'D' THEN 'Full' WHEN 'I' THEN 'Differential' WHEN 'L' THEN 'Transaction Log' END AS Backup_Type,
--m.physical_device_name,
CAST(s.backup_size / 1000 AS INT) AS Backup_Size_MB,
CAST(s.compressed_backup_size / 1000 AS INT) AS Compressed_Backup_Size_MB,
CAST(compressed_backup_size*100/backup_size as numeric(5,2)) as Compression_Ratio, --To calculate the compression ratio, use 
s.backup_start_date as Start_Date_Time,
s.backup_finish_date as End_Date_Time,
DATEDIFF(MINUTE, s.backup_start_date,s.backup_finish_date) as TimeTaken_Minute,
DATEDIFF(SECOND, s.backup_start_date,s.backup_finish_date) as TimeTaken_Second--,*
--CAST(s.first_lsn AS VARCHAR(50)) AS first_lsn,
--CAST(s.last_lsn AS VARCHAR(50)) AS last_lsn,
--,s.server_name
--,s.recovery_model
FROM msdb.dbo.backupset s
--INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE 1=1-- s.database_name = DB_NAME() -- Remove this line for all the database
and s.backup_start_date >= GETDATE()-@lastXdays
--ORDER BY s.backup_start_date DESC, s.backup_finish_date
ORDER BY s.backup_start_date asc
GO