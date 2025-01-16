IF OBJECT_ID(N'REPORTING.[dbo].[AggregateOTZOutcome]', N'U') IS NOT NULL 	
	drop  TABLE REPORTING.[dbo].[AggregateOTZOutcome]
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
    case when TransitionAttritionReason is null then 'Active' else TransitionAttritionReason end as Outcome,
    COUNT(case when TransitionAttritionReason is null then 1 else 1 end) as patients_totalOutcome,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO REPORTING.dbo.AggregateOTZOutcome
FROM NDWH.Fact.FactOTZ otz
INNER join NDWH.Dim.DimAgeGroup age on age.AgeGroupKey=otz.AgeGroupKey
INNER join NDWH.Dim.DimFacility f on f.FacilityKey = otz.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = otz.AgencyKey
INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = otz.PatientKey
INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = otz.PartnerKey
LEFT JOIN NDWH.Dim.DimDate as date on date.DateKey = otz.OTZEnrollmentDateKey
WHERE IsTXCurr = 1 AND age.Age BETWEEN 10 AND 19
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
    TransitionAttritionReason

