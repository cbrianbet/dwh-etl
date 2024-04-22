with cte AS (
						Select
						PatientPK,
						Sitecode,
						visitID,
						VisitDate,
						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,onTBDrugs,OnIPT,EverOnIPT,EvaluatedForIPT,TBScreening,VisitDate ORDER BY
						Date_created  desc) Row_Num
						FROM [ODS].[dbo].[CT_Ipt](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;

					INSERT INTO [ODS_logs].[dbo].[CT_IptCount_Log]([SiteCode],[CreatedDate],[IptCount])
					SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS IptCount 
					FROM [ODS].[dbo].[CT_Ipt] 
					GROUP BY SiteCode;