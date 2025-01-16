IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateTimeToVL]', N'U') IS NOT NULL 	
	drop TABLE [REPORTING].[dbo].[AggregateTimeToVL]
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
    year(StartARTDateKey) StartYr,
    EOMONTH(date.Date) as AsOfDate,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY Year(StartARTDateKey)) AS MedianTimeToFirstVL_year,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY Year(StartARTDateKey),p.PartnerName) AS MedianTimeToFirstVL_yearPartner,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY Year(StartARTDateKey),County) AS MedianTimeToFirstVL_yearCounty,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY Year(StartARTDateKey),Subcounty) AS MedianTimeToFirstVL_yearSbCty,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY Year(StartARTDateKey),f.FacilityName) AS MedianTimeToFirstVL_yearFacility,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY Year(StartARTDateKey), County, p.PartnerName) AS MedianTimeToFirstVL_yearCountyPartner,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY Year(StartARTDateKey), a.AgencyName) AS MedianTimeToFirstVL_yearCTAgency,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY Year(StartARTDateKey), Gender) AS MedianTimeToFirstVL_Gender,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY Year(StartARTDateKey), g.DATIMAgeGroup) AS MedianTimeToFirstVL_yearDATIM_AgeGroup,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
           OVER (PARTITION BY EOMONTH(date.Date)) AS MedianTimeToFirstVL_AsOffDate,        
    CAST(GETDATE() AS DATE) AS LoadDate   
        INTO [REPORTING].[dbo].[AggregateTimeToVL]
FROM NDWH.Fact.FactViralLoads it
INNER join NDWH.Dim.DimAgeGroup g on g.AgeGroupKey=it.AgeGroupKey
INNER join NDWH.Dim.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.Fact.FactART art on art.PatientKey = it.PatientKey
INNER JOIN NDWH.Dim.DimDate as date on date.DateKey = art.StartARTDateKey
WHERE StartARTDateKey between cast('2011-01-01' as date) AND DateADD(MONTH,-6,GETDATE()) AND TimetoFirstVL IS NOT NULL