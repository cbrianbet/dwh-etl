	with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						visitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
						visitDate desc) Row_Num
						FROM [ODS].[dbo].[CT_DrugAlcoholScreening](NoLock)
						)
					delete from cte 
						Where Row_Num >1 ;

				INSERT INTO [ODS_logs].[dbo].[CT_DrugAlcoholScreeningCount_Log]([SiteCode],[CreatedDate],[DrugAlcoholScreeningCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS DrugAlcoholScreeningCount 
				FROM [ODS].[dbo].[CT_DrugAlcoholScreening] 
				GROUP BY [SiteCode];