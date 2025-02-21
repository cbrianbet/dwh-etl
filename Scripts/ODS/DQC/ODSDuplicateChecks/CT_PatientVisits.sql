with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						visitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
						visitDate desc) Row_Num
						FROM [ODS].[dbo].[CT_PatientVisits](NoLock)
						)
					Select count(*) from cte 
						Where Row_Num >1 ;