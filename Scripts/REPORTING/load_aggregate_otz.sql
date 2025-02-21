IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateOTZ]', N'U') IS NOT NULL 
	DROP TABLE [REPORTING].[dbo].[AggregateOTZ]
GO

SELECT DISTINCT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	Gender,
	age.DATIMAgeGroup as AgeGroup,
	CONVERT(char(7), cast(cast(OTZEnrollmentDateKey as char) as datetime), 23) as OTZEnrollmentYearMonth,
    EOMONTH(date.Date) as AsofDate,
	count(*) as Enrolled,
	sum(case when otz.ModulesPreviouslyCovered is not null then 1 else 0 end) as CompletedTraining,
	TransferInStatus,
	ModulesPreviouslyCovered,
	SUM(ModulesCompletedToday_OTZ_Orientation) as CompletedToday_OTZ_Orientation,
	SUM(ModulesCompletedToday_OTZ_Participation) as CompletedToday_OTZ_Participation,
	SUM(ModulesCompletedToday_OTZ_Leadership) as CompletedToday_OTZ_Leadership,
	SUM(ModulesCompletedToday_OTZ_MakingDecisions) as CompletedToday_OTZ_MakingDecisions,
	SUM(ModulesCompletedToday_OTZ_Transition) as CompletedToday_OTZ_Transition,
	SUM(ModulesCompletedToday_OTZ_TreatmentLiteracy) as CompletedToday_OTZ_TreatmentLiteracy,
	SUM(ModulesCompletedToday_OTZ_SRH) as CompletedToday_OTZ_SRH,
	SUM(ModulesCompletedToday_OTZ_Beyond) as CompletedToday_OTZ_Beyond,
	FirstVL,
	LastVL,
	SUM(vl.EligibleVL) as EligibleVL,
	ValidVLResult,
	vl.ValidVLResultCategory2 as ValidVLResultCategory,
	SUM(vl.HasValidVL) as HasValidVL,
	Count(*) TotalOTZ,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO [REPORTING].[dbo].[AggregateOTZ]
FROM NDWH.Fact.FactOTZ otz
INNER join NDWH.Dim.DimAgeGroup age on age.AgeGroupKey=otz.AgeGroupKey
INNER join NDWH.Dim.DimFacility f on f.FacilityKey = otz.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = otz.AgencyKey
INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = otz.PatientKey
INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = otz.PartnerKey
LEFT JOIN NDWH.Fact.FactViralLoads vl on vl.PatientKey = otz.PatientKey and vl.PatientKey IS NOT NULL
LEFT JOIN NDWH.Dim.DimDate as date on date.DateKey = otz.OTZEnrollmentDateKey
WHERE age.Age BETWEEN 10 AND 19 AND IsTXCurr = 1
GROUP BY 
	MFLCode, 
	f.FacilityName, 
	County, 
	SubCounty, 
	p.PartnerName,
	a.AgencyName, 
	Gender, 
	age.DATIMAgeGroup, 
	CONVERT(char(7), cast(cast(OTZEnrollmentDateKey as char) as datetime), 23), 
	EOMONTH(date.Date),
	TransferInStatus, 
	ModulesPreviouslyCovered, 
	vl.FirstVL, 
	vl.LastVL, 
	vl.ValidVLResult,
	vl.ValidVLResultCategory2
