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
						Select count(*) from cte 
						Where Row_Num >1 ;