with cte AS (
						Select
						Sitecode,
						PatientPK,
						visitID,
						VisitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,VisitDate ORDER BY
						VisitDate desc) Row_Num
						FROM [ODS].[dbo].[CT_DepressionScreening](NoLock)
						)
						Select count(*) from cte 
						Where Row_Num >1 ;