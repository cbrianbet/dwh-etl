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
from NDWH.Fact.FactDefaulterTracing tracing
left join NDWH.Dim.DimPatient as patient on patient.PatientKey = tracing.PatientKey
left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = tracing.FacilityKey
left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = tracing.PartnerKey
left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = tracing.AgencyKey
left join NDWH.Dim.DimAgeGroup as agegroup on agegroup.AgeGroupKey = tracing.AgeGroupKey
left join NDWH.Dim.DimDate as date on date.DateKey = tracing.VisitDateKey
left join NDWH.Dim.DimDifferentiatedCare as diffcare on diffcare.DifferentiatedCareKey = tracing.DifferentiatedCareKey
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
