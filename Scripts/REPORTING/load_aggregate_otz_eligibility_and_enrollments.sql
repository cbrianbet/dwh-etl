IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateOTZEligibilityAndEnrollments]', N'U')IS NOT NULL 	
	DROP TABLE [REPORTING].[dbo].[AggregateOTZEligibilityAndEnrollments]
GO
SELECT DISTINCT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	Gender,
	age.DATIMAgeGroup AS AgeGroup,
	CONVERT (CHAR (7), CAST (CAST (OTZEnrollmentDateKey AS CHAR)AS datetime), 23)AS OTZEnrollmentYearMonth,
	SUM (CASE WHEN otz.ModulesPreviouslyCovered IS NOT NULL THEN 1 ELSE 0 END)AS CompletedTraining,
	TransferInStatus,
	ModulesPreviouslyCovered,
	SUM (ModulesCompletedToday_OTZ_Orientation) AS CompletedToday_OTZ_Orientation,
	SUM (ModulesCompletedToday_OTZ_Participation) AS CompletedToday_OTZ_Participation,
	SUM (ModulesCompletedToday_OTZ_Leadership)AS CompletedToday_OTZ_Leadership,
	SUM (ModulesCompletedToday_OTZ_MakingDecisions) AS CompletedToday_OTZ_MakingDecisions,
	SUM (ModulesCompletedToday_OTZ_Transition) AS CompletedToday_OTZ_Transition,
	SUM (ModulesCompletedToday_OTZ_TreatmentLiteracy) AS CompletedToday_OTZ_TreatmentLiteracy,
	SUM (ModulesCompletedToday_OTZ_SRH) AS CompletedToday_OTZ_SRH,
	SUM (ModulesCompletedToday_OTZ_Beyond) AS CompletedToday_OTZ_Beyond,
	FirstVL,
	LastVL,
	ValidVLResult,
	vl.ValidVLResultCategory2 as ValidVLResultCategory,
	EOMONTH(date.Date)as AsofDate,
	SUM (vl.EligibleVL)AS EligibleVL,
	SUM (vl.HasValidVL)AS HasValidVL,
	COUNT (*)patients_eligible,
	COUNT(otz.PatientKey)as Enrolled,
	CAST(GETDATE()AS DATE)AS LoadDate
INTO [REPORTING].[dbo].[AggregateOTZEligibilityAndEnrollments]
FROM NDWH.Fact.FACTART art
INNER JOIN NDWH.Dim.DimAgeGroup age ON age.AgeGroupKey= art.AgeGroupKey
INNER JOIN NDWH.Dim.DimFacility f ON f.FacilityKey = art.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a ON a.AgencyKey = art.AgencyKey
INNER JOIN NDWH.Dim.DimPatient pat ON pat.PatientKey = art.PatientKey
INNER JOIN NDWH.Dim.DimPartner p ON p.PartnerKey = art.PartnerKey
LEFT JOIN NDWH.Fact.FactViralLoads vl ON vl.PatientKey = art.PatientKey AND vl.PatientKey IS NOT NULL 
FULL OUTER JOIN NDWH.Fact.FactOTZ otz on otz.PatientKey = art.PatientKey
LEFT JOIN NDWH.Dim.DimDate as date on date.DateKey = otz.OTZEnrollmentDateKey
WHERE age.Age BETWEEN 10 AND 19 AND IsTXCurr = 1 
GROUP BY 
	MFLCode,
	f.FacilityName,
	County,SubCounty,
	p.PartnerName,
	a.AgencyName,
	Gender,
	age.DATIMAgeGroup,
	CONVERT (CHAR (7), CAST (CAST(OTZEnrollmentDateKey AS CHAR)AS datetime), 23),
	TransferInStatus,
	ModulesPreviouslyCovered,
	vl.FirstVL,
	vl.LastVL,
	vl.ValidVLResult,
	ValidVLResultCategory2,
	EOMONTH(date.Date)

GO