IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateTreatmentOutcomes]', N'U') IS NOT NULL 		
	DROP TABLE [REPORTING].[dbo].[AggregateTreatmentOutcomes]
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
	Year(StartARTDateKey) StartYear,
	Month(StartARTDateKey) StartMonth,
    EOMONTH(date.Date) AsOfDate,
	ARTOutcomeDescription,
	Count(ARTOutcomeDescription) TotalOutcomes,
    CAST(GETDATE() AS DATE) AS LoadDate 
INTO REPORTING.dbo.AggregateTreatmentOutcomes
FROM NDWH.Fact.FACTART art
INNER join NDWH.Dim.DimAgeGroup age on age.AgeGroupKey= art.AgeGroupKey
INNER join NDWH.Dim.DimFacility f on f.FacilityKey = art.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = art.AgencyKey
INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = art.PatientKey
INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = art.PartnerKey
INNER JOIN NDWH.Dim.DimARTOutcome ot on ot.ARTOutcomeKey = art.ARTOutcomeKey
INNER JOIN NDWH.Dim.DimDate as date on date.DateKey = art.StartARTDateKey
GROUP BY 
    MFLCode, 
    f.FacilityName,
    County,
    SubCounty, 
    p.PartnerName, 
    a.AgencyName, 
    pat.Gender, 
    age.DATIMAgeGroup, 
    Year(StartARTDateKey) ,
    Month(StartARTDateKey),
    EOMONTH(date.Date),
    ARTOutcomeDescription