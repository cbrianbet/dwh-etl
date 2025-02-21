IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateDSDStable]', N'U') IS NOT NULL 
	drop TABLE [REPORTING].[dbo].[AggregateDSDStable]
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
    DifferentiatedCare, 
    COUNT(DifferentiatedCare) as MMDModels,
    Sum(pat.isTXCurr) As TXCurr,
    cast(getdate() as date) as LoadDate
INTO REPORTING.dbo.AggregateDSDStable 
FROM NDWH.Fact.FactART as art
LEFT JOIN NDWH.Fact.FactLatestObs as lob on lob.Patientkey = art.PatientKey
LEFT JOIN NDWH.Dim.DimAgeGroup age on age.AgeGroupKey = lob.AgeGroupKey
LEFT JOIN NDWH.Dim.DimFacility f on f.FacilityKey = lob.FacilityKey
LEFT JOIN NDWH.Dim.DimAgency a on a.AgencyKey = lob.AgencyKey
LEFT JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = lob.PatientKey
LEFT JOIN NDWH.Dim.DimPartner p on p.PartnerKey = lob.PartnerKey
WHERE pat.isTXCurr = 1 and StabilityAssessment = 'Stable'
GROUP BY 
    MFLCode, 
    f.FacilityName,
    County, 
    SubCounty, 
    p.PartnerName,
    a.AgencyName, 
    Gender, 
    age.DATIMAgeGroup,
    DifferentiatedCare
    
GO
