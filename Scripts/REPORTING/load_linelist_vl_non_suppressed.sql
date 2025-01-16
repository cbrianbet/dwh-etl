IF OBJECT_ID(N'[REPORTING].[dbo].[LineListVLNonSuppressed]', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].[LineListVLNonSuppressed]
GO

SELECT DISTINCT
	PatientIDHash,
    PatientPKHash,
    MFLCode,
	f.FacilityName,
	SubCounty,
	County,
	p.PartnerName,
	a.AgencyName,
	pat.Gender,
	g.DATIMAgeGroup as AgeGroup,
	art.AgeLastVisit,
	StartARTDateKey as StartARTDate,
	ValidVLResult,
	art.LastVisitDate,
	art.NextAppointmentDate,
	aro.ARTOutcome,
    CAST(GETDATE() AS DATE) AS LoadDate ,
	case 
		when aro.ARTOutcome is null then 'Others'
		else aro.ARTOutcomeDescription
	end as ARTOutcomeDescription
INTO [REPORTING].[dbo].[LineListVLNonSuppressed]
FROM NDWH.Fact.FactViralLoads it
INNER join NDWH.Dim.DimAgeGroup g on g.AgeGroupKey=it.AgeGroupKey
INNER join NDWH.Dim.DimFacility f on f.FacilityKey = it.FacilityKey
INNER JOIN NDWH.Dim.DimAgency a on a.AgencyKey = it.AgencyKey
INNER JOIN NDWH.Dim.DimPatient pat on pat.PatientKey = it.PatientKey
INNER JOIN NDWH.Dim.DimPartner p on p.PartnerKey = it.PartnerKey
INNER JOIN NDWH.Fact.FactART art on art.PatientKey = it.PatientKey
INNER JOIN NDWH.Dim.DimARTOutcome aro on aro.ARTOutcomeKey = art.ARTOutcomeKey
WHERE ValidVLResultCategory1 in ('>1000', '200-999')