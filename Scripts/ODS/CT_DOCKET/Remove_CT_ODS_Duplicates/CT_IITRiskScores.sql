with cte AS (
						Select
						Sitecode,
						PatientPK,						

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode ORDER BY
						PatientPK,Sitecode) Row_Num
						FROM  [ODS].[Care].[CT_IITRiskScores](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;