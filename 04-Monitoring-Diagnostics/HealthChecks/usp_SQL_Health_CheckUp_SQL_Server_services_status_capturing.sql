/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
    - This script uses xp_servicecontrol, which requires sysadmin rights and interacts with Windows services.
*/

/*
Name: usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing.sql
Description :
    - Captures the status of a specific SQL Server–related Windows service using xp_servicecontrol.
    - Inserts the service status into [tbl_sql_Server_service_status_Information].
    - Handles errors gracefully by logging error messages into the same table.
Execution Instruction:
    - Before execution: Ensure table [tbl_sql_Server_service_status_Information] exists (created by controller script).
    - After execution: Review service status entries in [tbl_sql_Server_service_status_Information].
*/

use Z_ETS

GO
/*=============================================
AUTHOR		: Alok Ranjan
CREATE DATE	: 03/Oct/2022
DESCRIPTION	: This stored procedure is for the sql server health checkup data capturing
=============================================*/
CREATE OR ALTER PROCEDURE usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing
(
	@ip_Service_Name VARCHAR(50)
)
AS
BEGIN

	BEGIN TRY
		SELECT 1
		-- Capture Status
		INSERT tbl_sql_Server_service_status_Information([service status])
		EXEC xp_servicecontrol N'querystate',@ip_Service_Name
		/*
		--See below example to start/stop service using SSMS
		EXEC xp_servicecontrol N'stop',N'SQLServerAGENT' -- to START service
		EXEC xp_servicecontrol N'start',N'SQLServerAGENT -- to STOP service
		'*/
		-- Update Service Name
		UPDATE tbl_sql_Server_service_status_Information
		SET [service name] = @ip_Service_Name
		WHERE ROW_ID = @@identity
	END TRY
	BEGIN CATCH
		SELECT 2,@ip_Service_Name
		INSERT tbl_sql_Server_service_status_Information([service name] ,[service status])
		VALUES (@ip_Service_Name,ERROR_MESSAGE())
	END CATCH
END


