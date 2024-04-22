
BEGIN
    --truncate table [ODS].[dbo].[MNCH_Arts]
	MERGE [ODS].[dbo].[MNCH_Arts] AS a
			USING(
					SELECT  distinct  P.[PatientPk],P.[SiteCode],P.[Emr], P.[Project], P.[Processed], P.[QueueId], P.[Status], P.[StatusDate], P.[DateExtracted]
						  , P.[Pkv], P.[PatientMnchID], P.[PatientHeiID], P.[FacilityName],[RegistrationAtCCC],[StartARTDate],[StartRegimen]
						  ,[StartRegimenLine],[StatusAtCCC],[LastARTDate],[LastRegimen],[LastRegimenLine], P.[Date_Created], P.[Date_Last_Modified]
					     ,[FacilityReceivingARTCare],RecordUUID
					   FROM [MNCHCentral].[dbo].[MnchArts] P(NoLock) 
				inner join (select tn.PatientPK,tn.SiteCode,max(ID) As MaxID,max(cast(tn.DateExtracted as date))MaxDateExtracted FROM [MNCHCentral].[dbo].[MnchArts] (NoLock)tn
				group by tn.PatientPK,tn.SiteCode)tm
					on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and cast(p.DateExtracted as date) = tm.MaxDateExtracted
					and p.ID = tm.MaxID
			INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.[PatientMnchID] = b.[PatientMnchID]
						and a.RecordUUID = b.RecordUUID
						
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,PatientMnchID,PatientHeiID,FacilityName,RegistrationAtCCC,StartARTDate,StartRegimen,StartRegimenLine,StatusAtCCC,LastARTDate,LastRegimen,LastRegimenLine,Date_Created,Date_Last_Modified,[FacilityReceivingARTCare],LoadDate,RecordUUID)  
						VALUES(PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,PatientMnchID,PatientHeiID,FacilityName,RegistrationAtCCC,StartARTDate,StartRegimen,StartRegimenLine,StatusAtCCC,LastARTDate,LastRegimen,LastRegimenLine,Date_Created,Date_Last_Modified,[FacilityReceivingARTCare],Getdate(),RecordUUID)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status],
							a.LastRegimen = b.LastRegimen,
							a.StartRegimen = b.StartRegimen,
							a.StartRegimenLine = b.StartRegimenLine,
							a.[FacilityReceivingARTCare]  = b.[FacilityReceivingARTCare],
							a.RecordUUID  = b.RecordUUID;
END





