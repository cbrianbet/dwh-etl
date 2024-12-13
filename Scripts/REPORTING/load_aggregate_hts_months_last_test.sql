IF OBJECT_ID(N'REPORTING.[dbo].[AggregateHTSMonthsLastTest]', N'U') IS NOT NULL 
	drop TABLE REPORTING.[dbo].[AggregateHTSMonthsLastTest]
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
    MonthsLastTest MonthLastTest,
    year,
    month,
    EOMONTH(cast(concat([year], '-', [month], '-01') as date)) as AsOfDate,
    FORMAT(cast(date as date), 'MMMM') MonthName,
    Sum(Tested) Tested,
    Sum(Positive) Positive,
    Sum(Linked) Linked,
    CAST(GETDATE() AS DATE) AS LoadDate
INTO REPORTING.dbo.AggregateHTSMonthsLastTest 
FROM NDWH.Fact.FactHTSClientTests hts
LEFT join NDWH.Dim.DimFacility f on f.FacilityKey = hts.FacilityKey
LEFT JOIN NDWH.Dim.DimAgency a on a.AgencyKey = hts.AgencyKey
LEFT JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = hts.PatientKey
LEFT join NDWH.Dim.DimAgeGroup age on age.AgeGroupKey=hts.AgeGroupKey
LEFT JOIN NDWH.Dim.DimPartner p on p.PartnerKey = hts.PartnerKey
LEFT JOIN NDWH.Fact.FactHTSClientLinkages link on link.PatientKey = hts.PatientKey
LEFT JOIN NDWH.Dim.DimDate d on d.DateKey = hts.DateTestedKey
where TestType in ('Initial test','Initial')
GROUP BY 
    MFLCode, 
    f.FacilityName,
    County, 
    SubCounty, 
    p.PartnerName, 
    a.AgencyName, 
    Gender, 
    age.DATIMAgeGroup, 
    MonthsLastTest, 
    year,
    month, 
    EOMONTH(cast(concat([year], '-', [month], '-01') as date)),
    FORMAT(cast(date as date), 'MMMM')