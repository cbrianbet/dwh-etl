
MERGE [NDWH].[Dim].[DimDifferentiatedCare] AS a
		USING	(	SELECT DISTINCT DifferentiatedCare as DifferentiatedCare
					FROM ODS.Care.CT_PatientVisits
					WHERE DifferentiatedCare <> 'NULL' AND DifferentiatedCare <>''
				) AS b 
						ON(
							a.DifferentiatedCare = b.DifferentiatedCare
						  )
		WHEN NOT MATCHED THEN 
							INSERT(DifferentiatedCare,LoadDate) 
							VALUES(DifferentiatedCare,GetDate())
		WHEN MATCHED THEN
						UPDATE  						
							SET a.DifferentiatedCare =b.DifferentiatedCare;

