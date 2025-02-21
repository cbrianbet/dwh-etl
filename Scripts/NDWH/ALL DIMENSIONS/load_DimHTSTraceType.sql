MERGE [NDWH].[Dim].[DimHTSTraceType] AS a
		USING	(	SELECT DISTINCT TracingType AS TraceType 
					FROM ODS.HTS.HTS_ClientTracing
					
					UNION

					SELECT DISTINCT TraceType 
					FROM ODS.HTS.HTS_PartnerTracings
				) AS b 
						ON(
							a.TraceType = b.TraceType
						  )
		WHEN NOT MATCHED THEN 
						INSERT(TraceType,LoadDate) 
						VALUES(TraceType,GetDate())
		WHEN MATCHED THEN
						UPDATE  						
							SET	a.TraceType =b.TraceType;