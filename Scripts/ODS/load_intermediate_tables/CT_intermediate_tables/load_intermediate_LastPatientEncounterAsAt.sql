IF OBJECT_ID(N'[ODS].[Intermediate].[Intermediate_LastPatientEncounterAsAt]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[Intermediate].[Intermediate_LastPatientEncounterAsAt];
BEGIN
	--Load_LastPatientEncounterAsAt
	With LastPatientEncounterAsAt AS ( 

	 SELECT 
		coalesce (LastVisit.PatientID,LastDispense.PatientID) AS PatientID,
		 coalesce(LastVisit.SiteCode,LastDispense.SiteCode) AS SiteCode,
		 coalesce(LastVisit.PatientPK,LastDispense.PatientPK) AS PatientPK ,
	
		 CASE
		 WHEN LastVisit.VisitDateAsAt > LastDispense.LastDispenseDate
			THEN LastVisit.VisitDateAsAt 
			END AS EncounterDateAsAt,
		CASE 
			WHEN LastVisit.[AppointmentDateAsAt]>LastDispense.ExpectedReturn
			THEN LastVisit.[AppointmentDateAsAt] ELSE coalesce(LastDispense.ExpectedReturn,LastVisit.AppointmentDateAsAt)  END AS AppointmentDateAsAt,
			cast(getdate() as date) as LoadDate, 
			cast( '' as nvarchar(100)) PatientPKHash,
			cast( '' as nvarchar(100)) PatientIDHash
	 FROM ODS.[Intermediate].Intermediate_LastVisitAsAt  LastVisit
	 FULL JOIN ODS.[Intermediate].Intermediate_PharmacyDispenseAsAtDate  LastDispense
	 ON   LastVisit.SiteCode=LastDispense.SiteCode AND LastVisit.PatientPK =LastDispense.PatientPK

	)
	 Select LastPatientEncounterAsAt.* 
	 INTO [ODS].[Intermediate].[Intermediate_LastPatientEncounterAsAt]
	 from LastPatientEncounterAsAt
END
