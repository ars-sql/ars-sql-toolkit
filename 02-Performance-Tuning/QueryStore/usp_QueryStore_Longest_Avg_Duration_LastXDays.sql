/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: QueryStore_Longest_Avg_Duration_LastXDays.sql
Description :
    - Returns the Top-N queries with the highest average execution time from Query Store over the last X days.
    - Consolidates ARS_017 (1-day) and ARS_028 (N-day) into one flexible, parameterized tool.
    - Shows query text, object name, plan id, execution counts, first/last execution time,
      and average CPU/IO metrics alongside average duration (in ms/sec).
Execution Instruction:
    - Before execution: Ensure Query Store is enabled on the current database.
    - After execution: Review results; tune slow queries (indexing, rewrites, plan stabilization) as needed.
*/

CREATE OR ALTER PROCEDURE dbo.usp_QueryStore_Longest_Avg_Duration_LastXDays
(
      @LastDays          int         = 1      -- lookback window in days
    , @TopN              int         = 10     -- number of rows to return
    , @MinExecutions     int         = 1      -- filter out noise; require at least N executions in window
    , @UseUTC            bit         = 1      -- 1 = use UTC clock; 0 = use server local time
)
AS
BEGIN
    SET NOCOUNT ON;

    -------------------------------------------------------------------------
    -- Time window (UTC vs local) – Query Store stores times in UTC.
    -------------------------------------------------------------------------
    DECLARE @window_end   datetime2(7);
    DECLARE @window_start datetime2(7);

    IF (@UseUTC = 1)
    BEGIN
        SET @window_end   = SYSUTCDATETIME();
        SET @window_start = DATEADD(DAY, -@LastDays, @window_end);
    END
    ELSE
    BEGIN
        -- Converted to UTC to compare correctly to Query Store timestamps (which are UTC)
        DECLARE @local_end   datetimeoffset(7) = SYSDATETIMEOFFSET();
        DECLARE @local_start datetimeoffset(7) = DATEADD(DAY, -@LastDays, @local_end);

        SET @window_end   = SWITCHOFFSET(@local_end,  '+00:00');
        SET @window_start = SWITCHOFFSET(@local_start,'+00:00');
    END

    -------------------------------------------------------------------------
    -- Pull top-N by avg duration within the window
    -- Notes:
    --   * Query Store avg_* metrics are in microseconds (duration/cpu), reads/writes are logical IO counts.
    --   * We convert durations to ms and sec for readability.
    -------------------------------------------------------------------------
    ;WITH rs AS
    (
        SELECT
              qsq.query_id
            , qsq.object_id
            , qt.query_sql_text
            , p.plan_id
            , SUM(r.count_executions)                          AS exec_count
            , AVG(CAST(r.avg_duration      AS float))          AS avg_duration_us
            , AVG(CAST(r.avg_cpu_time      AS float))          AS avg_cpu_us
            , AVG(CAST(r.avg_logical_io_reads  AS float))      AS avg_lio_reads
            , AVG(CAST(r.avg_logical_io_writes AS float))      AS avg_lio_writes
            , MIN(r.first_execution_time)                      AS first_exec_time_utc
            , MAX(r.last_execution_time)                       AS last_exec_time_utc
        FROM sys.query_store_runtime_stats AS r
        JOIN sys.query_store_plan         AS p   ON p.plan_id        = r.plan_id
        JOIN sys.query_store_query        AS qsq ON qsq.query_id      = p.query_id
        JOIN sys.query_store_query_text   AS qt  ON qt.query_text_id  = qsq.query_text_id
        WHERE NOT (
                    r.first_execution_time > @window_end
                    OR r.last_execution_time  < @window_start
                  )
        GROUP BY qsq.query_id, qsq.object_id, qt.query_sql_text, p.plan_id
        HAVING SUM(r.count_executions) >= @MinExecutions
    )
    SELECT TOP (@TopN)
          rs.query_id
        , rs.plan_id
        , rs.exec_count
        , rs.avg_duration_us / 1000.0                          AS avg_duration_ms
        , rs.avg_duration_us / 1000000.0                       AS avg_duration_sec
        , rs.avg_cpu_us     / 1000.0                           AS avg_cpu_ms
        , rs.avg_lio_reads                                    AS avg_logical_reads
        , rs.avg_lio_writes                                   AS avg_logical_writes
        , rs.first_exec_time_utc
        , rs.last_exec_time_utc
        , OBJECT_SCHEMA_NAME(rs.object_id)                     AS object_schema
        , OBJECT_NAME(rs.object_id)                            AS object_name
        , rs.query_sql_text
    FROM rs
    ORDER BY avg_duration_us DESC, exec_count DESC;
END
GO

-- Quick examples:
-- EXEC dbo.usp_QueryStore_Longest_Avg_Duration_LastXDays @LastDays = 1,  @TopN = 10, @MinExecutions = 2, @UseUTC = 1;
-- EXEC dbo.usp_QueryStore_Longest_Avg_Duration_LastXDays @LastDays = 7,  @TopN = 25, @MinExecutions = 5, @UseUTC = 1;
