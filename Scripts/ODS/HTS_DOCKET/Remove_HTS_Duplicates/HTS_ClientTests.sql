with cte AS (
	Select
	a.PatientPK,
	a.SiteCode,
	a.TestResult1,
	a.TestResult2,
	a.FinalTestResult,
	a.TestDate,
	a.TestType,
	a.EntryPoint,
	a.TestStrategy,
	a.EncounterId,
	 ROW_NUMBER() OVER (PARTITION BY a.PatientPK,a.SiteCode,a.TestResult1,a.TestResult2,a.FinalTestResult,a.TestDate,a.TestType,a.EntryPoint,a.TestStrategy,a.EncounterId ORDER BY
	a.TestDate desc) Row_Num
	 FROM [ODS].[HTS].[HTS_ClientTests] a
				
				where a.FinalTestResult is not null
	)
delete  from cte 
	Where Row_Num >1