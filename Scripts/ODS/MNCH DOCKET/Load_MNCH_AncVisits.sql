
BEGIN
--truncate table [ODS].[dbo].[MNCH_AncVisits]
	MERGE [ODS].[dbo].[MNCH_AncVisits] AS a
		USING(
				SELECT  Distinct P.[PatientMnchID],[ANCClinicNumber], P.[PatientPk],F.[SiteCode], P.[FacilityName],P.[EMR], P.[Project]
					  ,[VisitID],cast(p.[VisitDate] as date)[VisitDate],[ANCVisitNo],[GestationWeeks],[Height],[Weight],[Temp],[PulseRate],[RespiratoryRate]
					  ,[OxygenSaturation],[MUAC],[BP],[BreastExam],[AntenatalExercises],[FGM],[FGMComplications],[Haemoglobin],[DiabetesTest],[TBScreening]
					  ,[CACxScreen],[CACxScreenMethod],[WHOStaging],[VLSampleTaken],[VLDate],[VLResult],[SyphilisTreatment],[HIVStatusBeforeANC]
					  ,[HIVTestingDone],[HIVTestType],[HIVTest1],[HIVTest1Result],[HIVTest2],[HIVTest2Result],[HIVTestFinalResult],[SyphilisTestDone]
					  ,[SyphilisTestType],[SyphilisTestResults],[SyphilisTreated],[MotherProphylaxisGiven],[MotherGivenHAART],[AZTBabyDispense]
					  ,[NVPBabyDispense],[ChronicIllness],[CounselledOn],[PartnerHIVTestingANC],[PartnerHIVStatusANC],[PostParturmFP],[Deworming]
					  ,[MalariaProphylaxis],[TetanusDose],[IronSupplementsGiven],[ReceivedMosquitoNet],[PreventiveServices],[UrinalysisVariables]
					  ,[ReferredFrom],[ReferredTo],[ReferralReasons],cast([NextAppointmentANC] as date)[NextAppointmentANC]
					  ,[ClinicalNotes] , P.[Date_Last_Modified],RecordUUID
				  FROM [MNCHCentral].[dbo].[AncVisits] (NoLock) P
					inner join (select tn.PatientPK,tn.SiteCode,tn.VisitDate,Max(ID) As MaxID,max(cast(tn.DateExtracted as date))MaxDateExtracted 
									FROM [MNCHCentral].[dbo].[AncVisits] (NoLock)tn
									group by tn.PatientPK,tn.SiteCode,tn.VisitDate
								)tm
					on P.PatientPk = tm.PatientPk and p.SiteCode = tm.SiteCode
					and p.VisitDate = tm.VisitDate  and cast(p.DateExtracted as date) = tm.MaxDateExtracted
					and p.ID = tm.MaxID
					INNER JOIN [MNCHCentral].[dbo].[Facilities](NoLock) F ON P.[FacilityId] = F.Id ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.VisitID = b.VisitID
						and a.VisitDate = b.VisitDate  
						and a.RecordUUID = b.RecordUUID

						)
					WHEN NOT MATCHED THEN 
						INSERT(PatientMnchID,ANCClinicNumber,PatientPk,SiteCode,FacilityName,EMR,Project,VisitID,VisitDate,ANCVisitNo,GestationWeeks,Height,[Weight],Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,AntenatalExercises,FGM,FGMComplications,Haemoglobin,DiabetesTest,TBScreening,CACxScreen,CACxScreenMethod,WHOStaging,VLSampleTaken,VLDate,VLResult,SyphilisTreatment,HIVStatusBeforeANC,HIVTestingDone,HIVTestType,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,SyphilisTestDone,SyphilisTestType,SyphilisTestResults,SyphilisTreated,MotherProphylaxisGiven,MotherGivenHAART,AZTBabyDispense,NVPBabyDispense,ChronicIllness,CounselledOn,PartnerHIVTestingANC,PartnerHIVStatusANC,PostParturmFP,Deworming,MalariaProphylaxis,TetanusDose,IronSupplementsGiven,ReceivedMosquitoNet,PreventiveServices,UrinalysisVariables,ReferredFrom,ReferredTo,ReferralReasons,NextAppointmentANC,ClinicalNotes,Date_Last_Modified,LoadDate,RecordUUID) 
						VALUES(PatientMnchID,ANCClinicNumber,PatientPk,SiteCode,FacilityName,EMR,Project,VisitID,VisitDate,ANCVisitNo,GestationWeeks,Height,[Weight],Temp,PulseRate,RespiratoryRate,OxygenSaturation,MUAC,BP,BreastExam,AntenatalExercises,FGM,FGMComplications,Haemoglobin,DiabetesTest,TBScreening,CACxScreen,CACxScreenMethod,WHOStaging,VLSampleTaken,VLDate,VLResult,SyphilisTreatment,HIVStatusBeforeANC,HIVTestingDone,HIVTestType,HIVTest1,HIVTest1Result,HIVTest2,HIVTest2Result,HIVTestFinalResult,SyphilisTestDone,SyphilisTestType,SyphilisTestResults,SyphilisTreated,MotherProphylaxisGiven,MotherGivenHAART,AZTBabyDispense,NVPBabyDispense,ChronicIllness,CounselledOn,PartnerHIVTestingANC,PartnerHIVStatusANC,PostParturmFP,Deworming,MalariaProphylaxis,TetanusDose,IronSupplementsGiven,ReceivedMosquitoNet,PreventiveServices,UrinalysisVariables,ReferredFrom,ReferredTo,ReferralReasons,NextAppointmentANC,ClinicalNotes,Date_Last_Modified,Getdate(),RecordUUID)
																																																																																	
					WHEN MATCHED THEN
						UPDATE SET 
							a.SyphilisTreatment	 =b.SyphilisTreatment,
							a.Height = b.Height,
							a.[Weight] = b.[Weight],
							a.Temp = b.Temp,
							a.PulseRate = b.PulseRate,
							a.RespiratoryRate = b.RespiratoryRate,
							a.OxygenSaturation = b.OxygenSaturation,
							a.MUAC = b.MUAC,
							a.BP = b.BP,
							a.BreastExam = b.BreastExam,
							a.AntenatalExercises = b.AntenatalExercises,
							a.FGM = b.FGM,
							a.FGMComplications = b.FGMComplications,
							a.Haemoglobin = b.Haemoglobin,
							a.DiabetesTest = b.DiabetesTest,
							a.TBScreening = b.TBScreening,
							a.CACxScreen = b.CACxScreen,
							a.CACxScreenMethod = b.CACxScreenMethod,
							a.WHOStaging = b.WHOStaging,
							a.VLSampleTaken = b.VLSampleTaken,
							a.VLDate = b.VLDate,
							a.VLResult = b.VLResult,
							a.HIVStatusBeforeANC = b.HIVStatusBeforeANC,
							a.HIVTestingDone = b.HIVTestingDone,
							a.HIVTestType = b.HIVTestType,
							a.HIVTest1 = b.HIVTest1,
							a.HIVTest1Result = b.HIVTest1Result,
							a.HIVTest2 = b.HIVTest2,
							a.HIVTest2Result = b.HIVTest2Result,
							a.HIVTestFinalResult = b.HIVTestFinalResult,
							a.SyphilisTestDone = b.SyphilisTestDone,
							a.SyphilisTestType = b.SyphilisTestType,
							a.SyphilisTestResults = b.SyphilisTestResults,
							a.SyphilisTreated = b.SyphilisTreated,
							a.MotherProphylaxisGiven = b.MotherProphylaxisGiven,
							a.MotherGivenHAART = b.MotherGivenHAART,
							a.AZTBabyDispense = b.AZTBabyDispense,
							a.NVPBabyDispense = b.NVPBabyDispense,
							a.ChronicIllness = b.ChronicIllness,
							a.CounselledOn = b.CounselledOn,
							a.PartnerHIVTestingANC = b.PartnerHIVTestingANC,
							a.PartnerHIVStatusANC = b.PartnerHIVStatusANC,
							a.PostParturmFP = b.PostParturmFP,
							a.Deworming = b.Deworming,
							a.MalariaProphylaxis = b.MalariaProphylaxis,
							a.TetanusDose =b.TetanusDose,
							a.IronSupplementsGiven = b.IronSupplementsGiven,
							a.ReceivedMosquitoNet = b.ReceivedMosquitoNet,
							a.PreventiveServices = b.PreventiveServices,
							a.UrinalysisVariables = b.UrinalysisVariables,
							a.ReferredFrom = b.ReferredFrom,
							a.ReferredTo = b.ReferredTo,
							a.ReferralReasons = b.ReferralReasons,
							a.NextAppointmentANC = b.NextAppointmentANC,
							a.ClinicalNotes  = b.ClinicalNotes,
							a.RecordUUID = b.RecordUUID;


					with cte AS (
						Select
						Sitecode,
						PatientPK,
						VisitID,
						VisitDate,

						 ROW_NUMBER() OVER (PARTITION BY PatientPK,Sitecode,VisitID,VisitDate ORDER BY
						PatientPK,Sitecode,VisitDate) Row_Num
						FROM  [ODS].[dbo].[MNCH_AncVisits](NoLock)
						)
						delete from cte 
						Where Row_Num >1 ;


END



