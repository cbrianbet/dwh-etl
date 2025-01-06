	with cte AS (
						Select
						Sitecode,
						PatientPK,
						visitID,
						visitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
						PatientPK,Sitecode,visitID,visitDate) Row_Num
						FROM [ODS].[Care].[CT_CervicalCancerScreening](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;