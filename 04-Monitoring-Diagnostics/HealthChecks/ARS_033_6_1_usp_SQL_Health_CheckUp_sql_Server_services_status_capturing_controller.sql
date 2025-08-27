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

