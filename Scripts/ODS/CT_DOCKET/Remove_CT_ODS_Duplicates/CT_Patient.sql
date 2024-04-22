	with cte AS (
						Select
						PatientPK,
						Sitecode,
						

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode ORDER BY
						PatientPK,Sitecode) Row_Num
						FROM [ODS].[dbo].[CT_Patient](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;

INSERT INTO [ODS_Logs].[dbo].[CT_PatientCount_Log] ([SiteCode],[CreatedDate],[PatientCount])
SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS PatientCount 
FROM [ODS].[dbo].[CT_Patient] 
GROUP BY SiteCode;