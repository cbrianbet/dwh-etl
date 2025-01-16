MERGE [NDWH].[Dim].[DimAgency] AS a
		USING(SELECT DISTINCT [SDP_Agency] AS AgencyName
				FROM ODS.Care.All_EMRSites
				WHERE [SDP_Agency] <> 'NULL' AND [SDP_Agency] <> '') AS b 
						ON(
							a.AgencyName = b.AgencyName
						  )
		WHEN NOT MATCHED THEN 
						INSERT(AgencyName,LoadDate) 
						VALUES(AgencyName,GetDate())
		WHEN MATCHED THEN
						UPDATE  						
							SET	a.AgencyName =b.AgencyName;
