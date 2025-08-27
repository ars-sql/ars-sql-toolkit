/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Get_All_Databases_N_SIZE_MDF_LDF.sql
Description :
    - Retrieves current sizes (in GB) of MDF (data files) and LDF (log files) for all user databases.
    - Excludes system databases (master, model, msdb, tempdb).
    - Helps DBAs monitor file growth and perform capacity planning.
Execution Instruction:
    - Before execution: Ensure you have appropriate access to sys.master_files.
    - After execution: Review size information for database capacity management or maintenance planning.
*/

SELECT DB_NAME(database_id) AS database_name, 
    type_desc, 
    name AS FileName, 
    CAST((size/128.0)/1000 as NUMERIC(10,2)) AS CurrentSize_GB
FROM sys.master_files
WHERE database_id > 6 AND type IN (0,1)
--ORDER BY CurrentSize_GB desc