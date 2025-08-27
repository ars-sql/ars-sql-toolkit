/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsibility of the Author; the executor is solely responsible.
*/

/*
Name: Get_TableNames_Without_PrimaryKey.sql
Description :
    - Lists all base tables in the current database that do not have a primary key constraint.
    - Provides row count (both absolute and in millions) for each table.
    - Useful for schema auditing, normalization checks, and performance planning.
Execution Instruction:
    - Run in the target database context where you want to audit tables.
    - Ensure access to INFORMATION_SCHEMA views and sys.dm_db_partition_stats DMV.
    - Review results to decide if missing primary keys need to be added.
*/

SELECT 
    T.TABLE_CATALOG,
    T.TABLE_NAME,
    CAST(ISNULL(P.row_count, 0)/1000000.0 as numeric(10,2)) AS Record_Count_MIllion,
	ISNULL(P.row_count, 0) as Tot_Record_Count
FROM 
    INFORMATION_SCHEMA.TABLES T
LEFT JOIN 
    sys.objects O ON T.TABLE_NAME = OBJECT_NAME(O.parent_object_id)
    AND O.type_desc = 'PRIMARY_KEY_CONSTRAINT'
LEFT JOIN 
(
    SELECT 
        OBJECT_NAME(PS.object_id) AS TableName,
        SUM(PS.row_count) AS row_count
    FROM sys.dm_db_partition_stats PS
    WHERE PS.index_id IN (0,1) -- 0 = Heap, 1 = Clustered Index
    GROUP BY PS.object_id
) P ON T.TABLE_NAME = P.TableName
WHERE T.TABLE_TYPE = 'BASE TABLE'
    AND O.name IS NULL
ORDER BY Record_Count_MIllion DEsC;
