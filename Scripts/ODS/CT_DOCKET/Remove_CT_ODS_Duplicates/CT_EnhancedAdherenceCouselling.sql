with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						visitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
						visitDate desc) Row_Num
						FROM [ODS].[dbo].[CT_EnhancedAdherenceCounselling](NoLock)
						)
					delete from cte 
						Where Row_Num >1 ;

					INSERT INTO [ODS_logs].[dbo].[CT_EnhancedAdherenceCounsellingCount_Log]([SiteCode],[CreatedDate],[EnhancedAdherenceCounsellingCount])
					SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS EnhancedAdherenceCounsellingCount 
					FROM [ODS].[dbo].[CT_EnhancedAdherenceCounselling] 
					GROUP BY SiteCode;