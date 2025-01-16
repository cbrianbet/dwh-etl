IF OBJECT_ID(N'[REPORTING].[dbo].[CSAggregateHTSRiskScoresLastThreeMonths]', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].[CSAggregateHTSRiskScoresLastThreeMonths]
GO

BEGIN

-- Calculate the end of the last completed month
DECLARE @EndOfLastCompletedMonth DATE = EOMONTH(GETDATE(), -1);

-- Calculate the start date three months before the end of the last completed month
DECLARE @StartDate DATE = DATEADD(DAY, 1, EOMONTH(GETDATE(), -4));

with source_data as (
	select 
		row_number() over (partition by tests.FacilityKey, tests.PatientKey, tests.TestType order by tests.DateTestedKey desc) as num,
		patient.PatientKey,
		agegroup.DATIMAgeGroup,
		patient.Gender,
		facility.FacilityName,
		facility.County,
		facility.SubCounty,
		facility.MFLCode,
		partner.PartnerName,
		agency.AgencyName,
		facility.latitude,
		facility.longitude,
		elig.VisitDateKey,
		elig.HIVRiskCategory,
		elig.HtsRiskScore
	from NDWH.Fact.FactHTSClientTests as tests
	left join NDWH.Fact.FactHTSEligibilityExtract elig on elig.PatientKey = tests.PatientKey
		and elig.VisitDateKey = tests.DateTestedKey
	left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = tests.FacilityKey
	left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = tests.AgencyKey
	left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = tests.PartnerKey
	left join NDWH.Dim.DimPatient as patient on patient.PatientKey = tests.PatientKey
	left join NDWH.Dim.DimDate as testDate on testDate.DateKey =tests.DateTestedKey
	left join NDWH.Dim.DimAgeGroup as agegroup on agegroup.AgeGroupKey = tests.AgeGroupKey
	where testDate.Date >= @StartDate
        and testDate.Date <= @EndOfLastCompletedMonth and TestType ='Initial Test'
)
select 
	FacilityName,
	MFLCode,
	DATIMAgeGroup,
    Gender,
	Latitude,
	Longitude,
	SubCounty, 
	County,
	HIVRiskCategory as LatestHIVRiskCategory,
	count(distinct PatientKey) as CountOfClients,
	sum(count(distinct PatientKey)) over(partition by MFLCode) as TotalClientsInFacility,
    sum(count(distinct PatientKey)) over(partition by SubCounty) as TotalClientsInSubCounty,
	sum(count(distinct PatientKey)) over(partition by County) as TotalClientsInCounty
into HIVCaseSurveillance.dbo.CSAggregateHTSRiskScoresLastThreeMonths
from source_data
where num = 1 and (HIVRiskCategory is not null and HIVRiskCategory <> '')
group by 
	FacilityName,
	MFLCode,
    Gender,
	DATIMAgeGroup,
	Latitude,
	Longitude,
	SubCounty, 
	County,
	HIVRiskCategory
order by County

END