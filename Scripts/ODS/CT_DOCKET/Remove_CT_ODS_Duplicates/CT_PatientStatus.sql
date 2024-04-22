with cte AS (
									Select
									PatientPK,
									SiteCode,
									ExitDate,

									 ROW_NUMBER() OVER (PARTITION BY SiteCode,PatientPK,ExitDate ORDER BY
									EffectiveDiscontinuationDate,ReEnrollmentDate desc) Row_Num
									FROM [ODS].[dbo].[CT_PatientStatus]PS WITH (NoLock)
									)
								delete  from cte 
									Where Row_Num >1;
									
 INSERT INTO [ODS_logs].[dbo].[CT_PatientStatusCount_Log]
                ([sitecode],
                 [createddate],
                 [patientstatuscount])
    SELECT sitecode,
           Getdate(),
           Count(Concat(sitecode, patientpk)) AS PatientStatusCount
    FROM   [ODS].[dbo].[ct_patientstatus]
    GROUP  BY sitecode;