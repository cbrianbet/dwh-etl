with cte AS (
						Select
						PatientPK,
						sitecode,
						visitID,
						DispenseDate,
						drug,
						 ROW_NUMBER() OVER (PARTITION BY PatientPK,sitecode,visitID,DispenseDate,drug ORDER BY
						DispenseDate desc) Row_Num
						FROM [ODS].[dbo].[CT_PatientPharmacy](NoLock)
						)
					delete from cte 
						Where Row_Num >1;


			INSERT INTO [ODS_logs].[dbo].[CT_PatientPharmacyCount_Log] ([SiteCode],[CreatedDate],[PatientPharmacyCount])
			SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS PatientPharmacyCount 
			FROM [ODS].[dbo].[CT_PatientPharmacy] 
			GROUP BY SiteCode;