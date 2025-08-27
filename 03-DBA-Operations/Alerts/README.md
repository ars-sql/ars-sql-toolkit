Name: Restricting_Column_Drop_from_Any_Table.sql
    Description :
        - Creates a database-level DDL Trigger to restrict DROP COLUMN operations.
        - Rolls back any ALTER TABLE DROP COLUMN command and prints a warning.
        - Helps DBAs protect schema integrity from accidental or unauthorized changes.
    Execution Instruction:
        - Before execution: Ensure you have sysadmin or db_owner permissions to create DDL triggers.
        - After execution: Any DROP COLUMN attempts will fail with a warning message. To disable, drop the trigger manually.
