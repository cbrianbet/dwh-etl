
BEGIN
		DECLARE		@MaxDateCreated_Hist			DATETIME,
				   @DateCreated					DATETIME
				
		SELECT @MaxDateCreated_Hist =  MAX(MaxDateCreated) FROM [ODS_Logs].[dbo].[CT_ContactListing_Log]   (NoLock)
		SELECT @MaxDateCreated_Hist = MAX(Created) FROM [DWAPICentral].[dbo].[ContactListingExtract](NoLock)
							
		INSERT INTO  [ODS_Logs].[dbo].[CT_ContactListing_Log] (MaxDateCreated,LoadStartDateTime)
		VALUES(@MaxDateCreated_Hist,GETDATE())
	       ---- Refresh [ODS].[dbo].[CT_ContactListing]
			MERGE [ODS].[dbo].[CT_ContactListing] AS a
				USING(SELECT distinct
						P.[PatientCccNumber] AS PatientID,P.[PatientPID] AS PatientPK,F.Code AS SiteCode,
						F.Name AS FacilityName,P.[Emr] AS Emr,
						CASE
							P.[Project]
							WHEN 'I-TECH' THEN 'Kenya HMIS II'
							WHEN 'HMIS' THEN 'Kenya HMIS II'
							ELSE P.[Project]
						END AS Project,
						CL.[PartnerPersonID] AS PartnerPersonID,CL.[ContactAge] AS ContactAge,CL.[ContactSex] AS ContactSex,
						CL.[ContactMaritalStatus] AS ContactMaritalStatus,CL.[RelationshipWithPatient] AS RelationshipWithPatient,
						CL.[ScreenedForIpv] AS ScreenedForIpv,CL.[IpvScreening] AS IpvScreening,
						CL.[IPVScreeningOutcome] AS IPVScreeningOutcome,
						CL.[CurrentlyLivingWithIndexClient] AS CurrentlyLivingWithIndexClient,
						CL.[KnowledgeOfHivStatus] AS KnowledgeOfHivStatus,CL.[PnsApproach] AS PnsApproach,					
					  ContactPatientPK,
					  CL.Created as DateCreated
					  ,CL.ID,CL.[Date_Created],CL.[Date_Last_Modified],
					  CL.RecordUUID,CL.voided
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[ContactListingExtract](NoLock) CL ON CL.[PatientId] = P.ID 
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					INNER JOIN (SELECT p.[PatientPID],F.code,CL.Contactage,max(cast(cl.created as date))Maxcreated 
								FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
								INNER JOIN [DWAPICentral].[dbo].[ContactListingExtract](NoLock) CL ON CL.[PatientId] = P.ID 
								INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
								GROUP BY p.[PatientPID],F.code,CL.Contactage)tn
								on p.[PatientPID] = tn.[PatientPID] and 
								F.code = tn.code and 
								cast(cl.created as date) = tn.Maxcreated and
								 cl.Contactage = tn.Contactage
					WHERE P.gender != 'Unknown' AND F.code >0) AS b 
						ON(
						 a.SiteCode = b.SiteCode
						and a.PatientPK  = b.PatientPK 
						and a.Contactage = b.Contactage 
						and a.RelationshipWithPatient =b.RelationshipWithPatient 
						and a.voided   = b.voided
						and a.ID = b.ID
						)

					WHEN NOT MATCHED THEN 
						INSERT(ID,PatientID,PatientPK,SiteCode,FacilityName,Emr,Project,PartnerPersonID,ContactAge,ContactSex,ContactMaritalStatus,RelationshipWithPatient,ScreenedForIpv,IpvScreening,IPVScreeningOutcome,CurrentlyLivingWithIndexClient,KnowledgeOfHivStatus,PnsApproach,ContactPatientPK,DateCreated,[Date_Created],[Date_Last_Modified],RecordUUID,voided,LoadDate)  
						VALUES(ID,PatientID,PatientPK,SiteCode,FacilityName,Emr,Project,PartnerPersonID,ContactAge,ContactSex,ContactMaritalStatus,RelationshipWithPatient,ScreenedForIpv,IpvScreening,IPVScreeningOutcome,CurrentlyLivingWithIndexClient,KnowledgeOfHivStatus,PnsApproach,ContactPatientPK,DateCreated,[Date_Created],[Date_Last_Modified],RecordUUID,voided,Getdate())
				
					WHEN MATCHED THEN
						UPDATE SET 	
						a.PatientID						=b.PatientID,
						a.ContactAge					=b.ContactAge,
						a.ContactSex					=b.ContactSex,
						a.ContactPatientPK				=b.ContactPatientPK,
						a.ContactMaritalStatus			=b.ContactMaritalStatus,
						a.RelationshipWithPatient		=b.RelationshipWithPatient,
						a.ScreenedForIpv				=b.ScreenedForIpv,
						a.IpvScreening					=b.IpvScreening,
						a.IPVScreeningOutcome			=b.IPVScreeningOutcome,
						a.CurrentlyLivingWithIndexClient=b.CurrentlyLivingWithIndexClient,
						a.KnowledgeOfHivStatus			=b.KnowledgeOfHivStatus,
						a.PnsApproach					=b.PnsApproach,
						a.[Date_Created]				=b.[Date_Created],
						a.[Date_Last_Modified]			=b.[Date_Last_Modified],
						a.RecordUUID					=b.RecordUUID,
						a.voided						=b.voided;					

				UPDATE [ODS_Logs].[dbo].[CT_ContactListing_Log] 
					SET LoadEndDateTime = GETDATE()
				WHERE MaxDateCreated = @MaxDateCreated_Hist;


	END
