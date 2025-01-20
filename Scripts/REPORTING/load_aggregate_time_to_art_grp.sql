IF OBJECT_ID(N'[REPORTING].[dbo].AggregateTimeToARTGrp', N'U') IS NOT NULL 	
	Drop TABLE [REPORTING].[dbo].AggregateTimeToARTGrp
GO

select 
    MFLCode,
    f.FacilityName,
    County,
    Subcounty,
    p.PartnerName,
    a.AgencyName,
    Gender,
    g.DATIMAgeGroup as AgeGroup,
    Year(StartARTDateKey) StartARTYear,
    DateName(Month,StartARTDateKey) StartARTMonth,
    EOMONTH(date.Date) as AsofDate,
    convert(varchar(7),StartARTDateKey,126) as StartARTYearMonth,
    CASE WHEN [TimetoARTDiagnosis]=0 THEN 'Same Day'
        WHEN [TimetoARTDiagnosis] between 1 and 7 THEN '1 to 7 Days'
        WHEN [TimetoARTDiagnosis] between 8 and 14 THEN '8 to 14 Days'
        WHEN [TimetoARTDiagnosis]>14 and TimetoARTDiagnosis is not NULL THEN '> 14 Days'
        ELSE NULL END AS TimeToARTDiagnosis_Grp,
    Count(*) as NumPatients,
    SUM(Count(*)) OVER (PARTITION BY MFLCode,Year(StartARTDateKey),DateName(Month,StartARTDateKey)) AS TotalBySite,
    cast((cast(Count(*) as decimal (9,2))/
        SUM(Count(*)) OVER (PARTITION BY MFLCode,Year(StartARTDateKey),DateName(Month,StartARTDateKey))*100) 
    as decimal(8,2))  AS proportions,
     CAST(GETDATE() AS DATE) AS LoadDate 
INTO [REPORTING].[dbo].[AggregateTimeToARTGrp]
from NDWH.Fact.FactART it
INNER join NDWH.Dim.DimAgeGroup g on g.Age=it.AgeAtEnrol
INNER join NDWH.Dim.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = it.PatientKey
LEFT JOIN NDWH.Dim.DimDate as date on date.DateKey = it.StartARTDateKey
where MFLCode > 1
Group BY 
    MFLCode,
    f.FacilityName,
    County,
    Subcounty,
    p.PartnerName,
    a.AgencyName,
    Gender,
    g.DATIMAgeGroup,
    Year(StartARTDateKey),
    DateName(Month,StartARTDateKey), 
    convert(varchar(7),StartARTDateKey,126), 
    EOMONTH(date.Date),
    TimetoARTDiagnosis
order by 
    MFLCode,Year(StartARTDateKey)