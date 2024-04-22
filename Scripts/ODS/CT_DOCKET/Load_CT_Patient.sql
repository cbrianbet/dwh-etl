BEGIN
			
			 DECLARE @MaxRegistrationDate_Hist			DATETIME,
					 @RegistrationDate					DATETIME
				
			SELECT @MaxRegistrationDate_Hist	= MAX(MaxRegistrationDate) FROM [ODS_Logs].[dbo].[CT_Patient_Log]  (NoLock)
			SELECT @RegistrationDate			= MAX(RegistrationDate) FROM [DWAPICentral].[dbo].[PatientExtract] (NoLock)
									
			INSERT INTO  [ODS_Logs].[dbo].[CT_Patient_Log](MaxRegistrationDate,LoadStartDateTime)
			VALUES(@RegistrationDate,GETDATE())
			--truncate table [ODS].[dbo].[CT_Patient] 
			MERGE [ODS].[dbo].[CT_Patient] AS a
				USING(SELECT  DISTINCT P.ID,P.[PatientCccNumber] as PatientID,P.[PatientPID] as PatientPK,F.Code as SiteCode,F.[Name] as FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC
										,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village
									   ,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,P.Emr,P.Project,Orphan,Inschool,PatientType,null PopulationType,null KeyPopulationType,PatientResidentCounty,
									   PatientResidentSubCounty,PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI
									   ,Pkv,P.[Date_Created],P.[Date_Last_Modified]
									   ,P.RecordUUID,P.voided
						FROM [DWAPICentral].[dbo].[PatientExtract]  P  with (NoLock)
						INNER JOIN [DWAPICentral].[dbo].[Facility] F with (NoLock)  
						ON P.[FacilityId]  = F.Id  AND F.Voided=0 	
						INNER JOIN (SELECT P.PatientPID,p.PatientCccNumber,F.code,max(p.ID) As Max_ID,Max(cast(P.created as date))MaxCreated FROM [DWAPICentral].[dbo].[PatientExtract]  P  with (NoLock)
									INNER JOIN [DWAPICentral].[dbo].[Facility] F with (NoLock)  
									ON P.[FacilityId]  = F.Id
									GROUP BY  P.PatientPID,F.code,p.PatientCccNumber)tn
							on P.PatientPID = tn.PatientPID and 
							F.code = tn.code and 
							cast(P.Created as date) = tn.MaxCreated
							and P.ID = tn.Max_ID
							and p.PatientCccNumber = tn.PatientCccNumber
						WHERE  P.[Gender] is NOT NULL and p.gender!='Unknown' AND F.code >0 ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.voided   = b.voided
						and a.ID =b.ID

						)

						WHEN NOT MATCHED THEN 
						INSERT(ID,PatientID,PatientPK,SiteCode,FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,Emr,Project,Orphan,Inschool,PatientType,PopulationType,KeyPopulationType,PatientResidentCounty,PatientResidentSubCounty,PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI,Pkv,[Date_Created],[Date_Last_Modified],RecordUUID,voided,LoadDate)  
						VALUES(ID,PatientID,PatientPK,SiteCode,FacilityName,Gender,DOB,RegistrationDate,RegistrationAtCCC,RegistrationAtPMTCT,RegistrationAtTBClinic,PatientSource,Region,District,Village,ContactRelation,LastVisit,MaritalStatus,EducationLevel,DateConfirmedHIVPositive,PreviousARTExposure,PreviousARTStartDate,Emr,Project,Orphan,Inschool,PatientType,PopulationType,KeyPopulationType,PatientResidentCounty,PatientResidentSubCounty,PatientResidentLocation,PatientResidentSubLocation,PatientResidentWard,PatientResidentVillage,TransferInDate,Occupation,NUPI,Pkv,[Date_Created],[Date_Last_Modified],RecordUUID,voided,Getdate())
				
						WHEN MATCHED THEN
							UPDATE SET 				
							a.PatientID					=b.PatientID,
							a.nupi       				 = b.nupi,
							a.PatientSource				=b.PatientSource,							
							a.ContactRelation			=b.ContactRelation,
							a.LastVisit					=b.LastVisit,
							a.MaritalStatus				=b.MaritalStatus,
							a.DateConfirmedHIVPositive	=b.DateConfirmedHIVPositive	,
							a.PreviousARTExposure		=b.PreviousARTExposure,
							a.PreviousARTStartDate		=b.PreviousARTStartDate,
							a.Orphan					=b.Orphan,
							a.Inschool					=b.Inschool	,
							a.PatientType				=b.PatientType,
							a.PopulationType			=b.PopulationType,
							a.KeyPopulationType			=b.KeyPopulationType,
							a.PatientResidentCounty		=b.PatientResidentCounty,
							a.PatientResidentSubCounty	=b.PatientResidentSubCounty,
							a.PatientResidentLocation	=b.PatientResidentLocation,
							a.PatientResidentSubLocation=b.PatientResidentSubLocation,
							a.PatientResidentWard		=b.PatientResidentWard	,
							a.PatientResidentVillage	=b.PatientResidentVillage,
							a.TransferInDate			=b.TransferInDate,
							a.Occupation				=b.Occupation,
							a.Pkv						=b.Pkv,
							a.[Date_Created]			=b.[Date_Created],
							a.[Date_Last_Modified]		=b.[Date_Last_Modified],
							a.RecordUUID			=b.RecordUUID,
							a.voided		=b.voided;
																

					UPDATE [ODS_Logs].[dbo].[CT_Patient_Log]
						SET LoadEndDateTime = GETDATE()
					WHERE MaxRegistrationDate = @RegistrationDate;

	END
