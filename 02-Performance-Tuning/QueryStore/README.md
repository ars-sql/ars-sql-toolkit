Name: Reusing_ExecutionPlan_for_Different_Filter_Criteria.sql
	Description :
		- Shows how SQL Server generates different execution plans when queries use literal values.
		- Demonstrates how using parameters with sp_executesql enables execution plan reuse.
		- Helps identify plan cache usage and reduce bloat by proper parameterization.
	Execution Instruction:
		- Before execution: Ensure the table [NewValueHistory] exists and has data for multiple Account values.
		- After execution: Check execution plan cache via sys.dm_exec_cached_plans and confirm plan reuse with sp_executesql.
Name: Number_Of_Executions_For_Each_Query.sql
	Description :
		- Retrieves query execution counts from Query Store for all queries in the database.
		- Aggregates execution statistics from sys.query_store_runtime_stats.
		- Identifies the most frequently executed queries for performance tuning focus.
	Execution Instruction:
		- Before execution: Ensure Query Store is enabled on the target database.
		- After execution: Review top queries and investigate optimization or indexing opportunities.
Name: Query_Store_Last_N_queries_executed_on_the_database.sql
	Description :
		- Retrieves the last N queries executed on the database using Query Store.
		- Filters by a user-defined time interval (last X hours/days).
		- Provides object name, query text, execution counts, and last execution time.
		- Helps DBAs quickly analyze recent query workload and troubleshoot performance issues.
	Execution Instruction:
		- Before execution: Adjust @results_row_count, @interval_start_time, and @interval_end_time as needed.
		- After execution: Review output to identify recent queries and focus on tuning high-cost or frequently executed ones.
Name: Query_Store_Top_N_Query_Execution_Count_in_date_range.sql
	Description :
		- Retrieves the top N queries executed within a given date range using Query Store.
		- Displays query text, execution counts, and number of distinct plans per query.
		- Helps DBAs detect most frequently executed queries and potential plan instability.
	Execution Instruction:
		- Before execution: Adjust @results_row_count, @interval_start_time, and @interval_end_time parameters.
		- After execution: Review results to focus on optimizing high-frequency queries or stabilizing multi-plan queries.
Name: QueryStore_Longest_Avg_Duration_LastXDays.sql
	Description :
		- Returns the Top-N queries with the highest average execution time from Query Store over the last X days.
		- Consolidates ARS_017 (1-day) and ARS_028 (N-day) into one flexible, parameterized tool.
		- Shows query text, object name, plan id, execution counts, first/last execution time,
		and average CPU/IO metrics alongside average duration (in ms/sec).
	Execution Instruction:
		- Before execution: Ensure Query Store is enabled on the current database.
		- After execution: Review results; tune slow queries (indexing, rewrites, plan stabilization) as needed.
Name: Query_Store_Top_IO_Consumers_Last24Hours.sql
	Description :
		- Retrieves the top 10 queries with the highest average physical IO reads in the last 24 hours from Query Store.
		- Provides query text, execution counts, row counts, and interval timestamps.
		- Helps DBAs identify IO-heavy queries that may require optimization.
	Execution Instruction:
		- Before execution: Ensure Query Store is enabled and collecting runtime stats.
		- After execution: Review queries with high IO consumption and tune them (e.g., indexing, rewrites, partitioning).
Name: Query_Store_Query_Id_with_multiple_plans.sql
Description :
    - Identifies queries that have multiple execution plans in Query Store.
    - Returns query IDs and the count of distinct plans.
    - Useful for detecting plan instability (parameter sniffing, stats skew).
Execution Instruction:
    - Before execution: Ensure Query Store is enabled and capturing runtime stats.
    - After execution: Review queries with multiple plans and consider stabilization techniques (e.g., forced plans, query hints).
Name: Query_Store_Remove_Non_Used_Queries_from_Query_Store.sql
	Description :
		- Removes non-used or internal queries from Query Store to prevent space issues.
		- Helps avoid losing important workload queries by purging irrelevant ones.
		- Uses sp_query_store_remove_query to clean entries.
	Execution Instruction:
		- Before execution: Review filters (internal queries, adhoc queries, last execution cutoff time).
		- After execution: Monitor Query Store space usage to confirm cleanup effectiveness.
Name: Query_Store_top_N_queries_with_the_highest_wait_durations.sql
	Description :
		- Retrieves the top N queries with the highest total wait durations using Query Store wait stats.
		- Aggregates total_query_wait_time_ms across query plans.
		- Helps DBAs identify queries with significant wait bottlenecks for further tuning.
	Execution Instruction:
		- Before execution: Adjust TOP clause (default 10) to fetch more/less queries.
		- After execution: Investigate high-wait queries to determine root causes (locks, IO, CPU pressure).
