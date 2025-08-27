/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Number_Of_Executions_For_Each_Query.sql
Description :
    - Retrieves query execution counts from Query Store for all queries in the database.
    - Aggregates execution statistics from sys.query_store_runtime_stats.
    - Identifies the most frequently executed queries for performance tuning focus.
Execution Instruction:
    - Before execution: Ensure Query Store is enabled on the target database.
    - After execution: Review top queries and investigate optimization or indexing opportunities.
*/


SELECT q.query_id, qt.query_text_id, qt.query_sql_text
	,CAST(SUM(rs.count_executions)/1000000.0 as numeric(10,2)) AS execution_count_million
	,SUM(rs.count_executions) AS total_execution_count
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
GROUP BY q.query_id, qt.query_text_id, qt.query_sql_text
ORDER BY total_execution_count DESC;