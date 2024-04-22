with cte AS (
						Select
						Sitecode,
						PatientPK,
						visitID,
						VisitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,VisitDate ORDER BY
						PatientPK,Sitecode,visitID,VisitDate) Row_Num
						FROM [ODS].[dbo].[CT_AllergiesChronicIllness](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;

					INSERT INTO [ODS_logs].[dbo].[CT_AllergiesChronicIllnessCount_Log]([SiteCode],[CreatedDate],[AllergiesChronicIllnessCount])
					SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS PatientPharmacyCount 
					FROM [ODS].[dbo].[CT_AllergiesChronicIllness] 
					GROUP BY SiteCode;