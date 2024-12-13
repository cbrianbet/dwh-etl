	with cte AS (
						Select
						Sitecode,
						PatientPK,
						visitID,
						VisitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,VisitDate ORDER BY
						PatientPK,Sitecode,visitID,VisitDate) Row_Num
						FROM [ODS].[Care].[CT_CancerScreening](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;