Name: Get_TableNames_Without_PrimaryKey.sql
	Description :
		- Lists all base tables in the current database that do not have a primary key constraint.
		- Provides row count (both absolute and in millions) for each table.
		- Useful for schema auditing, normalization checks, and performance planning.
	Execution Instruction:
		- Run in the target database context where you want to audit tables.
		- Ensure access to INFORMATION_SCHEMA views and sys.dm_db_partition_stats DMV.
		- Review results to decide if missing primary keys need to be added.
Name: usp_SQL_Health_CheckUp_sql_Server_services_status_capturing_controller.sql
	Description :
		- Creates a controller procedure to capture SQL Server service status for key services.
		- Ensures table [tbl_sql_Server_service_status_Information] exists to log results.
		- Calls usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing for each SQL Server–related service.
		- Supports monitoring of Database Engine, SQL Agent, DTC, Browser, Reporting Services (and optionally OLAP).
	Execution Instruction:
		- Before execution: Ensure helper procedure usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing exists.
		- After execution: Query [tbl_sql_Server_service_status_Information] to review service status logs.
Name: usp_SQL_Health_CheckUp_SQL_Server_services_status_capturing.sql
	Description :
		- Captures the status of a specific SQL Server–related Windows service using xp_servicecontrol.
		- Inserts the service status into [tbl_sql_Server_service_status_Information].
		- Handles errors gracefully by logging error messages into the same table.
	Execution Instruction:
		- Before execution: Ensure table [tbl_sql_Server_service_status_Information] exists (created by controller script).
		- After execution: Review service status entries in [tbl_sql_Server_service_status_Information].
