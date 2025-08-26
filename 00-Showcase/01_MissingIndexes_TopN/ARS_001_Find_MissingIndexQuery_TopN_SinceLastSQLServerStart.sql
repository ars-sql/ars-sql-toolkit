

	SELECT TOP 25 
			(SELECT sqlserver_start_time FROM sys.dm_os_sys_info ) as Server_Start_DateTime,
		--SUBSTRING
		--(
		--		sql_text.text,
		--		misq.last_statement_start_offset / 2 + 1,
		--		(CASE misq.last_statement_start_offset WHEN -1 THEN DATALENGTH(sql_text.text) ELSE misq.last_statement_end_offset END - misq.last_statement_start_offset) / 2 + 1
		--) as SQL_Query
		--, 
			-- Index Name Build
			'CREATE NONCLUSTERED INDEX [IX_' 
			+ OBJECT_NAME(mid.OBJECT_ID,mid.database_id) 
			+ CASE WHEN mid.equality_columns IS NOT NULL THEN '_' + replace(replace(replace(equality_columns,'[',''),']',''),', ','_') ELSE '' END
			+ CASE WHEN mid.inequality_columns IS NOT NULL THEN '_' + replace(replace(replace(inequality_columns,'[',''),']',''),', ','_') ELSE '' END
			+ ']'
			-- Building Column collection to create index 
			+ ' ON '  + mid.statement
			-- Building Column collection to create index 
			+  ' (' + ISNULL (mid.equality_columns,'') + ISNULL (', ' + mid.inequality_columns, '') + ')'
			-- Building Column collection to create index 
			-- Building Include Clause
			+ ISNULL (' INCLUDE (' + mid.included_columns + ')', '') 
			as Statement_To_Execute
		, OBJECT_NAME(mid.OBJECT_ID,mid.database_id) AS [TableName]
		, ROUND(misq.avg_total_user_cost * misq.avg_user_impact * (misq.user_seeks + misq.user_scans),0)/100000 as Estimated_Improvement
		, misq.avg_total_user_cost -- Average cost of the user queries that could be reduced by the index in the group.
		, misq.avg_user_impact	-- Average percentage benefit that user queries could experience if this missing index group was implemented. 
								-- The value means that the query cost would on average drop by this percentage if this missing index group was implemented.
		, misq.user_seeks		-- Number of seeks caused by user queries that the recommended index in the group could have been used for. 
		, misq.user_scans		-- Number of scans caused by user queries that the recommended index in the group could have been used for.
		, last_user_seek		-- Date and time of last seek caused by user queries that the recommended index in the group could have been used for
		,equality_columns,inequality_columns,included_columns,statement
		--CREATE INDEX [IX_ASPUEComps_AccountID_TaxYear] ON ([AccountID], [TaxYear]) INCLUDE ([IncludeComp], [Stars], [Pre_Adjustment_PricePerSF], [Remodel_Adjustment], [CDU_Adjustment], [Grade_Adjustment], [SQFT_Adjustment], [Class_Adjustment], [Age_Adjustment], [Post_Adjustment_PricePerSF], [Adjustment_Ratio], [Adjusted_Impr_Value], [Final_Adjusted_Value], [Neighborhood], [ISD], [Taxid], [Year_Built], [Bldg_SQFT], [Grade], [Condition], [Land_Value], [Impr_Value], [Total_Assessed], [Extra_Value], [Appraised_Value], [Market_Value], [Land_Use], [State_Class], [Address], [City], [Zip], [Key_Map], [Econ_Area], [Econ_Bld_Class], [Land_SQFT], [Units], [Net_Rent_Area], [CDU], [CDUNum], [GradeNum], [IPSF], [MPSF], [Neighborhood_Group], [YR_REMODEL], [NBHD_FACTOR], [SIZE_INDEX], [LUMP_SUM_ADJ], [Remodel_Code], [Remodel_Factor], [Dist], [Impr_Sq_Ft], [FormatVersion], [ExcludeLand], [Lat], [Lon], [Building_Style], [Structure_Class], [Structure_Class_Desc], [Improv_Type], [Improv_Type_Desc], [NumBuildings], [WallHeights], [OfficePercent], [Quality], [Stories], [MarketArea], [Land_Adj], [Nbhd_Adj], [ClassPrice_Adj], [MarketDetail_Adj], [AvgUnitSize], [CADRentPSF], [Zoning], [PropertyName], [Rent_Adjustment], [IsHomestead], [Segment_Adj], [EffYear], [StreetName], [ImprovementCount], [PercentGood], [ClassCode], [SubClass], [SubClassNum], [UnitPrice], [MainAreaRCN], [HighestValueSQFT], [HighestValueRPSF], [RCN], [TotalMethod], [Score], [SpecialAdjPercent], [Special_Adj], [FacilityService], [LicenseCapacity], [MedicaidCapacity], [MedicareCapacity], [MedicareCaidCapacity], [ICFMRCapacity], [AlzCapacity], [TotalCapacity], [Area2RCN], [Area2SQFT], [Area2UnitPrice], [Area3RCN], [Area3SQFT], [Area3UnitPrice], [NbhdFactor], [SQFT_Adjustment2], [SQFT_Adjustment3], [ConstructionAdjustment], [AvgUnitAdjustment], [TTLAdjustment], [SizeFactorAdjustment], [SubAreaAdjustment], [TotalAdjustment])
		, mid.*  
		--, misq.*
		/* 
			This query provides the name of the database, schema, and table where an index is missing. 
			It also provides the names of the columns that should be used for the index key. 
			When writing the CREATE INDEX DDL statement to implement missing indexes, 
				list equality columns first 
				and then inequality columns in the ON <table_name> clause of the CREATE INDEX statement. 
				Included columns should be listed in the INCLUDE clause of the CREATE INDEX statement. 
				To determine an effective order for the equality columns, order them based on their selectivity
				, listing the most selective columns first (leftmost in the column list).		
		*/
	FROM sys.dm_db_missing_index_groups AS mig
	INNER JOIN sys.dm_db_missing_index_group_stats_query AS misq ON  mig.index_group_handle = misq.group_handle
	INNER JOIN sys.dm_db_missing_index_details as mid ON mig.index_handle = mid.index_handle 
--	CROSS APPLY sys.dm_exec_sql_text(misq.last_sql_handle) AS sql_text
	WHERE mid.database_id =  DB_ID() -- Current Database Id
	ORDER BY Estimated_Improvement DESC;