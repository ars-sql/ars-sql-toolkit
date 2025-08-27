/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
    - This script removes queries from Query Store. Executor is solely responsible for running it.
*/

/*
Name: Query_Store_Remove_Non_Used_Queries_from_Query_Store.sql
Description :
    - Removes non-used or internal queries from Query Store to prevent space issues.
    - Helps avoid losing important workload queries by purging irrelevant ones.
    - Uses sp_query_store_remove_query to clean entries.
Execution Instruction:
    - Before execution: Review filters (internal queries, adhoc queries, last execution cutoff time).
    - After execution: Monitor Query Store space usage to confirm cleanup effectiveness.
*/


SET NOCOUNT ON
-- This purges adhoc and internal queries from 
-- the Query Store in the current database 
-- so that the Query Store does not run out of space 
-- and remove queries we really need to track

DECLARE @id int;
DECLARE non_used_queries_cursor CURSOR
FOR
    SELECT q.query_id
    FROM sys.query_store_query_text AS qt
    JOIN sys.query_store_query AS q
    ON q.query_text_id = qt.query_text_id
    JOIN sys.query_store_plan AS p
    ON p.query_id = q.query_id
    JOIN sys.query_store_runtime_stats AS rs
    ON rs.plan_id = p.plan_id
    WHERE q.is_internal_query = 1  -- is it an internal query then we dont care to keep track of it
      -- OR q.object_id = 0 -- if it does not have a valid object_id then it is an adhoc query and we don't care about keeping track of it
    GROUP BY q.query_id
    HAVING MAX(rs.last_execution_time) < DATEADD (minute, -5, GETUTCDATE())  -- if it has been more than 5 minutes since the adhoc query ran
    ORDER BY q.query_id;
OPEN non_used_queries_cursor ;
FETCH NEXT FROM non_used_queries_cursor INTO @id;
WHILE @@fetch_status = 0
BEGIN
    PRINT 'EXEC sp_query_store_remove_query ' + str(@id);
    EXEC sp_query_store_remove_query @id;
    FETCH NEXT FROM non_used_queries_cursor INTO @id;
END
CLOSE non_used_queries_cursor;
DEALLOCATE non_used_queries_cursor;