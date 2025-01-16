MERGE [NDWH].[Dim].[DimTestKitName] AS a
		USING	(	SELECT DISTINCT TestKitName1 AS TestKitName 
					FROM ODS.Hts.HTS_TestKits
					WHERE 	TestKitName1 IS NOT NULL AND 
							TestKitName1 <> '' AND 
							TestKitName1 <> 'null'

        			UNION

					SELECT DISTINCT TestKitName2 AS TestKitName 
					FROM ODS.Hts.HTS_TestKits
 					WHERE 	TestKitName2 IS NOT NULL AND 
							TestKitName2 <> '' AND 
							TestKitName2 <> 'null'
				) AS b 
						ON(
							a.TestKitName = b.TestKitName
						  )
		WHEN NOT MATCHED THEN 
						INSERT(TestKitName,LoadDate) 
						VALUES(TestKitName,GetDate())
		WHEN MATCHED THEN
						UPDATE  						
							SET a.TestKitName =b.TestKitName;
						 