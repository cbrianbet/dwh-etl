
BEGIN
--truncate table [ODS].[dbo].[PrEP_AdverseEvent]
MERGE [ODS].[dbo].[PrEP_AdverseEvent] AS a
	USING(SELECT distinct
				  a.[Id]
				  ,a.[RefId]
				  ,a.[Created]
				  ,a.[PatientPk]
				  ,a.[SiteCode]
				  ,a.[Emr]
				  ,a.[Project]
				  ,a.[Processed]
				  ,a.[QueueId]
				  ,a.[Status]
				  ,a.[StatusDate]
				  ,a.[DateExtracted]
				  ,a.[FacilityId]
				  ,a.[FacilityName]
				  ,a.[PrepNumber]
				  ,[AdverseEvent]
				  ,[AdverseEventStartDate]
				  ,[AdverseEventEndDate]
				  ,[Severity]
				  ,[VisitDate]
				  ,[AdverseEventActionTaken]
				  ,[AdverseEventClinicalOutcome]
				  ,[AdverseEventIsPregnant]
				  ,[AdverseEventCause]
				  ,[AdverseEventRegimen]
				  ,a.[Date_Created]
				  ,a.[Date_Last_Modified]
				  ,a.RecordUUID
				  
			FROM [PREPCentral].[dbo].[PrepAdverseEvents](NoLock) a
			INNER JOIN 
			(SELECT patientPK,sitecode,max(ID) As MaxID,max(cast(created as date))as Maxcreated from [PREPCentral].[dbo].[PrepAdverseEvents](NoLock) group by patientPK,sitecode)tn
			on a.patientPK = tn.patientPK 
				and a.sitecode =tn.sitecode and cast(a.created as date) = tn.Maxcreated
				and a.ID  = tn.MaxID
			inner join    [PREPCentral].[dbo].[PrepPatients](NoLock) b
			on a.SiteCode = b.SiteCode 
			and a.PatientPk =  b.PatientPk
			and a.[PrepNumber] = b.[PrepNumber]
			
			) AS b 	 
			ON(

			a.PatientPK  = b.PatientPK						
			and a.SiteCode = b.SiteCode
			and a.Id = b.ID
			and a.RecordUUID = b.RecordUUID
		)  
	WHEN NOT MATCHED THEN 

		  INSERT( Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,
		  FacilityId,FacilityName,PrepNumber,AdverseEvent,AdverseEventStartDate,AdverseEventEndDate,Severity,VisitDate,
		  AdverseEventActionTaken,AdverseEventClinicalOutcome,AdverseEventIsPregnant,AdverseEventCause,
		  AdverseEventRegimen,Date_Created,Date_Last_Modified,LoadDate,RecordUUID) 

		  VALUES(Id,RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,FacilityId,
		  FacilityName,PrepNumber,AdverseEvent,AdverseEventStartDate,AdverseEventEndDate,Severity,VisitDate,
		  AdverseEventActionTaken,AdverseEventClinicalOutcome,AdverseEventIsPregnant,AdverseEventCause,AdverseEventRegimen,
		  Date_Created,Date_Last_Modified,Getdate(),RecordUUID)

	WHEN MATCHED THEN UPDATE SET 															 								
		a.AdverseEvent					=b.AdverseEvent,
		a.Severity						=b.Severity,
		a.AdverseEventCause				=b.AdverseEventCause,
		a.AdverseEventRegimen			=b.AdverseEventRegimen,
		a.AdverseEventActionTaken		=b.AdverseEventActionTaken,
		a.AdverseEventClinicalOutcome	=b.AdverseEventClinicalOutcome,
		a.AdverseEventIsPregnant		=b.AdverseEventIsPregnant,
		a.Date_Last_Modified            =b.Date_Last_Modified,
		a.RecordUUID					=b.RecordUUID;
		
		with cte AS (
						Select
						Sitecode,
						PatientPK,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode ORDER BY
						PatientPK,Sitecode) Row_Num
						FROM  [ODS].[dbo].[PrEP_AdverseEvent](NoLock)
						)
						Delete from cte 
						Where Row_Num >1 ;
						
END

					