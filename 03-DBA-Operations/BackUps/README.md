Name: Get_All_Database_Backup_History_from_last_X_days.sql
    Description :
        - Retrieves backup history for all databases from msdb for the last X days.
        - Displays backup type (Full, Differential, Log), size, compressed size, and compression ratio.
        - Shows start/end time and duration (minutes/seconds).
        - Helps DBAs validate backup frequency, duration, and compression efficiency.
    Execution Instruction:
        - Before execution: Set @lastXdays parameter to the desired number of days.
        - After execution: Review output for missing or failed backups; adjust job schedules if necessary.
