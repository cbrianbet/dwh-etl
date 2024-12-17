
 IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateTimeToART]', N'U') IS NOT NULL 	
	drop  TABLE [REPORTING].[dbo].[AggregateTimeToART]
GO
                    
SELECT DISTINCT
    MFLCode,
    f.FacilityName,
    SubCounty,
    County,
    p.PartnerName,
    a.AgencyName,
    Gender,
    g.DATIMAgeGroup as AgeGroup,
    year(StartARTDateKey) as StartARTYear,
    convert(varchar(7),StartARTDateKey,126) as StartARTYearMonth,
    EOMONTH(date.Date) as AsOfDate,
    PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
            OVER (PARTITION BY Year(StartARTDateKey)) AS MedianTimeToARTDiagnosis_year,
    PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
            OVER (PARTITION BY Year(StartARTDateKey),p.PartnerName) AS MedianTimeToARTDiagnosis_yearPartner,
    PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
            OVER (PARTITION BY Year(StartARTDateKey),County) AS MedianTimeToARTDiagnosis_yearCounty,
    PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
            OVER (PARTITION BY Year(StartARTDateKey),Subcounty) AS MedianTimeToARTDiagnosis_yearSbCty,
    PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
            OVER (PARTITION BY Year(StartARTDateKey),FacilityName) AS MedianTimeToARTDiagnosis_yearFacility,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
            OVER (PARTITION BY Year(StartARTDateKey), County,p.PartnerName) AS MedianTimeToARTDiagnosis_YearCountyPartner,	
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
            OVER (PARTITION BY Year(StartARTDateKey), a.AgencyName) AS MedianTimeToARTDiagnosis_yearCTAgency,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
            OVER (PARTITION BY Gender) AS MedianTimeToART_Gender,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
            OVER (PARTITION BY g.DATIMAgeGroup) AS MedianTimeToART_DATIM_AgeGroup,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY it.TimeToARTDiagnosis DESC)
            OVER (PARTITION BY EOMONTH(date.Date)) AS MedianTimeToART_AsOfDate,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO [REPORTING].[dbo].[AggregateTimeToART]
FROM NDWH.Fact.FactART it
INNER join NDWH.Dim.DimAgeGroup g on g.Age=it.AgeAtEnrol
INNER join NDWH.Dim.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.Dim.DimDate as date on date.DateKey = it.StartARTDateKey
WHERE MFLCode > 1 and Year(StartARTDateKey) between 2011 and Year(GetDate())