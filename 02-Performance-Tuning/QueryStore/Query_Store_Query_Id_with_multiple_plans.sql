/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Query_Store_Query_Id_with_multiple_plans.sql
Description :
    - Identifies queries that have multiple execution plans in Query Store.
    - Returns query IDs and the count of distinct plans.
    - Useful for detecting plan instability (parameter sniffing, stats skew).
Execution Instruction:
    - Before execution: Ensure Query Store is enabled and capturing runtime stats.
    - After execution: Review queries with multiple plans and consider stabilization techniques (e.g., forced plans, query hints).
*/

SELECT q.query_id,COUNT(*) AS Exec_Plan_Count
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON p.query_id = q.query_id
GROUP BY q.query_id
HAVING COUNT(distinct plan_id) > 1
ORDER BY COUNT(distinct plan_id) DESC