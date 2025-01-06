IF EXISTS(SELECT * FROM REPORTING.sys.objects WHERE object_id = OBJECT_ID(N'REPORTING.[dbo].[AggregatePrepDiscontinuation]') AND type in (N'U')) 
    DROP TABLE REPORTING.[dbo].[AggregatePrepDiscontinuation]
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
    d.Month AS ExitMonth,		
    d.Year AS ExitYear,
    EOMONTH(d.[Date]) as AsOfDate,
    ExitReason,
    COUNT(DISTINCT CONCAT(PrepNumber, PatientPKHash, MFLCode)) AS PrepDiscontinuations,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO REPORTING.dbo.AggregatePrepDiscontinuation
FROM NDWH.Fact.FactPrepDiscontinuation prep
LEFT JOIN NDWH.Dim.DimFacility f ON f.FacilityKey = prep.FacilityKey
LEFT JOIN NDWH.Dim.DimAgency a ON a.AgencyKey = prep.AgencyKey
LEFT JOIN NDWH.Dim.DimPatient pat ON pat.PatientKey = prep.PatientKey
LEFT JOIN NDWH.Dim.DimAgeGroup age ON age.AgeGroupKey = prep.AgeGroupKey
LEFT JOIN NDWH.Dim.DimPartner p ON p.PartnerKey = prep.PartnerKey
LEFT JOIN NDWH.Dim.DimDate d ON d.DateKey = prep.ExitdateKey
GROUP BY 
    MFLCode,
    f.FacilityName,
    County,
    SubCounty,
    p.PartnerName,
    a.AgencyName,
    Gender,
    age.DATIMAgeGroup,		
    d.Month,
    d.Year,
    EOMONTH(d.[Date]),
    ExitReason;
