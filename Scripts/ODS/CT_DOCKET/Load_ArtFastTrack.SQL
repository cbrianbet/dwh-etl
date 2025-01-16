BEGIN ---- Refresh [ODS].[dbo].[CT_ArtFastTrack] 
MERGE [ODS].[Care].[CT_ArtFastTrack] AS a USING(
	SELECT  Distinct F.Code AS SiteCode
		,P.PatientPID AS PatientPK
		,P.PatientcccNumber AS PatientID
		,AFT.Emr
		,AFT.Project
		,AFT.Voided
		,AFT.Processed
		,AFT.Id
		,F.[Name] AS FacilityName
		,ARTRefillModel
		,VisitDate
		,CTXDispensed
		,DapsoneDispensed
		,CondomsDistributed
		,OralContraceptivesDispensed
		,MissedDoses
		,Fatigue
		,Cough
		,Fever
		,Rash
		,NauseaOrVomiting
		,GenitalSoreOrDischarge
		,Diarrhea
		,OtherSymptoms
		,PregnancyStatus
		,FPStatus
		,FPMethod
		,ReasonNotOnFP
		,ReferredToClinic
		,ReturnVisitDate
		,AFT.RecordUUID
		,AFT.Date_Created
		,AFT.Date_Last_Modified
		,AFT.Created
	FROM [DWAPICentral].[dbo].[PatientExtract] (NoLock) P
	INNER JOIN [DWAPICentral].[dbo].[ArtFastTrackExtract] (NoLock) AFT ON AFT.[PatientId] = P.ID
	INNER JOIN [DWAPICentral].[dbo].[Facility] (NoLock) F ON P.[FacilityId] = F.Id AND F.Voided = 0
	WHERE P.gender != 'Unknown'
) AS b ON( 
	a.SiteCode = b.SiteCode
	AND a.PatientPK = b.PatientPK
	AND a.ID = b.ID 
) WHEN NOT MATCHED THEN INSERT(SiteCode, PatientPK, Emr, Project, Voided, Id, FacilityName, ARTRefillModel, VisitDate, CTXDispensed, DapsoneDispensed, CondomsDistributed, OralContraceptivesDispensed, MissedDoses, Fatigue, Cough, Fever, Rash, NauseaOrVomiting, GenitalSoreOrDischarge, Diarrhea, OtherSymptoms, PregnancyStatus, FPStatus, FPMethod, ReasonNotOnFP, ReferredToClinic, ReturnVisitDate, RecordUUID, Date_Created, Date_Last_Modified, Created, PatientId, LoadDate) VALUES(SiteCode, PatientPK, Emr, Project, Voided, Id, FacilityName, ARTRefillModel, VisitDate, CTXDispensed, DapsoneDispensed, CondomsDistributed, OralContraceptivesDispensed, MissedDoses, Fatigue, Cough, Fever, Rash, NauseaOrVomiting, GenitalSoreOrDischarge, Diarrhea, OtherSymptoms, PregnancyStatus, FPStatus, FPMethod, ReasonNotOnFP, ReferredToClinic, ReturnVisitDate, RecordUUID, Date_Created, Date_Last_Modified, Created, PatientId, Getdate()) WHEN MATCHED THEN UPDATE

SET a.[Emr] = b.[Emr], a.[Project] = b.[Project], a.[Voided] = b.[Voided], a.[FacilityName] = b.[FacilityName], a.[ARTRefillModel] = b.[ARTRefillModel], a.[VisitDate] = b.[VisitDate], a.[CTXDispensed] = b.[CTXDispensed], a.[DapsoneDispensed] = b.[DapsoneDispensed], a.[CondomsDistributed] = b.[CondomsDistributed], a.[OralContraceptivesDispensed] = b.[OralContraceptivesDispensed], a.[MissedDoses] = b.[MissedDoses], a.[Fatigue] = b.[Fatigue], a.[Cough] = b.[Cough], a.[Fever] = b.[Fever], a.[Rash] = b.[Rash], a.[NauseaOrVomiting] = b.[NauseaOrVomiting], a.[GenitalSoreOrDischarge] = b.[GenitalSoreOrDischarge], a.[Diarrhea] = b.[Diarrhea], a.[OtherSymptoms] = b.[OtherSymptoms], a.[PregnancyStatus] = b.[PregnancyStatus], a.[FPStatus] = b.[FPStatus], a.[FPMethod] = b.[FPMethod], a.[ReasonNotOnFP] = b.[ReasonNotOnFP], a.[ReferredToClinic] = b.[ReferredToClinic], a.[ReturnVisitDate] = b.[ReturnVisitDate], a.[RecordUUID] = b.[RecordUUID], a.[Date_Created] = b.[Date_Created], a.[Date_Last_Modified] = b.[Date_Last_Modified], a.[Created] = b.[Created], a.[PatientId] = b.[PatientId]; END