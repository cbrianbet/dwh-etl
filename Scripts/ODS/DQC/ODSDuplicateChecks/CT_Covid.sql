with cte AS (
						Select
						Sitecode,
						PatientPK,
						visitID,
						Covid19AssessmentDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,Covid19AssessmentDate ORDER BY
						PatientPK,Sitecode,visitID,Covid19AssessmentDate) Row_Num
						FROM [ODS].[dbo].[CT_Covid](NoLock)
						)
						Select count(*) from cte 
						Where Row_Num >1 ;