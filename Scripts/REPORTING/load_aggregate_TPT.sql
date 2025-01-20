IF OBJECT_ID(N'REPORTING.[dbo].[AggregateTPT]', N'U') IS NOT NULL 
DROP TABLE REPORTING.[dbo].[AggregateTPT]
GO

WITH Source_TPT AS (
    SELECT distinct 
        MFLCode,
        FacilityName,
        tpt.PatientKey,
        County,
        SubCounty,
        PartnerName,
        AgencyName,
        Gender,
        DATIMAgeGroup,
		StartTBTreatmentDate.Year as StartTBTreatmentYear,
		StartTBTreatmentDate.Month as StartTBTreatmentMonth,
		TBDiagnosisDate.Year as TBDiagnosisYear,
		TBDiagnosisDate.Month as TBDiagnosisMonth,
        EOMONTH(TBDiagnosisDate.Date) as AsOfDate,            
		OnIPT,
		hasTB     
    FROM NDWH.Fact.FactTPT tpt
    LEFT join NDWH.Dim.DimFacility f on f.FacilityKey = tpt.FacilityKey
    LEFT JOIN NDWH.Dim.DimAgency a on a.AgencyKey = tpt.AgencyKey
    LEFT JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = tpt.PatientKey
    LEFT join NDWH.Dim.DimAgeGroup age on age.AgeGroupKey=tpt.AgeGroupKey
    LEFT JOIN NDWH.Dim.DimPartner p on p.PartnerKey = tpt.PartnerKey   
    LEFT JOIN NDWH.Dim.DimDate StartTBTreatmentDate on StartTBTreatmentDate.DateKey = tpt.StartTBTreatmentDateKey
	LEFT JOIN NDWH.Dim.DimDate TBDiagnosisDate on TBDiagnosisDate.DateKey = tpt.TBDiagnosisDateKey    
)
SELECT 
    MFLCode,
    FacilityName,
    County,
    SubCounty,
    PartnerName,
    AgencyName,
    Gender,
    DATIMAgeGroup as AgeGroup,
    StartTBTreatmentYear,
    StartTBTreatmentMonth,
    TBDiagnosisYear,
	TBDiagnosisMonth,
    AsOfDate,
	SUM(CASE WHEN OnIPT = 'Yes' THEN 1 ELSE 0 END) AS OnIPT,    
    Sum(hasTB) hasTB
INTO REPORTING.dbo.AggregateTPT   
FROM Source_TPT
GROUP BY 
    MFLCode, 
    FacilityName, 
    County,
    SubCounty, 
    PartnerName, 
    AgencyName, 
    Gender, 
    DATIMAgeGroup,   
    StartTBTreatmentYear,
    StartTBTreatmentMonth,
    AsOfDate,
    TBDiagnosisYear,
	TBDiagnosisMonth