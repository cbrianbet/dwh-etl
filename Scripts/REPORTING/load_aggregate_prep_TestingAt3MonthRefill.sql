IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregatePrepTestingAt3MonthRefill]') AND type in (N'U')) 
DROP TABLE REPORTING.[dbo].[AggregatePrepTestingAt3MonthRefill]
GO

SELECT DISTINCT 
	MFLCode,		
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	pat.Gender,
	test.Month,
	test.Year,
    EOMONTH(test.Date) as AsofDate,
	age.DATIMAgeGroup as AgeGroup,
	sum(case when DateDispenseMonth3 is not null then 1 else 0 end) refilled,
	sum(case when TestResultsMonth3 is not null then 1 else 0 end) tested,
	sum(case when TestResultsMonth3 is null then 1 else 0 end) nottested,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO REPORTING.dbo.AggregatePrepTestingAt3MonthRefill
FROM NDWH.Fact.FactPrepRefills prep
LEFT JOIN NDWH.Dim.DimFacility f on f.FacilityKey = prep.FacilityKey
LEFT JOIN NDWH.Dim.DimAgency a on a.AgencyKey = prep.AgencyKey
LEFT JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = prep.PatientKey
LEFT join NDWH.Dim.DimAgeGroup age on age.AgeGroupKey=prep.AgeGroupKey
LEFT JOIN NDWH.Dim.DimPartner p on p.PartnerKey = prep.PartnerKey
LEFT JOIN NDWH.Dim.DimDate test ON test.DateKey = DateDispenseMonth3 
GROUP BY  
    MFLCode,		
	f.FacilityName,
	County,
	SubCounty,
	p.PartnerName,
	a.AgencyName,
	pat.Gender,
	age.DATIMAgeGroup,
	test.Month,
	test.Year,
    EOMONTH(test.Date)