with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						visitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,visitID,visitDate ORDER BY
						visitDate desc) Row_Num
						FROM [ODS].[dbo].[CT_PatientVisits](NoLock)
						)
					delete from cte 
						Where Row_Num >1 ;

INSERT INTO [ODS_logs].[dbo].[CT_VisitCount_Log]([SiteCode],[CreatedDate],[VisitCount])
			SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS VisitCount 
			FROM [ODS].[dbo].[CT_PatientVisits] 
			GROUP BY SiteCode;
