			with cte AS (Select
						PatientPK,
						Sitecode,
						OrderedbyDate,
						TestResult,
						TestName,
						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,OrderedbyDate,TestResult,TestName ORDER BY
						OrderedbyDate) Row_Num
						FROM [ODS].[Care].[CT_PatientLabs](NoLock))
					DELETE from cte
						Where Row_Num >1 ;

INSERT INTO [ODS_logs].[dbo].[CT_PatientLabsCount_Log]([SiteCode],[CreatedDate],[PatientLabsCount])
SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS PatientLabsCount
FROM [ODS].[Care].[CT_PatientLabs]
GROUP BY SiteCode;
