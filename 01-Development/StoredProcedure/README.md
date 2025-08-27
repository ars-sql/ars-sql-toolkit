Name: Get_Table_Each_Column_Min_N_Max_Value.sql
    Description :
        - Stored procedure that returns the minimum and maximum values for each column in a given table.
        - Supports optional parameter to restrict results to numeric columns only.
        - Useful for data profiling, ETL validation, and anomaly detection.
    Execution Instruction:
        - Before execution: Ensure the target table exists and the user has SELECT permission on it.
        - After execution: Review the min/max values to validate data ranges and detect anomalies.
