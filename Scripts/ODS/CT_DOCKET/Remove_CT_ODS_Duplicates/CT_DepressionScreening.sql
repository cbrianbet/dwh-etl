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
						delete from cte 
						Where Row_Num >1 ;

				INSERT INTO [ODS_logs].[dbo].[CT_DepressionScreeningCount_Log]([SiteCode],[CreatedDate],[DepressionScreeningCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS DepressionScreeningCount 
				FROM [ODS].[dbo].[CT_DepressionScreening] 
				GROUP BY SiteCode;