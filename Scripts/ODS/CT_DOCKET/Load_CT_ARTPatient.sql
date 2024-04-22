BEGIN
     --truncate table [ODS].[dbo].[CT_ARTPatients]
			MERGE [ODS].[dbo].[CT_ARTPatients]  AS a
				USING(SELECT  DISTINCT PA.ID,
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,F.Name AS FacilityName, PA.[AgeEnrollment]
						,PA.[AgeARTStart],PA.[AgeLastVisit],PA.[RegistrationDate],PA.[PatientSource],PA.[Gender],PA.[StartARTDate],PA.[PreviousARTStartDate]
						,PA.[PreviousARTRegimen],PA.[StartARTAtThisFacility],PA.[StartRegimen],PA.[StartRegimenLine],PA.[LastARTDate],PA.[LastRegimen]
						,PA.[LastRegimenLine],PA.[Duration],PA.[ExpectedReturn],PA.[Provider],PA.[LastVisit],PA.[ExitReason],PA.[ExitDate],P.[Emr]
								,CASE P.[Project] 
									WHEN 'I-TECH' THEN 'Kenya HMIS II' 
									WHEN 'HMIS' THEN 'Kenya HMIS II'
								ELSE P.[Project] 
								END AS [Project]
								,PA.[DOB]

						,PA.[PreviousARTUse]
						,PA.[PreviousARTPurpose]
						,PA.[DateLastUsed]
						,PA.[Date_Created],PA.[Date_Last_Modified]
						,GETDATE () AS DateAsOf,
						PA.RecordUUID,PA.voided
						FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P 
						INNER JOIN [DWAPICentral].[dbo].[PatientArtExtract](NoLock) PA ON PA.[PatientId]= P.ID 
						INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0 
						INNER JOIN (SELECT a.PatientPID,c.code,Max(cast(b.created as date))MaxCreated FROM [DWAPICentral].[dbo].[PatientExtract]  a  with (NoLock)
											INNER JOIN [DWAPICentral].[dbo].[PatientArtExtract] b with(NoLock) ON b.[PatientId]= a.ID 
											INNER JOIN [DWAPICentral].[dbo].[Facility] c with (NoLock)  ON a.[FacilityId] = c.Id AND c.Voided=0 
											GROUP BY  a.PatientPID,c.code)tn
									on P.PatientPID = tn.PatientPID and F.code = tn.code and cast(PA.Created as date) = tn.MaxCreated
						WHERE p.gender!='Unknown' AND F.code >0) AS b	
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.lastvisit = b.lastvisit
						and a.voided   = b.voided
						and a.ID = b.ID
						
						)
					
					WHEN NOT MATCHED THEN 

						INSERT(
							  ID,PatientID,PatientPK,SiteCode,FacilityName,AgeEnrollment,AgeARTStart,AgeLastVisit,RegistrationDate,PatientSource,Gender,StartARTDate,PreviousARTStartDate,PreviousARTRegimen,StartARTAtThisFacility,StartRegimen,StartRegimenLine,LastARTDate,LastRegimen,
							  LastRegimenLine,Duration,ExpectedReturn,Provider,LastVisit,ExitReason,ExitDate,Emr,Project,[DOB],PreviousARTUse,PreviousARTPurpose,DateLastUsed,DateAsOf,[Date_Created],[Date_Last_Modified],RecordUUID,voided,LoadDate)
							   
						VALUES(
								ID,PatientID,PatientPK,SiteCode,FacilityName,AgeEnrollment,AgeARTStart,AgeLastVisit,RegistrationDate,PatientSource,Gender,StartARTDate,PreviousARTStartDate,PreviousARTRegimen,StartARTAtThisFacility,StartRegimen,StartRegimenLine,LastARTDate,LastRegimen,
								LastRegimenLine,Duration,ExpectedReturn,Provider,LastVisit,ExitReason,ExitDate,Emr,Project,[DOB],PreviousARTUse,PreviousARTPurpose,DateLastUsed,DateAsOf,[Date_Created],[Date_Last_Modified],RecordUUID,voided,Getdate())

					WHEN MATCHED THEN
						UPDATE SET 
								a.PatientID					=b.PatientID,
								a.[AgeEnrollment]			=b.[AgeEnrollment],
								a.[AgeARTStart]				=b.[AgeARTStart],	
								a.[AgeLastVisit]			=b.[AgeLastVisit],
								a.[FacilityName]			=b.[FacilityName],
								a.[RegistrationDate]		=b.[RegistrationDate],
								a.[PatientSource]			=b.[PatientSource],
								a.[Gender]					=b.[Gender]	,
								a.[StartARTDate]			=b.[StartARTDate],
								a.[PreviousARTStartDate]	=b.[PreviousARTStartDate],
								a.[PreviousARTRegimen]		=b.[PreviousARTRegimen]	,
								a.[StartARTAtThisFacility]	=b.[StartARTAtThisFacility],
								a.[StartRegimen]			=b.[StartRegimen],
								a.[StartRegimenLine]		=b.[StartRegimenLine],
								a.[LastARTDate]				=b.[LastARTDate],	
								a.[LastRegimen]				=b.[LastRegimen],	
								a.[LastRegimenLine]			=b.[LastRegimenLine],	
								a.[Duration]				=b.[Duration],
								a.[ExpectedReturn]			=b.[ExpectedReturn],
								a.[Provider]				=b.[Provider],
								a.[ExitReason]				=b.[ExitReason]	,
								a.[ExitDate]				=b.[ExitDate],
								a.[Emr]						=b.[Emr],			
								a.[PreviousARTUse]			=b.[PreviousARTUse]	,
								a.[PreviousARTPurpose]		=b.[PreviousARTPurpose],
								a.[DateLastUsed]			=b.[DateLastUsed],
								a.lastvisit					=b.lastvisit,
								a.[Date_Created]			=b.[Date_Created],
								a.[Date_Last_Modified]		=b.[Date_Last_Modified],
								a.RecordUUID				=b.RecordUUID,
								a.voided					=b.voided;

	END
