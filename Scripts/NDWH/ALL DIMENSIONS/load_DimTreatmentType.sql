MERGE [NDWH].[Dim].[DimTreatmentType] AS a
		USING	(	SELECT DISTINCT TreatmentType as TreatmentType
					FROM ODS.Care.CT_PatientPharmacy
					WHERE TreatmentType <> 'NULL' and TreatmentType <>''
				) AS b 
						ON(
							a.TreatmentType = b.TreatmentType
						  )
		WHEN NOT MATCHED THEN 
						INSERT(TreatmentType,LoadDate) 
						VALUES(TreatmentType,GetDate())
		WHEN MATCHED THEN
						UPDATE  						
							SET a.TreatmentType =b.TreatmentType;

		UPDATE a
		SET TreatmentTypeCategory = CASE 
										WHEN TreatmentType IN ('ARV','HIV Treatment')	THEN 'ART'
										WHEN TreatmentType='Hepatitis B'				THEN 'Non-ART'
										ELSE TreatmentType 
									END
		FROM [NDWH].[Dim].[DimTreatmentType] a;