/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
    - This script prevents DROP COLUMN operations. Executor must be aware it impacts all ALTER TABLE DROP COLUMN commands.
*/

/*
Name: Restricting_Column_Drop_from_Any_Table.sql
Description :
    - Creates a database-level DDL Trigger to restrict DROP COLUMN operations.
    - Rolls back any ALTER TABLE DROP COLUMN command and prints a warning.
    - Helps DBAs protect schema integrity from accidental or unauthorized changes.
Execution Instruction:
    - Before execution: Ensure you have sysadmin or db_owner permissions to create DDL triggers.
    - After execution: Any DROP COLUMN attempts will fail with a warning message. To disable, drop the trigger manually.
*/


CREATE OR ALTER TRIGGER ARS_RESTRICT_DROP_COLUMN_COMMAND
ON Database 
FOR ALTER_TABLE 
AS 
BEGIN
    Declare @Msg nvarchar(max) = (SELECT EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]','nvarchar(max)'))
     If @Msg Like '%Drop Column%'
	 BEGIN
		PRINT 'DROP Column command is restricted by DBA. Please contact your DBA.'
		Rollback
	END
END