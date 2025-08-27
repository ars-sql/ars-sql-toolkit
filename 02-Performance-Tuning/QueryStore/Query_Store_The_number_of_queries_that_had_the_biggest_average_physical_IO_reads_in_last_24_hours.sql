/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Query_Store_Top_IO_Consumers_Last24Hours.sql
Description :
    - Retrieves the top 10 queries with the highest average physical IO reads in the last 24 hours from Query Store.
    - Provides query text, execution counts, row counts, and interval timestamps.
    - Helps DBAs identify IO-heavy queries that may require optimization.
Execution Instruction:
    - Before execution: Ensure Query Store is enabled and collecting runtime stats.
    - After execution: Review queries with high IO consumption and tune them (e.g., indexing, rewrites, partitioning).
*/

SELECT TOP 10 
	q.query_id
	, qt.query_sql_text
	,ISNULL(OBJECT_NAME(q.object_id),'') as [object_name]
	, rs.avg_physical_io_reads
	--, qt.query_text_id
	--, p.plan_id
	--, rs.runtime_stats_id
	, rsi.start_time
	, rsi.end_time
	, rs.avg_rowcount
	, rs.count_executions
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
JOIN sys.query_store_runtime_stats_interval AS rsi
    ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
WHERE rsi.start_time >= DATEADD(hour, -24, GETUTCDATE())
ORDER BY rs.avg_physical_io_reads DESC;