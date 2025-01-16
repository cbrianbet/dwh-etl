MERGE [NDWH].[Dim].[DimVaccinationStatus] AS a
		USING	(	SELECT DISTINCT VaccinationStatus
					FROM ODS.Care.CT_Covid
					WHERE 	VaccinationStatus <> '' AND 
							VaccinationStatus IS NOT NULL
				) AS b 
						ON(
							a.VaccinationStatus = b.VaccinationStatus
						  )
		WHEN NOT MATCHED THEN 
						INSERT(VaccinationStatus,LoadDate) 
						VALUES(VaccinationStatus,GetDate())
		WHEN MATCHED THEN
						UPDATE  						
							SET a.VaccinationStatus =b.VaccinationStatus;
