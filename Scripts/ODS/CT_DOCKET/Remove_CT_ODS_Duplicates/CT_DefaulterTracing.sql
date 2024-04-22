with cte AS (
							Select
							PatientPK,
							Sitecode,
							visitID,
							visitDate,

								ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
							PatientPK,Sitecode,visitID,visitDate) Row_Num
							FROM [ODS].[dbo].[CT_DefaulterTracing](NoLock))
							
							delete from cte 
								Where Row_Num >1 ;

				INSERT INTO [ODS_Logs].[dbo].[CT_DefaulterTracingCount_Log]([SiteCode],[CreatedDate],[DefaulterTracingCount])
				SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS DefaulterTracingCount 
				FROM [ODS].[dbo].CT_DefaulterTracing
				GROUP BY SiteCode;