IF OBJECT_ID(N'[REPORTING].[dbo].[LinelistHTSEligibilty]', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].[LinelistHTSEligibilty];


SELECT
	MFLCode,
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
    pat.PatientPKHash,
    pat.NUPI,
	pat.Gender,
	age_group.Age,
	age_group.DATIMAgeGroup AgeGroup,
	visit.Date VisitDate,
	HTSStrategy,
	HTSEntryPoint,
	PartnerHivStatus,
	UnknownStatusPartner,
	KnownStatusPartner,
	ExperiencedGBV,
	TypeGBV,
	EverOnPrep,
	CurrentlyOnPrep,
	TBStatus,
	HIVRiskCategory,
	EligibleForTest,
	ReasonsForIneligibility,
	ReferredForTesting,
	ReasonRefferredForTesting
	ReasonNotReffered
INTO LinelistHTSEligibilty
FROM NDWH.Fact.FactHTSEligibilityextract ex
LEFT join NDWH.Dim.DimFacility f on f.FacilityKey = ex.FacilityKey
LEFT JOIN NDWH.Dim.DimAgency a on a.AgencyKey = ex.AgencyKey
LEFT JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = ex.PatientKey
LEFT JOIN NDWH.Dim.DimPartner p on p.PartnerKey = ex.PartnerKey
LEFT JOIN NDWH.Dim.DimDate visit on visit.DateKey = ex.VisitDateKey
LEFT JOIN NDWH.Dim.DimAgeGroup as age_group on age_group.AgeGroupKey = DATEDIFF(YY,pat.DOB,visit.Date)
