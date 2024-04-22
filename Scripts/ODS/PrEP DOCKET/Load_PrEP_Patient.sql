
BEGIN
MERGE [ODS].[dbo].[PrEP_Patient] AS a
	USING(SELECT  ID
				  ,[RefId]
				  ,[Created]
				  ,c.[PatientPk]
				  ,c.[SiteCode]
				  ,[Emr]
				  ,[Project]
				  ,[Processed]
				  ,[QueueId]
				  ,[Status]
				  ,[StatusDate]
				  ,[DateExtracted]
				  ,[FacilityId]
				  ,[FacilityName]
				  ,[PrepNumber]
				  ,[HtsNumber]
				  ,[PrepEnrollmentDate]
				  ,[Sex]
				  ,[DateofBirth]
				  ,[CountyofBirth]
				  ,[County]
				  ,[SubCounty]
				  ,[Location]
				  ,[LandMark]
				  ,[Ward]
				  ,[ClientType]
				  ,[ReferralPoint]
				  ,[MaritalStatus]
				  ,[Inschool]
				  ,null [PopulationType]
				  ,null [KeyPopulationType]
				  ,[Refferedfrom]
				  ,[TransferIn]
				  ,[TransferInDate]
				  ,[TransferFromFacility]
				  ,[DatefirstinitiatedinPrepCare]
				  ,[DateStartedPrEPattransferringfacility]
				  ,[ClientPreviouslyonPrep]
				  ,[PrevPrepReg]
				  ,[DateLastUsedPrev]
				  ,[Date_Created]
				  ,[Date_Last_Modified]
				  ,RecordUUID
 	 FROM [PREPCentral].[dbo].[PrepPatients](NoLock) c
	 INNER JOIN 
		(SELECT patientPK,sitecode,Max(ID)As MaxID,max(cast(created as date))as Maxcreated from [PREPCentral].[dbo].[PrepPatients](NoLock) group by patientPK,sitecode)tn
		on c.patientPK = tn.patientPK 
			and c.sitecode =tn.sitecode and cast(c.created as date) = tn.Maxcreated and C.ID = tn.MaxID
			) AS b 
	 
	ON(
			a.PatientPK  = b.PatientPK						
		and a.SiteCode = b.SiteCode
		and a.RecordUUID = b.RecordUUID
		) 
	 WHEN NOT MATCHED THEN 
		  INSERT(ID,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PrepNumber,HtsNumber,PrepEnrollmentDate,Sex,DateofBirth,CountyofBirth,County,SubCounty,[Location],LandMark,Ward,ClientType,ReferralPoint,MaritalStatus,Inschool,PopulationType,KeyPopulationType,Refferedfrom,TransferIn,TransferInDate,TransferFromFacility,DatefirstinitiatedinPrepCare,DateStartedPrEPattransferringfacility,ClientPreviouslyonPrep,PrevPrepReg,DateLastUsedPrev,Date_Created
			  ,Date_Last_Modified,LoadDate,RecordUUID)
		  VALUES(ID,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PrepNumber,HtsNumber,PrepEnrollmentDate,Sex,DateofBirth,CountyofBirth,County,SubCounty,[Location],LandMark,Ward,ClientType,ReferralPoint,MaritalStatus,Inschool,PopulationType,KeyPopulationType,Refferedfrom,TransferIn,TransferInDate,TransferFromFacility,DatefirstinitiatedinPrepCare,DateStartedPrEPattransferringfacility,ClientPreviouslyonPrep,PrevPrepReg,DateLastUsedPrev,Date_Created
				,Date_Last_Modified,Getdate(),RecordUUID)

	  WHEN MATCHED THEN
				UPDATE SET 													
					a.Status=b.Status,
					a.StatusDate=b.StatusDate,													
					a.CountyofBirth=b.CountyofBirth,
					a.County=b.County,
					a.SubCounty=b.SubCounty,
					a.Location=b.Location,
					a.LandMark=b.LandMark,
					a.Ward=b.Ward,
					a.ClientType=b.ClientType,
					a.ReferralPoint=b.ReferralPoint,
					a.MaritalStatus=b.MaritalStatus,
					a.Inschool=b.Inschool,
					a.PopulationType=b.PopulationType,
					a.KeyPopulationType=b.KeyPopulationType,
					a.Refferedfrom=b.Refferedfrom,
					a.TransferIn=b.TransferIn,
					a.TransferInDate=b.TransferInDate,
					a.TransferFromFacility=b.TransferFromFacility,
					a.DatefirstinitiatedinPrepCare=b.DatefirstinitiatedinPrepCare,
					a.DateStartedPrEPattransferringfacility=b.DateStartedPrEPattransferringfacility,
					a.ClientPreviouslyonPrep=b.ClientPreviouslyonPrep,
					a.PrevPrepReg=b.PrevPrepReg,
					a.RecordUUID = b.RecordUUID;

			with cte AS (
				Select
				PatientPK,
				sitecode,

				 ROW_NUMBER() OVER (PARTITION BY PatientPK,sitecode ORDER BY
				PatientPK,sitecode) Row_Num
				FROM [ODS].[dbo].[PrEP_Patient](NoLock)
				)
			delete   from cte 
				Where Row_Num >1;										

	END

					