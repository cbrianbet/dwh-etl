	with cte AS (				
					Select
						PatientPK,
						Sitecode,
						OrderedbyDate,
						TestResult,
						TestName,
						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,OrderedbyDate,TestResult,TestName ORDER BY
						OrderedbyDate) Row_Num
						FROM [ODS].[dbo].[CT_PatientLabs](NoLock)
						)
					SELECT count(*) from cte 
						Where Row_Num >1 ;