MERGE [NDWH].[Dim].[DimHTSTraceOutcome] AS a
		USING	(	SELECT DISTINCT TracingOutcome AS TraceOutcome
					FROM ODS.HTS.HTS_ClientTracing 
					WHERE  TracingOutcome <> 'null' AND TracingOutcome <> '' AND TracingOutcome IS NOT NULL
				
					UNION

					SELECT DISTINCT TraceOutcome 
					FROM ODS.HTS.HTS_PartnerTracings
					WHERE  TraceOutcome <> 'null' AND TraceOutcome <> ''AND TraceOutcome IS NOT NULL
				) AS b 
						ON(
							a.[TraceOutcome] = b.[TraceOutcome]
						  )
		WHEN NOT MATCHED THEN 
						INSERT([TraceOutcome],LoadDate) 
						VALUES([TraceOutcome],GetDate())
		WHEN MATCHED THEN
						UPDATE  						
							SET a.[TraceOutcome] =b.[TraceOutcome];
		
		UPDATE source_data
			SET [TraceOutcome]=	CASE
									WHEN source_data.TraceOutcome IN ('Contact Not Reached', 'Contacted and not Reached') THEN 'Contact Not Reached'
									ELSE source_data.TraceOutcome
								END 
		FROM [NDWH].[Dim].[DimHTSTraceOutcome] source_data;

		

