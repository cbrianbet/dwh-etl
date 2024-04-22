with cte AS (
						Select
						Sitecode,
						PatientPK,
						
						 ROW_NUMBER() OVER (PARTITION BY Sitecode,PatientPK ORDER BY
						 Sitecode,PatientPK) Row_Num
						FROM [ODS].[dbo].[CT_Relationships](NoLock)
						)
					delete from cte 
						Where Row_Num >1 ;