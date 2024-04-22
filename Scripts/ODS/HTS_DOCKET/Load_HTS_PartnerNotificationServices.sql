BEGIN

		MERGE [ODS].[dbo].[HTS_PartnerNotificationServices] AS a
			USING(SELECT DISTINCT a.ID,a.[FacilityName]
				  ,a.[SiteCode]
				  ,a.[PatientPk]
				  ,a.[HtsNumber]
				  ,a.[Emr]
				  ,a.[Project]
				  ,[PartnerPatientPk]
				  ,a.[KnowledgeOfHivStatus]
				  ,[PartnerPersonID]
				  ,[CccNumber]
				  ,[IpvScreeningOutcome]
				  ,[ScreenedForIpv]
				  ,[PnsConsent]
				  ,a.[RelationsipToIndexClient]
				  ,[LinkedToCare]
				  ,a.[MaritalStatus]
				  ,[PnsApproach]
				  ,[FacilityLinkedTo]
				  ,LEFT([Sex], 1) AS Gender
				  ,[CurrentlyLivingWithIndexClient]    
				  ,[Age]
				  ,[DateElicited]
				  ,a.[Dob]
				  ,[LinkDateLinkedToCare]
					,a.Dateextracted
					,a.RecordUUID
					,a.IndexPatientPk
			  FROM [HTSCentral].[dbo].[HtsPartnerNotificationServices](NoLock) a
			INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
			  on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode
			  ) AS b 
			ON(
				a.PatientPK  = b.PatientPK 
				and a.SiteCode = b.SiteCode					
				and a.PartnerPersonID  = b.PartnerPersonID 
				and a.PartnerPatientPk  = b.PartnerPatientPk 				
				and a.DateElicited  = b.DateElicited
				and a.Dob  = b.Dob
				and a.ID = b.ID

			)
	WHEN NOT MATCHED THEN 
		INSERT(ID,FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,PartnerPatientPk,KnowledgeOfHivStatus,PartnerPersonID,CccNumber,IpvScreeningOutcome,ScreenedForIpv,PnsConsent,RelationsipToIndexClient,LinkedToCare,MaritalStatus,PnsApproach,FacilityLinkedTo,Gender,CurrentlyLivingWithIndexClient,Age,DateElicited,Dob,LinkDateLinkedToCare,RecordUUID,IndexPatientPk,LoadDate ) 
		VALUES(ID,FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,PartnerPatientPk,KnowledgeOfHivStatus,PartnerPersonID,CccNumber,IpvScreeningOutcome,ScreenedForIpv,PnsConsent,RelationsipToIndexClient,LinkedToCare,MaritalStatus,PnsApproach,FacilityLinkedTo,Gender,CurrentlyLivingWithIndexClient,Age,DateElicited,Dob,LinkDateLinkedToCare,RecordUUID,IndexPatientPk,Getdate())

	WHEN MATCHED THEN
		UPDATE SET 
			
				a.[KnowledgeOfHivStatus]			=b.[KnowledgeOfHivStatus],				
				a.[IpvScreeningOutcome]				=b.[IpvScreeningOutcome],	
				a.[ScreenedForIpv]					=b.[ScreenedForIpv]	,
				a.[PnsConsent]						=b.[PnsConsent],
				a.[RelationsipToIndexClient]		=b.[RelationsipToIndexClient],
				a.[LinkedToCare]					=b.[LinkedToCare],
				a.[MaritalStatus]					=b.[MaritalStatus],
				a.[PnsApproach]						=b.[PnsApproach],	
				a.[FacilityLinkedTo]				=b.[FacilityLinkedTo],
				a.[Gender]							=b.[Gender],
				a.[CurrentlyLivingWithIndexClient]	=b.[CurrentlyLivingWithIndexClient],	
				a.[LinkDateLinkedToCare]			=b.[LinkDateLinkedToCare],
				a.RecordUUID                         = b.RecordUUID,
				a.IndexPatientPk                     = b.IndexPatientPk;

				

				;with cte AS ( Select            
					a.*, 
					ROW_NUMBER() OVER (PARTITION BY a.FacilityName,a.SiteCode,a.PatientPk,a.HtsNumber,a.Emr,a.Project,a.PartnerPatientPk,a.KnowledgeOfHivStatus,a.PartnerPersonID,a.CccNumber,a.IpvScreeningOutcome,a.ScreenedForIpv,a.PnsConsent,a.
													RelationsipToIndexClient,a.LinkedToCare,a.PnsApproach,a.FacilityLinkedTo,a.CurrentlyLivingWithIndexClient,a.Age,a.DateElicited,a.Dob,a.LinkDateLinkedToCare
									
					ORDER BY a.SiteCode,a.PatientPk desc) Row_Num
			from [ODS].[dbo].[HTS_PartnerNotificationServices] a
			-- where a.HtsNumber = 'mggwca' and a.SiteCode = 12483 and a.PatientPk = 953 
			  ) 
			  

			  delete from cte where Row_Num >1
	
END
	
