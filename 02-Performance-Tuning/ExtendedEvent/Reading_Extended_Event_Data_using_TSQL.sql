/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
*/

/*
Name: Reading_Extended_Event_Data_using_TSQL.sql
Description :
    - Reads Extended Event session output files (.xel) and parses XML event data.
    - Dynamically pivots event attributes into tabular form for easy analysis.
    - Stores parsed results in [Extended_Event_Data_Store] for reporting and diagnostics.
Execution Instruction:
    - Before execution: Update @lv_extended_event_name with the target XE session name.
    - After execution: Query [Extended_Event_Data_Store] to analyze XE event data in tabular format.
*/

Declare @lv_extended_event_name VARCHAR(500) 
SET @lv_extended_event_name = 'ARS_Slow_Running_Queries_N_SP' -- Add the name of the EXTENDED EVENT HERE

Declare @extended_event_file_path nvarchar(260)
SELECT 
	--xet.target_data,CHARINDEX('name=',xet.target_data,0)+5,CHARINDEX('.xel',xet.target_data,0), 
	@extended_event_file_path = SUBSTRING(cast(xet.target_data as varchar(max)),CHARINDEX('name=',xet.target_data,0)+6,CHARINDEX('.xel',xet.target_data,0)-(CHARINDEX('name=',xet.target_data,0)+2))
FROM sys.dm_xe_session_targets xet
INNER JOIN sys.dm_xe_sessions xe
ON xe.[address] = xet.event_session_address
WHERE xe.name = @lv_extended_event_name
and xet.target_data LIKE '%File name%'

if object_id('Extended_Event_Data_Store') is not null
	DROP TABLE Extended_Event_Data_Store

--pull into temp table for speed and to make sure the ID works right
if object_id('tempdb..#myXmlTable') is not null
	DROP TABLE #myXmlTable

CREATE TABLE #myXmlTable (id INT IDENTITY, xml_data_value XML)
INSERT INTO #myXmlTable
SELECT CAST(event_data AS XML)
FROM sys.fn_xe_file_target_read_file(@extended_event_file_path,NULL,NULL, NULL)
 
--Now toss into temp table, generically shredded
if object_id('tempdb..#ParsedDataXML') is not null
	DROP TABLE #ParsedDataXML

CREATE TABLE #ParsedDataXML (id INT, Actual_Time DATETIME, Event_Type sysname, Parse_Name sysname, Node_Value VARCHAR(MAX))

INSERT INTO #ParsedDataXML 
SELECT id,
DATEADD(MINUTE, DATEPART(TZoffset, SYSDATETIMEOFFSET()), UTC_Time) AS Actual_Time,
Event_Type,
Parse_Name,
Node_Value
FROM (
	SELECT id,
	A.B.value('@name[1]', 'varchar(128)') AS Event_Type, -- Root Node Data, Way 1 to acess
	A.B.value('@package[1]', 'varchar(128)') AS Package, -- Root Node Data, Way 1 to acess
	A.B.value('./@timestamp[1]', 'datetime') AS UTC_Time, -- Root Node Data, Way 2 to acess
	X.N.value('local-name(.)', 'varchar(128)') AS Node_Name,-- XML document hierarchial node name
	X.N.value('../@name[1]', 'varchar(128)') AS Parse_Name, -- Name Value for each Node_Name
	X.N.value('./text()[1]', 'varchar(max)') AS Node_Value--, -- Name Value for each Node_Name
	FROM [#myXmlTable]
	CROSS APPLY xml_data_value.nodes('/*') AS A (B)
	CROSS APPLY xml_data_value.nodes('//*') AS X (N)
) T
WHERE Node_Name = 'value'

DECLARE @mySQL AS VARCHAR (MAX)
DECLARE @Column_Names AS VARCHAR (MAX)

SELECT 
	@Column_Names = COALESCE(@Column_Names + ',','') + QUOTENAME(Parse_Name)
FROM
(
	SELECT DISTINCT Parse_Name
	FROM #ParsedDataXML		
	WHERE Parse_Name <> 'tsql_stack'
) AS B

SET @mySQL=
	' 
	SELECT 
		Actual_Time, 
		Event_Type,
		' + @Column_Names + ' 
		INTO Extended_Event_Data_Store
	FROM
	(
		SELECT 
			id, 
			Event_Type, 
			Actual_Time, 
			Parse_Name, 
			Node_Value 
		FROM #ParsedDataXML 
	) AS source
	PIVOT
	(
		max(Node_Value) 
		FOR source.Parse_Name IN (' + @Column_Names + ')
	)AS pvt 
	'
EXEC (@mySQL) 
--order by actual_time DESC

SELECT * FROM Extended_Event_Data_Store