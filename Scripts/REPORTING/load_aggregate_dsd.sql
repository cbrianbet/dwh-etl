IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateDSD]', N'U') IS NOT NULL 
	drop TABLE [REPORTING].[dbo].[AggregateDSD]
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
    StabilityAssessment,
	DifferentiatedCare,
    SUM(onMMD) as patients_onMMD,
    SUM(case when onMMD = 0 then 1 else 0 end) as patients_nonMMD,
    COUNT(StabilityAssessment) AS Stability,
    Sum(pat.isTXCurr) As TXCurr,
    cast(getdate() as date) as LoadDate
INTO [REPORTING].[dbo].[AggregateDSD]
FROM NDWH.Fact.FactART as art
LEFT JOIN NDWH.Fact.FactLatestObs as lob on lob.Patientkey = art.PatientKey
LEFT JOIN NDWH.Dim.DimAgeGroup age on age.AgeGroupKey = art.AgeGroupKey
LEFT JOIN NDWH.Dim.DimFacility f on f.FacilityKey = art.FacilityKey
LEFT JOIN NDWH.Dim.DimAgency a on a.AgencyKey = art.AgencyKey
LEFT JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = art.PatientKey
LEFT JOIN NDWH.Dim.DimPartner p on p.PartnerKey = art.PartnerKey
WHERE pat.IsTXCurr = 1
GROUP BY 
    MFLCode, 
    f.FacilityName, 
    County, 
    SubCounty, 
    p.PartnerName,
    a.AgencyName, 
    Gender, 
    age.DATIMAgeGroup, 
    StabilityAssessment,
    DifferentiatedCare

GO
