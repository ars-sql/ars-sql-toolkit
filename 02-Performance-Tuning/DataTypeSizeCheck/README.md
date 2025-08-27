FindColumnsWIthBigIntDataType.sql
	- This query pull the column name and table name from pdcprod database and maximum value stored in the column
	- Then check for each column and its maximum value to decide can column data type can be decreased or not.
Name: FIndColumns_wIth_NVARCHAR_DataType.sql
	Description :
		- Identifies all NVARCHAR columns across user tables.
		- Captures maximum defined length and actual maximum length used in data.
		- Helps DBAs optimize schema by right-sizing NVARCHAR columns to reduce memory and storage overhead.
	Execution Instruction:
		- Before execution: Ensure database Z_ARS_Optimization exists or adjust schema references accordingly.
		- After execution: Query [Z_ARS_Optimization.dbo.tbl_Analysis_NVARCHAR] to review NVARCHAR column usage and optimization opportunities.
