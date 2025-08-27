/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
    - This script depends on usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing being available.
*/

/*
Name: usp_SQL_Health_CheckUp_sql_Server_services_status_capturing_controller.sql
Description :
    - Creates a controller procedure to capture SQL Server service status for key services.
    - Ensures table [tbl_sql_Server_service_status_Information] exists to log results.
    - Calls usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing for each SQL Server–related service.
    - Supports monitoring of Database Engine, SQL Agent, DTC, Browser, Reporting Services (and optionally OLAP).
Execution Instruction:
    - Before execution: Ensure helper procedure usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing exists.
    - After execution: Query [tbl_sql_Server_service_status_Information] to review service status logs.
*/

use Z_ETS

GO

GO
/*=============================================
AUTHOR		: Alok Ranjan
CREATE DATE	: 03/Oct/2022
DESCRIPTION	: This stored procedure is for the sql server health checkup data capturing
-- exec usp_SQL_Health_CheckUp_sql_Server_services_status_capturing_controller
-- SELeCT * FROM tbl_sql_Server_service_status_Information
=============================================*/
CREATE OR ALTER PROCEDURE usp_SQL_Health_CheckUp_sql_Server_services_status_capturing_controller
AS
BEGIN
	-- EXEC usp_sql_Server_services_status_capturing_controller

	--*****************************************************
	-- Database Server RAM check-up
	--*****************************************************
	IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tbl_sql_Server_service_status_Information')
	BEGIN
		create table dbo.tbl_sql_Server_service_status_Information
		(
			row_id INT IDENTITY(1,1) PRIMARY KEY,
			-----
			[service name] varchar(50),
			[service status] varchar(max),
			-----
			add_date_time datetime default getdate()
		)
	END
	Declare @lv_Service_Name VARCHAR(50)
	EXEC usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing 'MSSQLServer'
	EXEC usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing 'SQLServerAGENT'
	EXEC usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing 'msdtc'
	EXEC usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing 'sqlbrowser'
	--EXEC usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing 'MSSQLServerOLAPService'
	EXEC usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing 'ReportServer'
END

