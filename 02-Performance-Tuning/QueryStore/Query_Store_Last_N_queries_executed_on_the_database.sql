/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Query_Store_Last_N_queries_executed_on_the_database.sql
Description :
    - Retrieves the last N queries executed on the database using Query Store.
    - Filters by a user-defined time interval (last X hours/days).
    - Provides object name, query text, execution counts, and last execution time.
    - Helps DBAs quickly analyze recent query workload and troubleshoot performance issues.
Execution Instruction:
    - Before execution: Adjust @results_row_count, @interval_start_time, and @interval_end_time as needed.
    - After execution: Review output to identify recent queries and focus on tuning high-cost or frequently executed ones.
*/

DECLARE 
	@results_row_count		as int					= 25,
	@interval_start_time	as datetimeoffset(7)	= '2022-08-14 05:30:00 +05:30',
	@interval_end_time		as datetimeoffset(7)	= '2022-08-15 05:30:00 +05:30'

SELECT @interval_end_time = GETDATE()
SELECT	@interval_start_time = GETDATE() - 7
SELECT @interval_start_time as interval_start_time,@interval_end_time as interval_end_time

SELECT TOP (@results_row_count)
	store_query.object_id AS [Object Id]
	,ISNULL(OBJECT_NAME(store_query.object_id),'''') as [Object Name]
	,store_plan.query_id AS [Query Id]
	,query_text.query_text_id AS [Query Text Id]
	,query_text.query_sql_text as [Sql Query]
	,runtime_stats.count_executions as [Excution Count]
	,runtime_stats.last_execution_time
FROM sys.query_store_runtime_stats AS runtime_stats
JOIN sys.query_store_plan AS store_plan ON store_plan.plan_id = runtime_stats.plan_id
JOIN sys.query_store_query AS store_query ON store_query.query_id = store_plan.query_id
JOIN sys.query_store_query_text AS query_text ON store_query.query_text_id = query_text.query_text_id  
WHERE 
	-- Making sure runtime_stats's first_execution_time and last_execution_time
	-- falls between date range (start date time and end date time)
	NOT 
	(
		runtime_stats.first_execution_time > @interval_end_time 
		OR 
		runtime_stats.last_execution_time < @interval_start_time
	)  
ORDER BY runtime_stats.last_execution_time DESC