IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateTimeToVL12M]', N'U') IS NOT NULL 	
	drop  TABLE [REPORTING].[dbo].[AggregateTimeToVL12M]
GO

SELECT DISTINCT
    MFLCode,
    f.FacilityName,
    SubCounty,
    County,
    p.PartnerName,
    a.AgencyName,
    EOMONTH(date.Date) as AsOfDate,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY p.PartnerName) AS MedianTimeToFirstVL_Partner,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY County) AS MedianTimeToFirstVL_County,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY Subcounty) AS MedianTimeToFirstVL_SbCty,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY a.AgencyName) AS MedianTimeToFirstVL_CTAgency,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Floor(it.TimetoFirstVL/30.25) DESC)
            OVER (PARTITION BY EOMONTH(date.Date)) AS MedianTimeToFirstVL_AsOfDate,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO [REPORTING].dbo.AggregateTimeToVL12M
FROM NDWH.Fact.FactViralLoads it
INNER join NDWH.Dim.DimAgeGroup g on g.AgeGroupKey=it.AgeGroupKey
INNER join NDWH.Dim.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.Fact.FactART art on art.PatientKey = it.PatientKey
INNER JOIN NDWH.Dim.DimDate as date on date.DateKey = art.StartARTDateKey
WHERE DateDIFF(MONTH,StartARTDateKey,GETDATE()) <=12 AND TimetoFirstVL IS NOT NULL
ORDER BY county desc