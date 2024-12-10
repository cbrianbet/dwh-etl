MERGE [NDWH].[Dim].[DimFamilyPlanning] AS a
	USING	(	SELECT DISTINCT FamilyPlanningMethod AS FamilyPlanning
				FROM ODS.Care.CT_PatientVisits
				WHERE FamilyPlanningMethod <> 'NULL' AND FamilyPlanningMethod <>''
			) AS b 
						ON(
							a.[FamilyPlanning] = b.FamilyPlanning
						  )
		WHEN NOT MATCHED THEN 
						INSERT([FamilyPlanning],LoadDate) 
						VALUES(FamilyPlanning,GetDate())
		WHEN MATCHED THEN
						UPDATE  						
							SET a.FamilyPlanning =b.FamilyPlanning;
