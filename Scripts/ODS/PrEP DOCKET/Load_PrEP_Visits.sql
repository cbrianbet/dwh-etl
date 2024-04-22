
BEGIN
MERGE [ODS].[dbo].[PrEP_Visits] AS a
	USING(SELECT distinct
				  a.[RefId]
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
				  ,a.[HtsNumber]
				  ,[EncounterId]
				  ,[VisitID]
				  ,[VisitDate]
				  ,[BloodPressure]
				  ,[Temperature]
				  ,[Weight]
				  ,[Height]
				  ,[BMI]
				  ,[STIScreening]
				  ,[STISymptoms]
				  ,[STITreated]
				  ,[Circumcised]
				  ,[VMMCReferral]
				  ,[LMP]
				  ,[MenopausalStatus]
				  ,[PregnantAtThisVisit]
				  ,[EDD]
				  ,[PlanningToGetPregnant]
				  ,[PregnancyPlanned]
				  ,[PregnancyEnded]
				  ,[PregnancyEndDate]
				  ,[PregnancyOutcome]
				  ,[BirthDefects]
				  ,[Breastfeeding]
				  ,[FamilyPlanningStatus]
				  ,[FPMethods]
				  ,[AdherenceDone]
				  ,[AdherenceOutcome]
				  ,[AdherenceReasons]
				  ,[SymptomsAcuteHIV]
				  ,[ContraindicationsPrep]
				  ,[PrepTreatmentPlan]
				  ,[PrepPrescribed]
				  ,[RegimenPrescribed]
				  ,[MonthsPrescribed]
				  ,[CondomsIssued]
				  ,[Tobegivennextappointment]
				  ,[Reasonfornotgivingnextappointment]
				  ,[HepatitisBPositiveResult]
				  ,[HepatitisCPositiveResult]
				  ,[VaccinationForHepBStarted]
				  ,[TreatedForHepB]
				  ,[VaccinationForHepCStarted]
				  ,[TreatedForHepC]
				  ,[NextAppointment]
				  ,[ClinicalNotes]
				  ,a.[Date_Created]
				  ,a.[Date_Last_Modified]
				  ,a.RecordUUID
		FROM [PREPCentral].[dbo].[PrepVisits](NoLock) a
			INNER JOIN (SELECT PatientPk, SiteCode,Max(ID)As MaxID ,max(cast(Created as date)) AS maxCreated 
						from [PREPCentral].[dbo].[PrepVisits]
							group by PatientPk,SiteCode) tn
		ON a.PatientPk = tn.PatientPk and a.SiteCode = tn.SiteCode and cast(a.Created as date) = tn.maxCreated and a.ID = tn.MaxID

		INNER JOIN (SELECT PatientPk, SiteCode,Max(ID)As MaxID ,max(cast(DateExtracted as date)) AS maxDateExtracted 
					from [PREPCentral].[dbo].[PrepVisits]
					group by PatientPk,SiteCode) tm
			ON a.PatientPk = tm.PatientPk and a.SiteCode = tm.SiteCode and cast(a.DateExtracted as date)= tm.maxDateExtracted and a.ID = tm.MaxID
		)AS b      
            ON(

				a.PatientPK  = b.PatientPK						
			and a.SiteCode = b.SiteCode
			and a.visitID = b.visitID
			and a.VisitDate = b. visitDate
			and a.RecordUUID  = b.RecordUUID
			) 

	 WHEN NOT MATCHED THEN 
		  INSERT(RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PrepNumber,HtsNumber
		  ,VisitDate,VisitID,BloodPressure,Temperature,Weight,Height,BMI,STIScreening,STISymptoms,STITreated,Circumcised,VMMCReferral,LMP,MenopausalStatus,
		  PregnantAtThisVisit,EDD,PlanningToGetPregnant,PregnancyPlanned,PregnancyEnded,PregnancyEndDate,PregnancyOutcome,BirthDefects,Breastfeeding,FamilyPlanningStatus,
		  FPMethods,AdherenceDone,AdherenceOutcome,AdherenceReasons,SymptomsAcuteHIV,ContraindicationsPrep,PrepTreatmentPlan,PrepPrescribed,RegimenPrescribed,MonthsPrescribed,
		  CondomsIssued,Tobegivennextappointment,Reasonfornotgivingnextappointment,HepatitisBPositiveResult,HepatitisCPositiveResult,VaccinationForHepBStarted,TreatedForHepB,
		  VaccinationForHepCStarted,TreatedForHepC,NextAppointment,ClinicalNotes,Date_Created,Date_Last_Modified,LoadDate,RecordUUID) 
		  
		  VALUES(RefId,Created,PatientPk,SiteCode,Emr,Project,Processed,QueueId,[Status],StatusDate,DateExtracted,FacilityId,FacilityName,PrepNumber,HtsNumber,
          VisitDate,VisitID,BloodPressure,Temperature,Weight,Height,BMI,STIScreening,STISymptoms,STITreated,Circumcised,VMMCReferral,LMP,MenopausalStatus,
		  PregnantAtThisVisit,EDD,PlanningToGetPregnant,PregnancyPlanned,PregnancyEnded,PregnancyEndDate,PregnancyOutcome,BirthDefects,Breastfeeding,FamilyPlanningStatus,
		  FPMethods,AdherenceDone,AdherenceOutcome,AdherenceReasons,SymptomsAcuteHIV,ContraindicationsPrep,PrepTreatmentPlan,PrepPrescribed,RegimenPrescribed,MonthsPrescribed,
		  CondomsIssued,Tobegivennextappointment,Reasonfornotgivingnextappointment,HepatitisBPositiveResult,HepatitisCPositiveResult,VaccinationForHepBStarted,TreatedForHepB,
		  VaccinationForHepCStarted,TreatedForHepC,NextAppointment,ClinicalNotes,Date_Created,Date_Last_Modified,Getdate(),RecordUUID)
		  
	 WHEN MATCHED THEN
		UPDATE SET													
				a.Status=b.Status,
				a.StatusDate=b.StatusDate,							
				a.BloodPressure = b.BloodPressure,
				a.Temperature=b.Temperature,
				a.Weight=b.Weight,
				a.Height=b.Height,
				a.BMI=b.BMI,
				a.STIScreening=b.STIScreening,
				a.STISymptoms=b.STISymptoms,
				a.STITreated=b.STITreated,
				a.Circumcised=b.Circumcised,
				a.VMMCReferral=b.VMMCReferral,
                a.LMP=b.LMP,
				a.MenopausalStatus=b.MenopausalStatus,
				a.PregnantAtThisVisit=b.PregnantAtThisVisit,
				a.EDD=b.EDD,
				a.PlanningToGetPregnant=b.PlanningToGetPregnant,
				a.PregnancyPlanned = b.PregnancyPlanned,
				a.PregnancyEnded=b.PregnancyEnded,
				a.PregnancyEndDate=b.PregnancyEndDate,
                a.PregnancyOutcome=b.PregnancyOutcome,
				a.BirthDefects=b.BirthDefects,
				a.Breastfeeding=b.Breastfeeding,
                a.FamilyPlanningStatus=b.FamilyPlanningStatus,
                a.FPMethods=b.FPMethods,
				a.AdherenceDone=b.AdherenceDone,
                a.AdherenceOutcome=b.AdherenceOutcome,
				a.AdherenceReasons=b.AdherenceReasons,
				a.SymptomsAcuteHIV=b.SymptomsAcuteHIV,
                a.ContraindicationsPrep=b.ContraindicationsPrep,
                a.PrepTreatmentPlan=b.PrepTreatmentPlan,
                a.PrepPrescribed=b.PrepPrescribed,
                a.RegimenPrescribed=b.RegimenPrescribed,
                a.MonthsPrescribed=b.MonthsPrescribed,
                a.CondomsIssued=b.CondomsIssued,
                a.Tobegivennextappointment=b.Tobegivennextappointment,
                a.Reasonfornotgivingnextappointment=b.Reasonfornotgivingnextappointment,
                a.HepatitisBPositiveResult=b.HepatitisBPositiveResult,
                a.HepatitisCPositiveResult=b.HepatitisCPositiveResult,
				a.VaccinationForHepBStarted=b.VaccinationForHepBStarted,
				a.TreatedForHepB=b.TreatedForHepB,
				a.VaccinationForHepCStarted=b.VaccinationForHepCStarted,
				a.TreatedForHepC=b.TreatedForHepC,
				a.NextAppointment=b.NextAppointment,
				a.ClinicalNotes=b.ClinicalNotes,
				a.RecordUUID   = b.RecordUUID;					
																
END

					