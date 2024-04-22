with cte AS (
						Select
						Sitecode,
						PatientPK,
						VisitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,VisitDate ORDER BY
						PatientPK,Sitecode,VisitDate) Row_Num
						FROM  [ODS].[dbo].[CT_AdverseEvents](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;

 INSERT INTO [ODS_Logs].[dbo].[ct_adverseeventcount_log]
                ([sitecode],
                 [createddate],
                 [adverseeventcount])
    SELECT sitecode,
           Getdate(),
           Count(Concat(sitecode, patientpk)) AS AdverseEventCount
    FROM   [ODS].[dbo].[ct_adverseevents]
    GROUP  BY sitecode;