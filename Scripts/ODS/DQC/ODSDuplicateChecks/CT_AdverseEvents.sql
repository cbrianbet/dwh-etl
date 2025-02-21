with cte AS (
						Select
						Sitecode,
						PatientPK,
						VisitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,VisitDate ORDER BY
						PatientPK,Sitecode,VisitDate) Row_Num
						FROM  [ODS].[dbo].[CT_AdverseEvents](NoLock)
						)
						select count(*) from cte 
						Where Row_Num >1 ;