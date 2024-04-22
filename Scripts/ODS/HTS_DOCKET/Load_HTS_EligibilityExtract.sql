BEGIN
 --truncate table [ODS].[dbo].[HTS_EligibilityExtract]
		MERGE [ODS].[dbo].[HTS_EligibilityExtract] AS a
			USING(SELECT DISTINCT  a.ID,a.[FacilityName],a.[SiteCode],a.[PatientPk],a.[HtsNumber],a.[Emr],a.[Project],a.[Processed],a.[QueueId],a.[Status]
							,a.[StatusDate],a.[EncounterId],a.[VisitID],a.[VisitDate],a.[PopulationType],[KeyPopulation],[PriorityPopulation],[Department]
							,[PatientType],[IsHealthWorker],[RelationshipWithContact],[TestedHIVBefore],[WhoPerformedTest],[ResultOfHIV],[DateTestedSelf]
							,[StartedOnART],[CCCNumber],[EverHadSex],[SexuallyActive],[NewPartner],[PartnerHIVStatus],a.[CoupleDiscordant],[MultiplePartners]
							,[NumberOfPartners],[AlcoholSex],[MoneySex],[CondomBurst],[UnknownStatusPartner],[KnownStatusPartner],[Pregnant],[BreastfeedingMother]
							,[ExperiencedGBV],[ContactWithTBCase],[Lethargy],[EverOnPrep],[CurrentlyOnPrep],[EverOnPep],[CurrentlyOnPep],[EverHadSTI],[CurrentlyHasSTI]
							,[EverHadTB],[SharedNeedle],[NeedleStickInjuries],[TraditionalProcedures],[ChildReasonsForIneligibility],[EligibleForTest]
							,[ReasonsForIneligibility],[SpecificReasonForIneligibility],a.[FacilityId],[Cough],[DateTestedProvider],[Fever],[MothersStatus]
							,[NightSweats],[ReferredForTesting],[ResultOfHIVSelf],[ScreenedTB],[TBStatus],[WeightLoss],[AssessmentOutcome],[ForcedSex]
							,[ReceivedServices],[TypeGBV]
							,Disability
							,a.DisabilityType
							,HTSStrategy
							,HTSEntryPoint
							,HIVRiskCategory
							,ReasonRefferredForTesting
							,ReasonNotReffered
							,[HtsRiskScore]
							,a.RecordUUID
						FROM [HTSCentral].[dbo].[HtsEligibilityExtract] (NoLock)a
						Inner join ( select ct.sitecode,ct.patientPK,ct.encounterID,ct.visitID,max(ID)As MaxID,max(DateCreated)MaxDateCreated  from [HTSCentral].[dbo].[HtsEligibilityExtract] ct
									group by ct.sitecode,ct.patientPK,ct.encounterID,ct.visitID)tn
									on a.sitecode = tn.sitecode and a.patientPK = tn.patientPK
									and a.DateCreated = tn.MaxDateCreated
									and a.encounterID = tn.encounterID
									and a.visitID = tn.visitID
									and a.ID = tn.MaxID
									
						Inner join ( select ct1.sitecode,ct1.patientPK,ct1.encounterID,ct1.visitID,Max(ID)As MaxID,max(cast(ct1.DateExtracted as date))MaxDateExtracted  from [HTSCentral].[dbo].[HtsEligibilityExtract] ct1
									group by ct1.sitecode,ct1.patientPK,ct1.encounterID,ct1.visitID)tn1
									on a.sitecode = tn1.sitecode and a.patientPK = tn1.patientPK
									and cast(a.DateExtracted as date) = tn1.MaxDateExtracted
									and a.encounterID = tn1.encounterID
									and a.visitID = tn1.visitID
									and a.ID  = tn1.MaxID

						INNER JOIN [HTSCentral].[dbo].Clients (NoLock) Cl
						on a.PatientPk = Cl.PatientPk and a.SiteCode = Cl.SiteCode				
					
				) AS b 
				ON(
					a.PatientPK  = b.PatientPK 
					and a.SiteCode = b.SiteCode	
					and a.encounterID = b.encounterID
					and a.visitID = b.visitID
					and a.ID = b.ID
					

				)
		WHEN NOT MATCHED THEN 
			INSERT(ID,FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,Processed,QueueId,Status,StatusDate,EncounterId,VisitID,VisitDate,PopulationType,KeyPopulation,PriorityPopulation,Department,PatientType,IsHealthWorker,RelationshipWithContact,TestedHIVBefore,WhoPerformedTest,ResultOfHIV,DateTestedSelf,StartedOnART,CCCNumber,EverHadSex,SexuallyActive,NewPartner,PartnerHIVStatus,CoupleDiscordant,MultiplePartners,NumberOfPartners,AlcoholSex,MoneySex,CondomBurst,UnknownStatusPartner,KnownStatusPartner,Pregnant,BreastfeedingMother,ExperiencedGBV,ContactWithTBCase,Lethargy,EverOnPrep,CurrentlyOnPrep,EverOnPep,CurrentlyOnPep,EverHadSTI,CurrentlyHasSTI,EverHadTB,SharedNeedle,NeedleStickInjuries,TraditionalProcedures,ChildReasonsForIneligibility,EligibleForTest,ReasonsForIneligibility,SpecificReasonForIneligibility,Cough,DateTestedProvider,Fever,MothersStatus,NightSweats,ReferredForTesting,ResultOfHIVSelf,ScreenedTB,TBStatus,WeightLoss,AssessmentOutcome,ForcedSex,ReceivedServices,TypeGBV,Disability,DisabilityType,HTSStrategy,HTSEntryPoint,HIVRiskCategory,ReasonRefferredForTesting,ReasonNotReffered,[HtsRiskScore],RecordUUID,LoadDate)  
			VALUES(ID,FacilityName,SiteCode,PatientPk,HtsNumber,Emr,Project,Processed,QueueId,Status,StatusDate,EncounterId,VisitID,VisitDate,PopulationType,KeyPopulation,PriorityPopulation,Department,PatientType,IsHealthWorker,RelationshipWithContact,TestedHIVBefore,WhoPerformedTest,ResultOfHIV,DateTestedSelf,StartedOnART,CCCNumber,EverHadSex,SexuallyActive,NewPartner,PartnerHIVStatus,CoupleDiscordant,MultiplePartners,NumberOfPartners,AlcoholSex,MoneySex,CondomBurst,UnknownStatusPartner,KnownStatusPartner,Pregnant,BreastfeedingMother,ExperiencedGBV,ContactWithTBCase,Lethargy,EverOnPrep,CurrentlyOnPrep,EverOnPep,CurrentlyOnPep,EverHadSTI,CurrentlyHasSTI,EverHadTB,SharedNeedle,NeedleStickInjuries,TraditionalProcedures,ChildReasonsForIneligibility,EligibleForTest,ReasonsForIneligibility,SpecificReasonForIneligibility,Cough,DateTestedProvider,Fever,MothersStatus,NightSweats,ReferredForTesting,ResultOfHIVSelf,ScreenedTB,TBStatus,WeightLoss,AssessmentOutcome,ForcedSex,ReceivedServices,TypeGBV,Disability,DisabilityType,HTSStrategy,HTSEntryPoint,HIVRiskCategory,ReasonRefferredForTesting,ReasonNotReffered,[HtsRiskScore],RecordUUID,Getdate())
		
		WHEN MATCHED THEN
			UPDATE SET 
					
					a.[PopulationType]					=b.[PopulationType]	,
					a.[KeyPopulation]					=b.[KeyPopulation],
					a.[PriorityPopulation]				=b.[PriorityPopulation]	,
					a.[Department]						=b.[Department]	,
					a.[PatientType]						=b.[PatientType],
					a.[IsHealthWorker]					=b.[IsHealthWorker],
					a.[RelationshipWithContact]			=b.[RelationshipWithContact],
					a.[TestedHIVBefore]					=b.[TestedHIVBefore],
					a.[WhoPerformedTest]				=b.[WhoPerformedTest],
					a.[ResultOfHIV]						=b.[ResultOfHIV],
					a.[DateTestedSelf]					=b.[DateTestedSelf],
					a.[StartedOnART]					=b.[StartedOnART],
					a.[CCCNumber]						=b.[CCCNumber],
					a.[EverHadSex]						=b.[EverHadSex]	,
					a.[SexuallyActive]					=b.[SexuallyActive]	,
					a.[NewPartner]						=b.[NewPartner]	,
					a.[PartnerHIVStatus]				=b.[PartnerHIVStatus],
					a.[CoupleDiscordant]				=b.[CoupleDiscordant],
					a.[MultiplePartners]				=b.[MultiplePartners],
					a.[NumberOfPartners]				=b.[NumberOfPartners],
					a.[AlcoholSex]						=b.[AlcoholSex]	,
					a.[MoneySex]						=b.[MoneySex]	,
					a.[CondomBurst]						=b.[CondomBurst],
					a.[UnknownStatusPartner]			=b.[UnknownStatusPartner],
					a.[KnownStatusPartner]				=b.[KnownStatusPartner]	,
					a.[Pregnant]						=b.[Pregnant],
					a.[BreastfeedingMother]				=b.[BreastfeedingMother],
					a.[ExperiencedGBV]					=b.[ExperiencedGBV]	,
					a.[ContactWithTBCase]				=b.[ContactWithTBCase],
					a.[Lethargy]						=b.[Lethargy],
					a.[EverOnPrep]						=b.[EverOnPrep]	,
					a.[CurrentlyOnPrep]					=b.[CurrentlyOnPrep],
					a.[EverOnPep]						=b.[EverOnPep],
					a.[CurrentlyOnPep]					=b.[CurrentlyOnPep]	,
					a.[EverHadSTI]						=b.[EverHadSTI]	,
					a.[CurrentlyHasSTI]					=b.[CurrentlyHasSTI],
					a.[EverHadTB]						=b.[EverHadTB]	,
					a.[SharedNeedle]					=b.[SharedNeedle]	,
					a.[NeedleStickInjuries]				=b.[NeedleStickInjuries],
					a.[TraditionalProcedures]			=b.[TraditionalProcedures],
					a.[ChildReasonsForIneligibility]	=b.[ChildReasonsForIneligibility],
					a.[EligibleForTest]					=b.[EligibleForTest],
					a.[ReasonsForIneligibility]			=b.[ReasonsForIneligibility],
					a.[SpecificReasonForIneligibility]	=b.[SpecificReasonForIneligibility]	,
					a.[Cough]							=b.[Cough]				,
					a.[DateTestedProvider]				=b.[DateTestedProvider]	,
					a.[Fever]							=b.[Fever]				,
					a.[MothersStatus]					=b.[MothersStatus]		,
					a.[NightSweats]						=b.[NightSweats]		,
					a.[ReferredForTesting]				=b.[ReferredForTesting]	,
					a.[ResultOfHIVSelf]					=b.[ResultOfHIVSelf]	,
					a.[ScreenedTB]						=b.[ScreenedTB]	,
					a.[TBStatus]						=b.[TBStatus],
					a.[WeightLoss]						=b.[WeightLoss]	,
					a.[AssessmentOutcome]				=b.[AssessmentOutcome],
					a.[ForcedSex]						=b.[ForcedSex],
					a.[ReceivedServices]				=b.[ReceivedServices],
					a.[TypeGBV]							=b.[TypeGBV],
					a.[HIVRiskCategory]                 =b.[HIVRiskCategory],
					a.Disability						=b.Disability,					
					a.DisabilityType					=b.DisabilityType,
					a.HTSStrategy						=b.HTSStrategy,
					a.HTSEntryPoint						=b.HTSEntryPoint,
					a.ReasonRefferredForTesting         =b.ReasonRefferredForTesting,
					a.ReasonNotReffered                 =b.ReasonNotReffered,
					a.[HtsRiskScore]					=b.[HtsRiskScore],
					a.RecordUUID                          =b.RecordUUID;

			
END
