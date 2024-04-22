
BEGIN
    --truncate table [ODS].[dbo].[MNCH_Labs]
	MERGE [ODS].[dbo].[MNCH_Labs] AS a
			USING(
					SELECT  distinct P.[PatientPk],P.[SiteCode],P.[Emr],P.[Project],P.[Processed],P.[QueueId],P.[Status],P.[StatusDate]
						  ,[PatientMNCH_ID],P.[FacilityName],[SatelliteName],[VisitID],P.[OrderedbyDate],[ReportedbyDate],[TestName],[TestResult]
						  ,[LabReason],P.[Date_Last_Modified],RecordUUID
					  FROM [MNCHCentral].[dbo].[MnchLabs] P(NoLock)
					  inner join (select tn.PatientPK,tn.SiteCode,tn.[OrderedbyDate],Max(ID) As MaxID,max(tn.DateExtracted)MaxDateExtracted FROM [MNCHCentral].[dbo].[MnchLabs] (NoLock)tn
					group by tn.PatientPK,tn.SiteCode,tn.[OrderedbyDate])tm
					on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and P.[OrderedbyDate] =tm.[OrderedbyDate] and p.DateExtracted = tm.MaxDateExtracted and p.ID = tm.MaxID
					    INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(

						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.[OrderedbyDate] = b.[OrderedbyDate]
						and a.[PatientMNCH_ID] = b.[PatientMNCH_ID]
						and a.visitID = b.visitID
						and a.RecordUUID  = b.RecordUUID
						--and a.[TestName] = b.[TestName]
						--and a.[TestResult] = b.[TestResult]
	
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,PatientMNCH_ID,FacilityName,SatelliteName,VisitID,OrderedbyDate,ReportedbyDate,TestName,TestResult,LabReason,Date_Last_Modified,LoadDate,RecordUUID)  
						VALUES(PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,PatientMNCH_ID,FacilityName,SatelliteName,VisitID,OrderedbyDate,ReportedbyDate,TestName,TestResult,LabReason,Date_Last_Modified,Getdate(),RecordUUID)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status],
							a.TestName = b.TestName,
							a.TestResult = b.TestResult,
							a.LabReason = b.LabReason,
							a.visitID	= b.visitID,
							a.RecordUUID  =b.RecordUUID;

				with cte AS (
						Select
						Sitecode,
						PatientPK,
						[OrderedbyDate],

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,[OrderedbyDate] ORDER BY
						PatientPK,Sitecode,[OrderedbyDate]) Row_Num
						FROM  [ODS].[dbo].[MNCH_Labs](NoLock)
						)
						Delete from cte 
						Where Row_Num >1 ;

END

