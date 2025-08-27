/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Query_Store_Top_N_Query_Execution_Count_in_date_range.sql
Description :
    - Retrieves the top N queries executed within a given date range using Query Store.
    - Displays query text, execution counts, and number of distinct plans per query.
    - Helps DBAs detect most frequently executed queries and potential plan instability.
Execution Instruction:
    - Before execution: Adjust @results_row_count, @interval_start_time, and @interval_end_time parameters.
    - After execution: Review results to focus on optimizing high-frequency queries or stabilizing multi-plan queries.
*/

DECLARE 
	@results_row_count		as int					= 25,
	@interval_start_time	as datetimeoffset(7)	= '2022-08-14 05:30:00 +05:30',
	@interval_end_time		as datetimeoffset(7)	= '2022-08-15 05:30:00 +05:30'

SELECT @interval_end_time = GETDATE()
SELECT	@interval_start_time = GETDATE() - 7
SELECT @interval_start_time as interval_start_time,@interval_end_time as interval_end_time

SELECT TOP (@results_row_count)
	store_plan.query_id query_id
	,store_query.object_id object_id
	,ISNULL(OBJECT_NAME(store_query.object_id),'''') object_name
	,query_text.query_sql_text query_sql_text
	,SUM(runtime_stats.count_executions) AS total_execution_count
	,COUNT(distinct store_plan.plan_id) AS num_plans  
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
GROUP BY store_plan.query_id, query_text.query_sql_text, store_query.object_id  
HAVING COUNT(distinct store_plan.plan_id) >= 1  
ORDER BY total_execution_count DESC