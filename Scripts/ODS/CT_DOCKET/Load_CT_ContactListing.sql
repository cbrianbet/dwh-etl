
BEGIN
		DECLARE		@MaxDateCreated_Hist			DATETIME,
				   @DateCreated					DATETIME
				
		SELECT @MaxDateCreated_Hist =  MAX(MaxDateCreated) FROM [ODS].[dbo].[CT_ContactListing_Log]  (NoLock)
		SELECT @MaxDateCreated_Hist = MAX(Created) FROM [DWAPICentral].[dbo].[ContactListingExtract](NoLock)
							
		INSERT INTO  [ODS].[dbo].[CT_ContactListing_Log](MaxDateCreated,LoadStartDateTime)
		VALUES(@MaxDateCreated_Hist,GETDATE())
	       ---- Refresh [ODS].[dbo].[CT_ContactListing]
			MERGE [ODS].[dbo].[CT_ContactListing] AS a
				USING(SELECT
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
						GETDATE() AS DateImported,
					  ContactPatientPK,
					  CL.Created as DateCreated
					  ,P.ID as  PatientUnique_ID
					  ,CL.PatientId as UniquePatientContactListingId
					  ,CL.ID as  ContactListingUnique_ID
					FROM [DWAPICentral].[dbo].[PatientExtract](NoLock) P
					INNER JOIN [DWAPICentral].[dbo].[ContactListingExtract](NoLock) CL ON CL.[PatientId] = P.ID AND CL.Voided = 0
					INNER JOIN [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
					WHERE P.gender != 'Unknown') AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.PatientUnique_ID =b.UniquePatientContactListingId
						and a.Contactage = b.Contactage 
						and a.RelationshipWithPatient =b.RelationshipWithPatient 
						)

					WHEN NOT MATCHED THEN 
						INSERT(PatientID,PatientPK,SiteCode,FacilityName,Emr,Project,PartnerPersonID,ContactAge,ContactSex,ContactMaritalStatus,RelationshipWithPatient,ScreenedForIpv,IpvScreening,IPVScreeningOutcome,CurrentlyLivingWithIndexClient,KnowledgeOfHivStatus,PnsApproach,DateImported,ContactPatientPK,DateCreated,PatientUnique_ID,ContactListingUnique_ID) 
						VALUES(PatientID,PatientPK,SiteCode,FacilityName,Emr,Project,PartnerPersonID,ContactAge,ContactSex,ContactMaritalStatus,RelationshipWithPatient,ScreenedForIpv,IpvScreening,IPVScreeningOutcome,CurrentlyLivingWithIndexClient,KnowledgeOfHivStatus,PnsApproach,DateImported,ContactPatientPK,DateCreated,PatientUnique_ID,ContactListingUnique_ID)
				
					WHEN MATCHED THEN
						UPDATE SET 					
						a.FacilityName					=b.FacilityName,
						a.ContactAge					=b.ContactAge,
						a.ContactSex					=b.ContactSex,
						a.ContactMaritalStatus			=b.ContactMaritalStatus,
						a.RelationshipWithPatient		=b.RelationshipWithPatient,
						a.ScreenedForIpv				=b.ScreenedForIpv,
						a.IpvScreening					=b.IpvScreening,
						a.IPVScreeningOutcome			=b.IPVScreeningOutcome,
						a.CurrentlyLivingWithIndexClient=b.CurrentlyLivingWithIndexClient,
						a.KnowledgeOfHivStatus			=b.KnowledgeOfHivStatus,
						a.PnsApproach					=b.PnsApproach;

				UPDATE [ODS].[dbo].[CT_ContactListing_Log]
					SET LoadEndDateTime = GETDATE()
				WHERE MaxDateCreated = @MaxDateCreated_Hist;


	END