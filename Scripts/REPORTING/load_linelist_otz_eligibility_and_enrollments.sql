IF OBJECT_ID(N'[REPORTING].[dbo].[LineListOTZEligibilityAndEnrollments]', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].[LineListOTZEligibilityAndEnrollments]
GO
--- A linelist of ALHIV patients (Enrolled + Not Enrolled to OTZ)
SELECT DISTINCT
	patientPKHash,
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	art.Gender,
	age.DATIMAgeGroup as AgeGroup,
	otz.OTZEnrollmentDateKey,
	LastVisitDateKey,
	TransitionAttritionReason,
	TransferInStatus,
	case when otz.ModulesPreviouslyCovered is not null then 1 else 0 end as CompletedTraining,
	ModulesPreviouslyCovered,
	ModulesCompletedToday_OTZ_Orientation,
	ModulesCompletedToday_OTZ_Participation,
	ModulesCompletedToday_OTZ_Leadership,
	ModulesCompletedToday_OTZ_MakingDecisions,
	ModulesCompletedToday_OTZ_Transition,
	ModulesCompletedToday_OTZ_TreatmentLiteracy,
	ModulesCompletedToday_OTZ_SRH,
	ModulesCompletedToday_OTZ_Beyond,
	FirstVL,
	LastVL,
	vl.EligibleVL,
	ValidVLResult,
	vl.ValidVLResultCategory2 as ValidVLResultCategory,
	vl.HasValidVL as HasValidVL,
	COUNT(CASE
	WHEN art.PatientKey is not null THEN 1
	ELSE 0 END) as Eligible,
	COUNT(CASE WHEN otz.PatientKey is not null THEN 1 ELSE NULL END) as Enrolled,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO [REPORTING].[dbo].[LineListOTZEligibilityAndEnrollments]
FROM NDWH.dbo.FACTART art
INNER JOIN NDWH.dbo.DimAgeGroup age ON age.AgeGroupKey= art.AgeGroupKey
INNER JOIN NDWH.dbo.DimFacility f ON f.FacilityKey = art.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a ON a.AgencyKey = art.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat ON pat.PatientKey = art.PatientKey
INNER JOIN NDWH.dbo.DimPartner p ON p.PartnerKey = art.PartnerKey
LEFT JOIN NDWH.dbo.FactViralLoads vl ON vl.PatientKey = art.PatientKey AND vl.PatientKey IS NOT NULL 
FULL OUTER JOIN NDWH.dbo.FactOTZ otz on otz.PatientKey = art.PatientKey
WHERE age.Age BETWEEN 10 AND 24  AND IsTXCurr = 1
GROUP BY 
	patientPKHash, MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	art.Gender,
	age.DATIMAgeGroup,
	otz.OTZEnrollmentDateKey,
	LastVisitDateKey,
	TransitionAttritionReason,
	TransferInStatus,
	case when otz.ModulesPreviouslyCovered is not null then 1 else 0 end,
	ModulesPreviouslyCovered,
	ModulesCompletedToday_OTZ_Orientation,
	ModulesCompletedToday_OTZ_Participation,
	ModulesCompletedToday_OTZ_Leadership,
	ModulesCompletedToday_OTZ_MakingDecisions,
	ModulesCompletedToday_OTZ_Transition,
	ModulesCompletedToday_OTZ_TreatmentLiteracy,
	ModulesCompletedToday_OTZ_SRH,
	ModulesCompletedToday_OTZ_Beyond,
	FirstVL,
	LastVL,
	vl.EligibleVL,
	ValidVLResult,
	ValidVLResultCategory2,
	vl.HasValidVL
GO