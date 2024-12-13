IF OBJECT_ID(N'[REPORTING].[dbo].[LineListOTZ]', N'U') IS NOT NULL 		
	DROP TABLE [REPORTING].[dbo].[LineListOTZ]
GO

SELECT 
    PatientIDHash,
	PatientPKHash,
    NUPI,
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	pat.Gender,
	age.DATIMAgeGroup as AgeGroup,
	otz.OTZEnrollmentDateKey,
	LastVisitDateKey,
    case 
	    when outcome.ARTOutcome is null then 'Others'
		else outcome.ARTOutcomeDescription 
	end as ARTOutcomeDescription,
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
	cast (art.StartARTDateKey as date) as startARTDate,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO [REPORTING].[dbo].[LineListOTZ]
FROM NDWH.Fact.FactOTZ otz
INNER join NDWH.Dim.DimAgeGroup age on age.AgeGroupKey=otz.AgeGroupKey
INNER join NDWH.Dim.DimFacility f on f.FacilityKey = otz.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = otz.AgencyKey
INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = otz.PatientKey
INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = otz.PartnerKey
LEFT JOIN NDWH.Fact.FactViralLoads vl on vl.PatientKey = otz.PatientKey and vl.PatientKey IS NOT NULL
LEFT JOIN NDWH.Fact.FACTART art on art.PatientKey = otz.PatientKey
LEFT JOIN NDWH.Dim.DimARTOutcome as outcome on outcome.ARTOutcomeKey = art.ARTOutcomeKey
WHERE age.Age BETWEEN 10 AND 19 AND IsTXCurr = 1

GO
