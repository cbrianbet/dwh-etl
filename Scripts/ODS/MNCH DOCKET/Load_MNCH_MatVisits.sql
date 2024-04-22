
BEGIN
	MERGE [ODS].[dbo].[MNCH_MatVisits] AS a
			USING(SELECT distinct  P.[PatientPk],P.[SiteCode],P.[Emr], P.[Project], P.[Processed], P.[QueueId], P.[Status], P.[StatusDate], P.[DateExtracted]
      , P.[FacilityId], P.[PatientMnchID], P.[FacilityName],[VisitID],[VisitDate],[AdmissionNumber],[ANCVisits],[DateOfDelivery]
      ,[DurationOfDelivery],[GestationAtBirth],[ModeOfDelivery],[PlacentaComplete],[UterotonicGiven],[VaginalExamination]
      ,[BloodLoss],[BloodLossVisual],[ConditonAfterDelivery],[MaternalDeath],[DeliveryComplications],[NoBabiesDelivered]
      ,[BabyBirthNumber],[SexBaby],[BirthWeight],[BirthOutcome],[BirthWithDeformity],[TetracyclineGiven],[InitiatedBF],[ApgarScore1]
      ,[ApgarScore5],[ApgarScore10],[KangarooCare],[ChlorhexidineApplied],[VitaminKGiven],[StatusBabyDischarge],[MotherDischargeDate]
      ,[SyphilisTestResults],[HIVStatusLastANC],[HIVTestingDone],[HIVTest1],[HIV1Results],[HIVTest2],[HIV2Results],[HIVTestFinalResult]
      ,[OnARTANC],[BabyGivenProphylaxis],[MotherGivenCTX],[PartnerHIVTestingMAT],[PartnerHIVStatusMAT],[CounselledOn],[ReferredFrom]
	  ,[ReferredTo],[ClinicalNotes]
	  ,[EDD]
      ,[LMP]
      ,[MaternalDeathAudited]
      ,[OnARTMat]
      ,[ReferralReason],RecordUUID
       FROM [MNCHCentral].[dbo].[MatVisits] P(Nolock)
	   inner join (select tn.PatientPK,tn.SiteCode,max(ID) As MaxID,max(cast(tn.DateExtracted as date))MaxDateExtracted FROM [MNCHCentral].[dbo].[MatVisits] (NoLock)tn
				group by tn.PatientPK,tn.SiteCode)tm
					on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode and cast(p.DateExtracted as date) = tm.MaxDateExtracted and p.ID = tm.MaxID
	    INNER JOIN [MNCHCentral].[dbo].[Facilities] F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID = b.VisitID
						and a.visitDate  = b.visitDate
						and a.PatientMnchID = b.PatientMnchID
						and a.RecordUUID  = b.RecordUUID
							)
					WHEN NOT MATCHED THEN 
						INSERT(PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,FacilityId,PatientMnchID,FacilityName,VisitID,VisitDate,AdmissionNumber,ANCVisits,DateOfDelivery,DurationOfDelivery,GestationAtBirth,ModeOfDelivery,PlacentaComplete,UterotonicGiven,VaginalExamination,BloodLoss,BloodLossVisual,ConditonAfterDelivery,MaternalDeath,DeliveryComplications,NoBabiesDelivered,BabyBirthNumber,SexBaby,BirthWeight,BirthOutcome,BirthWithDeformity,TetracyclineGiven,InitiatedBF,ApgarScore1,ApgarScore5,ApgarScore10,KangarooCare,ChlorhexidineApplied,VitaminKGiven,StatusBabyDischarge,MotherDischargeDate,SyphilisTestResults,HIVStatusLastANC,HIVTestingDone,HIVTest1,HIV1Results,HIVTest2,HIV2Results,HIVTestFinalResult,OnARTANC,BabyGivenProphylaxis,MotherGivenCTX,PartnerHIVTestingMAT,PartnerHIVStatusMAT,CounselledOn,ReferredFrom,ReferredTo,ClinicalNotes,[EDD],[LMP],[MaternalDeathAudited],[OnARTMat],[ReferralReason],LoadDate,RecordUUID)  
						VALUES(PatientPk,SiteCode,Emr,Project,Processed,QueueId,Status,StatusDate,DateExtracted,FacilityId,PatientMnchID,FacilityName,VisitID,VisitDate,AdmissionNumber,ANCVisits,DateOfDelivery,DurationOfDelivery,GestationAtBirth,ModeOfDelivery,PlacentaComplete,UterotonicGiven,VaginalExamination,BloodLoss,BloodLossVisual,ConditonAfterDelivery,MaternalDeath,DeliveryComplications,NoBabiesDelivered,BabyBirthNumber,SexBaby,BirthWeight,BirthOutcome,BirthWithDeformity,TetracyclineGiven,InitiatedBF,ApgarScore1,ApgarScore5,ApgarScore10,KangarooCare,ChlorhexidineApplied,VitaminKGiven,StatusBabyDischarge,MotherDischargeDate,SyphilisTestResults,HIVStatusLastANC,HIVTestingDone,HIVTest1,HIV1Results,HIVTest2,HIV2Results,HIVTestFinalResult,OnARTANC,BabyGivenProphylaxis,MotherGivenCTX,PartnerHIVTestingMAT,PartnerHIVStatusMAT,CounselledOn,ReferredFrom,ReferredTo,ClinicalNotes,[EDD],[LMP],[MaternalDeathAudited],[OnARTMat],[ReferralReason],Getdate(),RecordUUID)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.[Status]	 =b.[Status],
							a.DurationOfDelivery  = b.DurationOfDelivery,
							a.GestationAtBirth  = b.GestationAtBirth,
							a.ModeOfDelivery  = b.ModeOfDelivery,
							a.PlacentaComplete  = b.PlacentaComplete,
							a.UterotonicGiven	= b.UterotonicGiven,
							a.VaginalExamination =b.VaginalExamination,
							a.BloodLoss  = b.BloodLoss,
							a.BloodLossVisual = b.BloodLossVisual,
							a.ConditonAfterDelivery = b.ConditonAfterDelivery,
							a.MaternalDeath = b.MaternalDeath,
							a.DeliveryComplications = b.DeliveryComplications,
							a.NoBabiesDelivered = b.NoBabiesDelivered,
							a.BabyBirthNumber = b.BabyBirthNumber,
							a.SexBaby = b.SexBaby,
							a.BirthWeight = b.BirthWeight,
							a.BirthOutcome = b.BirthOutcome,
							a.BirthWithDeformity =b.BirthWithDeformity,
							a.TetracyclineGiven =b.TetracyclineGiven,
							a.InitiatedBF = b.InitiatedBF,
							a.ApgarScore1 = b.ApgarScore1,
							a.ApgarScore5 = b.ApgarScore5,
							a.ApgarScore10 = b.ApgarScore10,
							a.KangarooCare = b.KangarooCare,
							a.ChlorhexidineApplied = b.ChlorhexidineApplied,
							a.VitaminKGiven = b.VitaminKGiven,
							a.StatusBabyDischarge = b.StatusBabyDischarge,
							a.MotherDischargeDate = b.MotherDischargeDate,
							a.SyphilisTestResults = b.SyphilisTestResults,
							a.HIVStatusLastANC = b.HIVStatusLastANC,
							a.HIVTestingDone = b.HIVTestingDone,
							a.HIVTest1 = b.HIVTest1,
							a.HIV1Results = b.HIV1Results,
							a.HIVTest2 =b.HIVTest2,
							a.HIV2Results = b.HIV2Results,
							a.HIVTestFinalResult = b.HIVTestFinalResult,
							a.OnARTANC = b.OnARTANC,
							a.BabyGivenProphylaxis =  b.BabyGivenProphylaxis,
							a.MotherGivenCTX = b.MotherGivenCTX,
							a.PartnerHIVTestingMAT = b.PartnerHIVTestingMAT,
							a.PartnerHIVStatusMAT =b.PartnerHIVStatusMAT,
							a.CounselledOn = b.CounselledOn,
							a.ReferredFrom = b.ReferredFrom,
							a.ReferredTo = b.ReferredTo,
							a.ClinicalNotes = b.ClinicalNotes,
							a.[EDD]			= b.[EDD],
							a.[LMP]			=b.[LMP],
							a.[MaternalDeathAudited]   = b.[MaternalDeathAudited],
							a.[OnARTMat]				= b.[OnARTMat],
							a.[ReferralReason]			=b.[ReferralReason],
							a.RecordUUID        = b.RecordUUID;

			with cte AS (
						Select
						Sitecode,
						PatientPK,
						VisitID,
						VisitDate,
						PatientMnchID,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,VisitID,VisitDate,PatientMnchID ORDER BY
						PatientPK,Sitecode,VisitDate) Row_Num
						FROM  [ODS].[dbo].[MNCH_MatVisits] (NoLock)
						)
						delete from cte 
						Where Row_Num >1 
						;
END


