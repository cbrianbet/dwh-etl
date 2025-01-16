with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						VisitDate,
						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,onTBDrugs,OnIPT,EverOnIPT,EvaluatedForIPT,TBScreening,VisitDate ORDER BY
						Date_created  desc) Row_Num
						FROM [ODS].[dbo].[CT_Ipt](NoLock)
						)
						Select count(*) from cte 
						Where Row_Num >1 ;