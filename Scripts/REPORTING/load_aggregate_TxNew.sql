IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateTxNew]', N'U') IS NOT NULL 	
	DROP TABLE [REPORTING].[dbo].[AggregateTxNew]
GO


SELECT DISTINCT

    MFLCode,
    f.FacilityName,
    County,
    SubCounty,
    p.PartnerName,
    a.AgencyName,
    pat.Gender,
    age.DATIMAgeGroup as AgeGroup,
    CONVERT(char(7), cast(StartARTDateKey as datetime), 23) as StartARTYearMonth,
    EOMONTH(date.date) as AsofDate,
    COUNT(CONCAT(it.PatientKey,'-',it.FacilityKey)) as patients_startedART,
    cast(getdate() as date) as LoadDate
INTO REPORTING.dbo.AggregateTxNew 
FROM NDWH.Fact.FactART it
INNER join NDWH.Dim.DimAgeGroup age on age.Age=it.AgeAtARTStart
INNER join NDWH.Dim.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.Dim.DimDate as date on date.DateKey = it.StartARTDateKey
GROUP BY 
    MFLCode, 
    f.FacilityName, 
    County, 
    SubCounty, 
    p.PartnerName, 
    a.AgencyName, 
    Gender, 
    age.DATIMAgeGroup, 
    CONVERT(char(7), cast(StartARTDateKey as datetime), 23),
    EOMONTH(date.date)

