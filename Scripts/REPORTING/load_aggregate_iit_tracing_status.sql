IF OBJECT_ID(N'[REPORTING].[dbo].AggregateIITTracingStatus', N'U') IS NOT NULL 		
	DROP TABLE [REPORTING].[dbo].AggregateIITTracingStatus;

BEGIN

with iit_as_of_date as (
select 
    FacilityKey,
    AgencyKey,
    PartnerKey,
    date.year as YearIIT,
    date.[Month] as MonthIIT,
    age_group.AgeGroupKey,
    patient.Gender,
    count( distinct history.PatientKey) as iit_patients
from NDWH.Fact.FactARTHistory as history
left join NDWH.Dim.DimARTOutcome as outcome on outcome.ARTOutcomeKey = history.ARTOutcomeKey
left join NDWH.Dim.DimDate as date on date.DateKey = history.AsOfDateKey
left join NDWH.Dim.DimPatient as patient on patient.PatientKey = history.PatientKey
left join NDWH.Dim.DimAgeGroup as age_group on age_group.Age = datediff(yy, patient.DOB, date.[Date])
where outcome.ARTOutcome in ('uL', 'L')
group by 
    FacilityKey,
    AgencyKey,
    PartnerKey,
    age_group.AgeGroupKey,
    Gender,
    date.Year,
    date.[Month]
),
defaulter_tracing as (
  select 
    FacilityKey,
    AgencyKey,
    PartnerKey,
    AgeGroupKey,
    patient.Gender,
    date.Year as AsofYearTracing,
    date.Month as AsofMonthTracing,
    count(distinct defaulter.PatientKey) as defaluter_traced_clients
  from NDWH.Fact.FactDefaulterTracing as defaulter
  left join NDWH.Dim.DimDate as date on date.DateKey = defaulter.VisitDateKey
  left join NDWH.Dim.DimPatient as patient on patient.PatientKey = defaulter.PatientKey
  group by 
    FacilityKey,
    AgencyKey,
    PartnerKey,
    AgeGroupKey,
    patient.Gender,
    date.Year,
    date.Month
),
combined_dataset as (
select 
    iit_as_of_date.YearIIT,
    iit_as_of_date.MonthIIT,
    iit_as_of_date.AgencyKey,
    iit_as_of_date.PartnerKey,
    iit_as_of_date.FacilityKey,
    iit_as_of_date.AgeGroupKey,
    iit_as_of_date.Gender,
    iit_as_of_date.iit_patients,
    coalesce(defaulter_tracing.defaluter_traced_clients, 0) as DefaulterTracedClients
from iit_as_of_date
inner join defaulter_tracing on defaulter_tracing.AsofYearTracing = iit_as_of_date.YearIIT
    and defaulter_tracing.AsofMonthTracing = iit_as_of_date.MonthIIT
    and defaulter_tracing.FacilityKey = iit_as_of_date.FacilityKey
    and defaulter_tracing.PartnerKey = iit_as_of_date.PartnerKey
    and defaulter_tracing.AgencyKey = iit_as_of_date.AgencyKey
    and defaulter_tracing.AgeGroupKey = iit_as_of_date.AgeGroupKey
    and defaulter_tracing.Gender = iit_as_of_date.Gender
),
enriched_dataset as (
    select
        case 
            when DefaulterTracedClients > iit_patients then DefaulterTracedClients
            else iit_patients 
        end as IITPatients,
        DefaulterTracedClients,
        YearIIT,
        MonthIIT,
        AgencyKey,
        PartnerKey,
        FacilityKey,
        AgeGroupKey,
        Gender
    from combined_dataset
)
select
    YearIIT,
    MonthIIT,
    EOMONTH(CAST(CONCAT(YearIIT, '-', MonthIIT, '-01') AS DATE)) AS AsofDate,
    agency.AgencyName,
    partner.PartnerName,
    facility.FacilityName,
    facility.County,
    facility.SubCounty,
    agegroup.DATIMAgeGroup as AgeGroup,
    Gender,
    IITPatients,
    DefaulterTracedClients,
    IITPatients - DefaulterTracedClients as DefaulterNotTracedClients,
    CAST(GETDATE() AS DATE) AS LoadDate 
into [REPORTING].[dbo].AggregateIITTracingStatus
from enriched_dataset
left join NDWH.Dim.DimFacility as facility on facility.FacilityKey = enriched_dataset.FacilityKey
left join NDWH.Dim.DimPartner as partner on partner.PartnerKey = enriched_dataset.PartnerKey
left join NDWH.Dim.DimAgency as agency on agency.AgencyKey = enriched_dataset.AgencyKey
left join NDWH.Dim.DimAgeGroup as agegroup on agegroup.AgeGroupKey = enriched_dataset.AgeGroupKey

END




