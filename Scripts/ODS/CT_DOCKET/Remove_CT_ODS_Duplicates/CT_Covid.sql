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
						delete from cte 
						Where Row_Num >1 ;

				INSERT INTO [ODS_Logs].[dbo].[CT_CovidCount_Log]([SiteCode],[CreatedDate],[CovidCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS CovidCount 
				FROM [ODS].[dbo].[CT_Covid] 
				GROUP BY SiteCode;