IF OBJECT_ID(N'[REPORTING].[dbo].AggregateDefaulterTracingOutcome', N'U') IS NOT NULL 		
	DROP TABLE [REPORTING].[dbo].AggregateDefaulterTracingOutcome;

BEGIN

select
    facility.FacilityName,
    facility.County,
    facility.SubCounty,
    facility.MFLCode,
    partner.PartnerName,
    agency.AgencyName,
    agegroup.DATIMAgeGroup as AgeGroup,
    patient.Gender,
    diffcare.DifferentiatedCare,
    date.[Year] as Year,
    date.[Month] as Month,
    EOMONTH(date.Date) as AsOfDate,
    TracingOutcome,
    count(tracing.PatientKey) as patients,
    CAST(GETDATE() AS DATE) AS LoadDate  
into REPORTING.dbo.AggregateDefaulterTracingOutcome
from NDWH.dbo.FactDefaulterTracing tracing
left join NDWH.dbo.DimPatient as patient on patient.PatientKey = tracing.PatientKey
left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = tracing.FacilityKey
left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = tracing.PartnerKey
left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = tracing.AgencyKey
left join NDWH.dbo.DimAgeGroup as agegroup on agegroup.AgeGroupKey = tracing.AgeGroupKey
left join NDWH.dbo.DimDate as date on date.DateKey = tracing.VisitDateKey
left join NDWH.dbo.DimDifferentiatedCare as diffcare on diffcare.DifferentiatedCareKey = tracing.DifferentiatedCareKey
group by 
    facility.FacilityName,
    facility.County,
    facility.SubCounty,
    facility.MFLCode,
    partner.PartnerName,
    agency.AgencyName,
    agegroup.DATIMAgeGroup,
    patient.Gender,
    diffcare.DifferentiatedCare,
    date.[Year],
    date.[Month],
    EOMONTH(date.Date),
    TracingOutcome

END
