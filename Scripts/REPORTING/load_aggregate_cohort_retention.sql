IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateCohortRetention]', N'U') IS NOT NULL 	
	Drop TABLE [REPORTING].[dbo].[AggregateCohortRetention]
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
    CONVERT(char(7), cast(StartARTDateKey as datetime), 23) as StartARTYearMonth,
    COUNT(CONCAT(it.PatientKey,'-',it.FacilityKey)) as patients_startedART,
    cast(getdate() as date) as LoadDate
INTO REPORTING.dbo.AggregateCohortRetention 
FROM NDWH.dbo.FactART it
INNER join NDWH.dbo.DimAgeGroup age on age.Age=it.AgeAtARTStart
INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
GROUP BY MFLCode, f.FacilityName, County, SubCounty, p.PartnerName, a.AgencyName, Gender, age.DATIMAgeGroup, CONVERT(char(7), cast(StartARTDateKey as datetime), 23)
