/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsibility of the Author; the executor is solely responsible.
*/

/*
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
*/


IF OBJECT_ID('tempdb..#tempTableStorage') is not null
	DROP TABLE #tempTableStorage


SELECT
    DB_NAME(mf.database_id)    AS DBName,
    mf.name                    AS LogicalName,
    mf.physical_name           AS PhysicalName,
    mf.type_desc               AS FileType,
    CAST((mf.size*8.0)/(1024*1024) AS decimal(18,2)) AS Size_GB,
	max_size, growth
	INTO #tempTableStorage
FROM sys.master_files AS mf
WHERE mf.state_desc = 'ONLINE' -- optional

-- SQL Server Instance Total
SELECT 'SQL Server Total Space Used' as Data_Info,SUM(Size_GB) AS Instance_Total_Size_GB
FROM #tempTableStorage;

-- Per-DB totals includig mdf and ldf
SELECT DBName, SUM(Size_GB) AS Total_DB_Size_GB
FROM #tempTableStorage
GROUP BY DBName
ORDER BY Total_DB_Size_GB DESC;

-- DatabaseWise FIleWise Storage
SELECT *
FROM #tempTableStorage
ORDER BY DBName, FileType, LogicalName;


-- tempdb spotlight
SELECT *
FROM #tempTableStorage
WHERE DBName = 'tempdb'
ORDER BY FileType, LogicalName;
