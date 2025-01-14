IF OBJECT_ID(N'[REPORTING].[dbo].[AggregateIITRiskScores]', N'U') IS NOT NULL 			
	DROP TABLE [REPORTING].[dbo].[AggregateIITRiskScores]
GO

BEGIN

with source_data as (
	select 
		patient.PatientKey,
		patient.Gender,
		agegroup.DATIMAgeGroup,
		facility.MFLCode,
		facility.FacilityName,
		facility.Longitude,
		facility.Latitude,
		facility.County,
		facility.SubCounty,
		partner.PartnerName,
		agency.AgencyName,
		evaluation.Date as RiskEvaluationDate,    
		appointment.Date as LastVisitAppointmentGivenDate,
		scores.LatestRiskScore,
		scores.LatestRiskCategory
	from NDWH.Fact.FactIITRiskScores as scores
	left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = scores.FacilityKey
	left join NDWH.Dim.DimPatient as patient on patient.PatientKey = scores.PatientKey
	left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = scores.AgencyKey
	left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = scores.PartnerKey
	left join NDWH.Dim.DimAgeGroup as agegroup on agegroup.AgeGroupKey = scores.AgeGroupKey
	left join NDWH.Dim.DimDate as appointment on appointment.DateKey = scores.LastVisitAppointmentGivenDateKey
	left join NDWH.Dim.DimDate as evaluation on evaluation.DateKey = scores.RiskEvaluationDateKey
)
select 
	MFLCode,
	FacilityName,
    Gender,
	DATIMAgeGroup as AgeGroup,
	Latitude,
	Longitude,
	SubCounty, 
	County,
	LatestRiskCategory,
	count(distinct PatientKey) as CountOfClients,
	sum(count(distinct PatientKey)) over(partition by MFLCode) as TotalClientsInFacility,
    sum(count(distinct PatientKey)) over(partition by SubCounty) as TotalClientsInSubCounty,
	sum(count(distinct PatientKey)) over(partition by County) as TotalClientsInCounty
into REPORTING.dbo.AggregateIITRiskScores
from source_data
where (LatestRiskCategory is not null or LatestRiskCategory <> '')
group by 
	FacilityName,
	MFLCode,
    Gender,
	DATIMAgeGroup,
	Latitude,
	Longitude,
	SubCounty, 
	County,
	LatestRiskCategory
END