MERGE [NDWH].[Dim].[DimDrug] AS a
		USING	(	SELECT DISTINCT Drug as Drug
					FROM ODS.Care.CT_PatientPharmacy
					WHERE Drug <> 'NULL' AND Drug <>'' AND TreatmentType='ARV'
				) AS b 
						ON(
							a.Drug = b.Drug
						  )
		WHEN NOT MATCHED THEN 
						INSERT(Drug,LoadDate) 
						VALUES(Drug,GetDate())
		WHEN MATCHED THEN
						UPDATE SET 						
						a.Drug =b.Drug;
						 

