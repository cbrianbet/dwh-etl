BEGIN
		;with cte AS ( Select      distinct      
			P.PatientPID,            
			PV.PatientId,            
			F.code,
			PV.VisitID,
			PV.VisitDate,
			PV.created,  ROW_NUMBER() OVER (PARTITION BY P.PatientPID,F.code ,PV.VisitID,PV.VisitDate
			ORDER BY PV.created desc) Row_Num
			FROM [DWAPICentral].[dbo].[PatientExtract] P WITH (NoLock)  
			INNER JOIN [DWAPICentral].[dbo].[PatientVisitExtract] PV WITH(NoLock)  ON PV.[PatientId]= P.ID AND PV.Voided=0
			INNER JOIN [DWAPICentral].[dbo].[Facility] F WITH(NoLock)  ON P.[FacilityId] = F.Id AND F.Voided=0
			WHERE p.gender!='Unknown'  )      
		
			delete pv from  [DWAPICentral].[dbo].[PatientVisitExtract] (NoLock) PV
			inner join [DWAPICentral].[dbo].[PatientExtract](NoLock) P ON PV.[PatientId]= P.ID AND PV.Voided = 0       
			inner join [DWAPICentral].[dbo].[Facility](NoLock) F ON P.[FacilityId] = F.Id AND F.Voided=0       
			inner join cte on PV.PatientId = cte.PatientId  
				and cte.Created = PV.created 
				and cte.Code =  f.Code     
				and cte.VisitID = PV.VisitID
				and cte.VisitDate = PV.VisitDate
			where  Row_Num  > 1;

	 
	 DECLARE	@MaxVisitDate_Hist		DATETIME,
				@VisitDate				DATETIME,
				@MaxCreatedDate			DATETIME
				
		SELECT @MaxVisitDate_Hist	= MAX(MaxVisitDate) FROM [ODS_Logs].[dbo].[CT_Visit_Log]  (NoLock);
		SELECT @VisitDate			= MAX(VisitDate)	FROM [DWAPICentral].[dbo].[PatientVisitExtract] WITH (NOLOCK) ;
		SELECT @MaxCreatedDate		= MAX(CreatedDate)	FROM [ODS_logs].[dbo].[CT_VisitCount_Log] WITH (NOLOCK) ;
				
		INSERT INTO  [ODS_Logs].[dbo].[CT_Visit_Log](MaxVisitDate,LoadStartDateTime)
		VALUES(@VisitDate,GETDATE());

			MERGE [ODS].[dbo].[CT_PatientVisits] AS a
				USING(SELECT distinct   P.[PatientCccNumber] AS PatientID, P.[PatientPID] AS PatientPK,F.[Name] AS FacilityName, F.Code AS SiteCode,PV.[VisitId] VisitID,PV.[VisitDate] VisitDate
						  ,PV.[Service] [SERVICE],PV.[VisitType] VisitType,PV.[WHOStage] WHOStage,PV.[WABStage] WABStage,PV.[Pregnant] Pregnant,PV.[LMP] LMP,PV.[EDD] EDD,PV.[Height] [Height],PV.[Weight] [Weight],PV.[BP] [BP],PV.[OI] [OI],PV.[OIDate] [OIDate]
						  ,PV.[SubstitutionFirstlineRegimenDate] SubstitutionFirstlineRegimenDate,PV.[SubstitutionFirstlineRegimenReason] SubstitutionFirstlineRegimenReason,PV.[SubstitutionSecondlineRegimenDate] SubstitutionSecondlineRegimenDate,PV.[SubstitutionSecondlineRegimenReason] SubstitutionSecondlineRegimenReason
						  ,PV.[SecondlineRegimenChangeDate] SecondlineRegimenChangeDate,PV.[SecondlineRegimenChangeReason] SecondlineRegimenChangeReason,PV.[Adherence] Adherence,PV.[AdherenceCategory] AdherenceCategory,PV.[FamilyPlanningMethod] FamilyPlanningMethod
						  ,PV.[PwP] PwP,PV.[GestationAge] GestationAge,PV.[NextAppointmentDate] NextAppointmentDate,P.[Emr] Emr
						  ,CASE P.[Project]
									WHEN 'I-TECH' THEN 'Kenya HMIS II' 
									WHEN 'HMIS' THEN 'Kenya HMIS II'
								ELSE P.[Project] 
							END AS [Project] 
						  ,PV.[Voided] Voided,pv.[StabilityAssessment] StabilityAssessment,pv.[DifferentiatedCare] DifferentiatedCare,pv.[PopulationType] PopulationType,pv.[KeyPopulationType] KeyPopulationType,PV.[Processed] Processed
						  ,PV.[Created] Created						  
						 ,[GeneralExamination],[SystemExamination],[Skin],[Eyes],[ENT],[Chest],[CVS],[Abdomen],[CNS],[Genitourinary]
							-----Missing columns Added later by Dennis
						  ,PV.VisitBy VisitBy,PV.Temp Temp,PV.PulseRate PulseRate,PV.RespiratoryRate RespiratoryRate,PV.OxygenSaturation OxygenSaturation,PV.Muac Muac,PV.NutritionalStatus NutritionalStatus,PV.EverHadMenses EverHadMenses,PV.Menopausal Menopausal
						  ,PV.Breastfeeding Breastfeeding,PV.NoFPReason NoFPReason,PV.ProphylaxisUsed ProphylaxisUsed,PV.CTXAdherence CTXAdherence,PV.CurrentRegimen CurrentRegimen,PV.HCWConcern HCWConcern,PV.TCAReason TCAReason,PV.ClinicalNotes ClinicalNotes
						  ,P.ID as PatientUnique_ID
						  ,PV.PatientId as UniquePatientVisitId
						  ,PV.ID as PatientVisitUnique_ID
						  ,[ZScore]
							,[ZScoreAbsolute]
							,RefillDate
							,PaedsDisclosure,PV.[Date_Created],PV.[Date_Last_Modified]
							,PV.RecordUUID
							,[WHOStagingOI]
						FROM [DWAPICentral].[dbo].[PatientExtract] P WITH (NoLock)  
						INNER JOIN [DWAPICentral].[dbo].[PatientVisitExtract] PV WITH(NoLock)  ON PV.[PatientId]= P.ID 						
						INNER JOIN [DWAPICentral].[dbo].[Facility] F WITH(NoLock)  ON P.[FacilityId] = F.Id AND F.Voided=0
						INNER JOIN (
								SELECT F.code as SiteCode,p.[PatientPID] as PatientPK,[VisitId],visitDate,InnerPV.voided,max(InnerPV.ID) maxID, MAX(InnerPV.created) AS Maxdatecreated
								FROM [DWAPICentral].[dbo].[PatientExtract] P WITH (NoLock)  						
									INNER JOIN [DWAPICentral].[dbo].[PatientVisitExtract] InnerPV WITH(NoLock)  ON InnerPV.[PatientId]= P.ID 
									INNER JOIN [DWAPICentral].[dbo].[Facility] F WITH(NoLock)  ON P.[FacilityId] = F.Id AND F.Voided=0
								GROUP BY F.code,p.[PatientPID],[VisitId],visitDate,InnerPV.voided
							) tm 
							ON f.code = tm.[SiteCode] and p.PatientPID=tm.PatientPK and 
							pv.[VisitId] = tm.[VisitId] and pv.visitDate = tm.visitDate and pv.voided = tm.voided and 
							pv.created = tm.Maxdatecreated and
							PV.ID =tm. maxID
						WHERE p.gender!='Unknown' AND F.code >0) AS b 
						ON(
							 a.PatientPK  = b.PatientPK 
							AND a.SiteCode = b.SiteCode
							AND a.visitID = b.[VisitId]
							and a.visitDate = b.visitDate	
							and a.voided   = b.voided				
							)
					WHEN NOT MATCHED THEN 
							INSERT(PatientID,FacilityName,SiteCode,PatientPK,VisitID,VisitDate,[SERVICE],VisitType,WHOStage,WABStage,Pregnant,LMP,EDD,Height,[Weight],BP,OI,OIDate,Adherence,AdherenceCategory,FamilyPlanningMethod,PwP,GestationAge,NextAppointmentDate,Emr,Project,DifferentiatedCare,StabilityAssessment,KeyPopulationType,PopulationType,VisitBy,Temp,PulseRate,RespiratoryRate,OxygenSaturation,Muac,NutritionalStatus,EverHadMenses,Breastfeeding,Menopausal,NoFPReason,ProphylaxisUsed,CTXAdherence,CurrentRegimen,HCWConcern,TCAReason,ClinicalNotes,[ZScore],[ZScoreAbsolute],RefillDate,PaedsDisclosure,[Date_Created],[Date_Last_Modified],RecordUUID,voided,[WHOStagingOI],LoadDate)  
							VALUES(PatientID,FacilityName,SiteCode,PatientPK,VisitID,VisitDate,[SERVICE],VisitType,WHOStage,WABStage,Pregnant,LMP,EDD,Height,[Weight],BP,OI,OIDate,Adherence,AdherenceCategory,FamilyPlanningMethod,PwP,GestationAge,NextAppointmentDate,Emr,Project,DifferentiatedCare,StabilityAssessment,KeyPopulationType,PopulationType,VisitBy,Temp,PulseRate,RespiratoryRate,OxygenSaturation,Muac,NutritionalStatus,EverHadMenses,Breastfeeding,Menopausal,NoFPReason,ProphylaxisUsed,CTXAdherence,CurrentRegimen,HCWConcern,TCAReason,ClinicalNotes,[ZScore],[ZScoreAbsolute],RefillDate,PaedsDisclosure,[Date_Created],[Date_Last_Modified],RecordUUID,voided,[WHOStagingOI],Getdate())
			
					WHEN MATCHED THEN
						UPDATE SET 	
						a.PatientID					=b.PatientID,
						a.[SERVICE]					= b.[SERVICE],
						a.VisitType					= b.VisitType,
						a.WHOStage					= b.WHOStage,
						a.WABStage					= b.WABStage,
						a.Pregnant					= b.Pregnant,
						a.LMP						=b.LMP,
						a.EDD						=b.EDD,
						a.Height					=b.Height,
						a.[Weight]					=b.[Weight],
						a.BP						=b.BP,
						a.OI						=b.OI,
						a.OIDate					=b.OIDate,
						a.Adherence					=b.Adherence,
						a.AdherenceCategory			=b.AdherenceCategory,
						a.FamilyPlanningMethod		=b.FamilyPlanningMethod,
						a.PwP						=b.PwP,
						a.GestationAge				=b.GestationAge,
						a.DifferentiatedCare		=b.DifferentiatedCare,
						a.StabilityAssessment		=b.StabilityAssessment,
						a.KeyPopulationType			=b.KeyPopulationType,
						a.PopulationType			=b.PopulationType	,
						a.VisitBy					=b.VisitBy			,
						a.Temp						=b.Temp				,
						a.PulseRate					=b.PulseRate		,
						a.RespiratoryRate			=b.RespiratoryRate	,
						a.OxygenSaturation			=b.OxygenSaturation	,
						a.Muac						=b.Muac				,
						a.NutritionalStatus			=b.NutritionalStatus	,
						a.EverHadMenses				=b.EverHadMenses		,
						a.Breastfeeding				=b.Breastfeeding		,
						a.Menopausal				=b.Menopausal		,
						a.NoFPReason				=b.NoFPReason		,
						a.ProphylaxisUsed			=b.ProphylaxisUsed	,
						a.CTXAdherence				=b.CTXAdherence		,
						a.CurrentRegimen			=b.CurrentRegimen	,
						a.HCWConcern				=b.HCWConcern		,
						a.TCAReason					=b.TCAReason,
						a.ClinicalNotes				=b.ClinicalNotes,
						a.GeneralExamination		=b.GeneralExamination,
						a.SystemExamination			=b.SystemExamination,
						a.Skin						=b.Skin	,
						a.Eyes						=b.Eyes	,
						a.ENT						=b.ENT	,
						a.Chest						=b.Chest,
						a.CVS						=b.CVS,
						a.Abdomen					=b.Abdomen,
						a.CNS						=b.CNS,
						a.Genitourinary				=b.Genitourinary,
						a.NextAppointmentDate       =b.NextAppointmentDate,
						a.RefillDate				=b.RefillDate,
						a.PaedsDisclosure			=b.PaedsDisclosure,
						a.[Date_Created]			=b.[Date_Created],
						a.[Date_Last_Modified]		=b.[Date_Last_Modified],
						a.RecordUUID			    =b.RecordUUID,
						a.voided		            =b.voided,
						a.[WHOStagingOI]            =b.[WHOStagingOI];

			UPDATE [ODS_Logs].[dbo].[CT_Visit_Log]
				  SET LoadEndDateTime = GETDATE()
				  WHERE MaxVisitDate = @VisitDate;			
			
END
