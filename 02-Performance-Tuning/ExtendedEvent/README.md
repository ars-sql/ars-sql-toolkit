Name: Reading_Extended_Event_Data_using_TSQL.sql
    Description :
        - Reads Extended Event session output files (.xel) and parses XML event data.
        - Dynamically pivots event attributes into tabular form for easy analysis.
        - Stores parsed results in [Extended_Event_Data_Store] for reporting and diagnostics.
    Execution Instruction:
        - Before execution: Update @lv_extended_event_name with the target XE session name.
        - After execution: Query [Extended_Event_Data_Store] to analyze XE event data in tabular format.
