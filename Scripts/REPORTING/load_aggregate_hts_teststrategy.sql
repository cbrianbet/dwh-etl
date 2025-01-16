IF OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSTeststrategy]', N'U') IS NOT NULL 
	drop TABLE REPORTING.[dbo].[AggregateHTSTeststrategy];
GO

SELECT
    MFLCode,
    f.FacilityName,
    County,
    SubCounty,
    p.PartnerName,
    a.AgencyName,
    Gender,
    age.DATIMAgeGroup as AgeGroup, 
    TestStrategy,
    d.year,
    d.month,
    FORMAT(cast(date as date), 'MMMM') MonthName,
    EOMONTH(d.date) as AsOfDate,
    Sum(Tested) as TestedClients,
    Sum(Positive) as PositiveClients,
    Sum(Linked) as LinkedClients,
     CAST(GETDATE() AS DATE) AS LoadDate 
INTO REPORTING.dbo.AggregateHTSTeststrategy
FROM NDWH.Fact.FactHTSClientTests hts
LEFT JOIN NDWH.Dim.DimFacility f on f.FacilityKey = hts.FacilityKey
LEFT JOIN NDWH.Dim.DimAgency a on a.AgencyKey = hts.AgencyKey
LEFT JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = hts.PatientKey
LEFT JOIN NDWH.Dim.DimAgeGroup age on age.AgeGroupKey=hts.AgeGroupKey
LEFT JOIN NDWH.Dim.DimPartner p on p.PartnerKey = hts.PartnerKey
LEFT JOIN NDWH.Fact.FactHTSClientLinkages link on link.PatientKey = hts.PatientKey
LEFT JOIN NDWH.Dim.DimDate d on d.DateKey = hts.DateTestedKey
WHERE TestType in ('Initial Test', 'Initial')
GROUP BY 
    MFLCode, 
    f.FacilityName, 
    County, 
    SubCounty, 
    p.PartnerName, 
    a.AgencyName, 
    Gender, age.DATIMAgeGroup, 
    TestStrategy, 
    year, 
    month, 
    FORMAT(cast(date as date), 'MMMM'),
    EOMONTH(d.date)