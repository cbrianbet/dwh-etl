	with cte AS (
								Select
								PatientPK,
								sitecode,
								lastvisit,
								 ROW_NUMBER() OVER (PARTITION BY PatientPK,sitecode ORDER BY
								lastvisit desc) Row_Num
								FROM [ODS].[dbo].[CT_ARTPatients](NoLock)
								)
							delete from cte 
								Where Row_Num >1;
								

INSERT INTO  [ODS_logs].[dbo].[CT_ARTPatientsCount_Log]([SiteCode],[CreatedDate],ARTPatientsCount)
SELECT SiteCode,GETDATE(),COUNT(concat(Sitecode,PatientPK)) AS PatientStatusCount 
FROM [ODS].[dbo].[CT_ARTPatients]
group by SiteCode