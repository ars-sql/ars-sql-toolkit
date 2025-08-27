/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Query_Store_top_N_queries_with_the_highest_wait_durations.sql
Description :
    - Retrieves the top N queries with the highest total wait durations using Query Store wait stats.
    - Aggregates total_query_wait_time_ms across query plans.
    - Helps DBAs identify queries with significant wait bottlenecks for further tuning.
Execution Instruction:
    - Before execution: Adjust TOP clause (default 10) to fetch more/less queries.
    - After execution: Investigate high-wait queries to determine root causes (locks, IO, CPU pressure).
*/

-- https://docs.microsoft.com/en-us/sql/relational-databases/performance/tune-performance-with-the-query-store?view=sql-server-ver16
SELECT TOP 10
    qt.query_text_id,
    q.query_id,
    p.plan_id,
    sum(total_query_wait_time_ms) AS sum_total_wait_ms
FROM sys.query_store_wait_stats ws
JOIN sys.query_store_plan p ON ws.plan_id = p.plan_id
JOIN sys.query_store_query q ON p.query_id = q.query_id
JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
GROUP BY qt.query_text_id, q.query_id, p.plan_id
ORDER BY sum_total_wait_ms DESC;