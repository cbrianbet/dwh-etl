	with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						visitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
						visitDate desc) Row_Num
						FROM [ODS].[dbo].[CT_GbvScreening](NoLock)
						)
					delete from cte 
						Where Row_Num >1 ;

						INSERT INTO [ODS_logs].[dbo].[CT_GbvScreeningCount_Log]([SiteCode],[CreatedDate],[GbvScreeningCount])
					SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS GbvScreeningCount 
					FROM [ODS].[dbo].[CT_GbvScreening] 
					GROUP BY SiteCode;