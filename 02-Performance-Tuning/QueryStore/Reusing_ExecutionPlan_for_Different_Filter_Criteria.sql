/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Reusing_ExecutionPlan_for_Different_Filter_Criteria.sql
Description :
    - Shows how SQL Server generates different execution plans when queries use literal values.
    - Demonstrates how using parameters with sp_executesql enables execution plan reuse.
    - Helps identify plan cache usage and reduce bloat by proper parameterization.
Execution Instruction:
    - Before execution: Ensure the table [NewValueHistory] exists and has data for multiple Account values.
    - After execution: Check execution plan cache via sys.dm_exec_cached_plans and confirm plan reuse with sp_executesql.
*/


SELECT cplan.usecounts, cplan.objtype, qtext.text, qplan.query_plan,*
FROM sys.dm_exec_cached_plans AS cplan
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS qtext
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qplan
where text like '%NewValueHistory%'
AND TEXT NOT LIKE '%SELECT cplan.usecounts%'

--========================================================
-- Step-1: Run query with parameter with one value
--========================================================
select  * from NewValueHistory where Account='00464384'

--=======================================================================================================
-- Step-2: Run query with parameter with other value: This will not re-use the execution plan
--=======================================================================================================
select  * from NewValueHistory where Account='00202142'

--=======================================================================================================
--- Making Same query to run with different value but re-using the different execution plan
--=======================================================================================================
DECLARE @MyIntParm varchar(100) = '00202142'
EXEC sp_executesql
   N'SELECT * 
   FROM NewValueHistory 
   WHERE Account = @Parm',
   N'@Parm varchar(100)',
   @MyIntParm