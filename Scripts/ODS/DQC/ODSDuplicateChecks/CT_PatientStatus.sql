with cte AS (
									Select
									PatientPK,
									SiteCode,
									ExitDate,

									 ROW_NUMBER() OVER (PARTITION BY SiteCode,PatientPK,ExitDate ORDER BY
									EffectiveDiscontinuationDate,ReEnrollmentDate desc) Row_Num
									FROM [ODS].[dbo].[CT_PatientStatus]PS WITH (NoLock)
									)
								select count(*)  from cte 
									Where Row_Num >1;