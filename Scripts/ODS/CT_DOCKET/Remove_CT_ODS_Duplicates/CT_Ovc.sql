	with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						visitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
						PatientPK,Sitecode,visitID,visitDate) Row_Num
						FROM [ODS].[dbo].[CT_Ovc](NoLock)
						)
					delete from cte 
						Where Row_Num >1 ;

				INSERT INTO [ODS_logs].[dbo].[CT_OvcCount_Log]([SiteCode],[CreatedDate],[OvcCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS OVCCount 
				FROM [ODS].[dbo].[CT_Ovc] 
				GROUP BY SiteCode;